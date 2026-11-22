"""FSRS 排程引擎测试。

覆盖：纯函数性、单调性、边界、状态迁移。
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest
from app.domain.fsrs import (
    CardState,
    ReviewState,
    RunnerConfig,
    initial_difficulty,
    next_interval,
    retrievability,
    schedule,
)

NOW = datetime(2026, 11, 22, 12, 0, tzinfo=UTC)


class TestRetrievability:
    def test_at_stability_equals_stability_is_ninety_percent(self) -> None:
        # R(S, S) 应约等于 0.9
        assert retrievability(10.0, 10.0) == pytest.approx(0.9, abs=1e-6)

    def test_zero_elapsed_is_one(self) -> None:
        assert retrievability(0.0, 10.0) == 1.0

    def test_monotonically_decreasing(self) -> None:
        values = [retrievability(t, 10.0) for t in (0, 1, 5, 10, 30, 100)]
        assert values == sorted(values, reverse=True)

    def test_zero_stability_is_zero(self) -> None:
        assert retrievability(5.0, 0.0) == 0.0


class TestNextInterval:
    def test_higher_retention_shorter_interval(self) -> None:
        assert next_interval(10.0, 0.95) < next_interval(10.0, 0.85)

    def test_interval_grows_with_stability(self) -> None:
        assert next_interval(5.0, 0.9) < next_interval(50.0, 0.9)

    def test_minimum_one_day(self) -> None:
        assert next_interval(0.001, 0.9) >= 1.0


class TestInitialDifficulty:
    def test_within_bounds(self) -> None:
        for rating in (1, 2, 3, 4):
            d = initial_difficulty(rating)  # type: ignore[arg-type]
            assert 1.0 <= d <= 10.0

    def test_easier_rating_lower_difficulty(self) -> None:
        assert initial_difficulty(1) > initial_difficulty(4)  # type: ignore[arg-type]


class TestScheduleNewCard:
    def test_again_enters_learning(self) -> None:
        out = schedule(ReviewState(), 1, NOW)
        assert out.state.state is CardState.LEARNING
        assert out.state.due_at == NOW + timedelta(minutes=1)
        assert out.state.reps == 1

    def test_good_advances_step(self) -> None:
        out = schedule(ReviewState(), 3, NOW)
        assert out.state.state is CardState.LEARNING
        assert out.state.step == 1
        assert out.state.due_at == NOW + timedelta(minutes=10)

    def test_easy_graduates_immediately(self) -> None:
        out = schedule(ReviewState(), 4, NOW)
        assert out.state.state is CardState.REVIEW
        assert out.interval_days >= 1.0

    def test_naive_datetime_rejected(self) -> None:
        with pytest.raises(ValueError, match="时区"):
            schedule(ReviewState(), 3, datetime(2026, 11, 22, 12, 0))

    def test_invalid_rating_rejected(self) -> None:
        with pytest.raises(ValueError, match="rating"):
            schedule(ReviewState(), 5, NOW)  # type: ignore[arg-type]


class TestScheduleReviewCard:
    def _review_state(self, stability: float = 10.0, difficulty: float = 5.0) -> ReviewState:
        return ReviewState(
            stability=stability,
            difficulty=difficulty,
            due_at=NOW,
            last_review_at=NOW - timedelta(days=10),
            reps=3,
            lapses=0,
            state=CardState.REVIEW,
            step=0,
        )

    def test_good_increases_stability(self) -> None:
        before = self._review_state()
        out = schedule(before, 3, NOW)
        assert out.state.stability > before.stability
        assert out.state.state is CardState.REVIEW

    def test_again_increments_lapses_and_relearns(self) -> None:
        before = self._review_state()
        out = schedule(before, 1, NOW)
        assert out.state.state is CardState.RELEARNING
        assert out.state.lapses == before.lapses + 1
        assert out.state.stability < before.stability

    def test_intervals_monotonic_across_successes(self) -> None:
        """连续「良好」的间隔必须严格递增。

        注意：必须把 ``now`` 推进到上一次的 ``due_at``，否则 elapsed=0
        会被判定为「同日复习」，稳定度不增长（这是 FSRS 的正确行为）。
        """
        state = self._review_state()
        intervals: list[float] = []
        now = NOW
        for _ in range(5):
            out = schedule(state, 3, now)
            intervals.append(out.interval_days)
            state = ReviewState(
                stability=out.state.stability,
                difficulty=out.state.difficulty,
                due_at=out.state.due_at,
                last_review_at=now,
                reps=out.state.reps,
                lapses=out.state.lapses,
                state=out.state.state,
                step=out.state.step,
            )
            now = now + timedelta(days=out.interval_days)
        assert intervals == sorted(intervals), f"间隔应单调递增: {intervals}"
        assert len(set(intervals)) == len(intervals), f"间隔应严格递增: {intervals}"

    def test_easy_longer_than_good(self) -> None:
        before = self._review_state()
        assert schedule(before, 4, NOW).interval_days > schedule(before, 3, NOW).interval_days

    def test_hard_shorter_than_good(self) -> None:
        before = self._review_state()
        assert schedule(before, 2, NOW).interval_days < schedule(before, 3, NOW).interval_days


class TestDeterminism:
    def test_same_input_same_output(self) -> None:
        state = ReviewState(
            stability=12.5,
            difficulty=4.2,
            due_at=NOW,
            last_review_at=NOW - timedelta(days=12),
            reps=5,
            lapses=1,
            state=CardState.REVIEW,
        )
        a = schedule(state, 3, NOW)
        b = schedule(state, 3, NOW)
        assert a == b


class TestConfigValidation:
    def test_rejects_out_of_range_retention(self) -> None:
        with pytest.raises(ValueError, match="desired_retention"):
            RunnerConfig(desired_retention=0.5)

    def test_rejects_wrong_weight_count(self) -> None:
        with pytest.raises(ValueError, match="19"):
            RunnerConfig(weights=(0.1, 0.2))

    def test_custom_retention_changes_interval(self) -> None:
        state = ReviewState(
            stability=10.0,
            difficulty=5.0,
            last_review_at=NOW - timedelta(days=10),
            state=CardState.REVIEW,
        )
        low = schedule(state, 3, NOW, RunnerConfig(desired_retention=0.80))
        high = schedule(state, 3, NOW, RunnerConfig(desired_retention=0.95))
        assert low.interval_days > high.interval_days
