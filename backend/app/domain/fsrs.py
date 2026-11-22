"""FSRS-5 排程引擎。

设计约束（见 docs/03-MVP设计文档.md ADR-003）：

* **纯函数**：不读写数据库、不读时钟、不依赖全局状态。
* **确定性**：相同输入必然产生相同输出。
* **可测试**：所有分支均可通过构造 ``ReviewState`` 覆盖。

公式参考 FSRS-5 官方实现，权重 ``w`` 共 19 个参数。
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from datetime import datetime, timedelta
from enum import IntEnum
from typing import Literal

#: 遗忘曲线衰减率
DECAY: float = -0.5
#: 缩放因子，使 R(S, S) ≈ 0.9
FACTOR: float = 19 / 81

#: FSRS-5 默认权重
DEFAULT_WEIGHTS: tuple[float, ...] = (
    0.40255,
    1.18385,
    3.173,
    15.69105,
    7.1945,
    0.5345,
    1.4604,
    0.0046,
    1.54575,
    0.1192,
    1.01925,
    1.9395,
    0.11,
    0.29605,
    2.2698,
    0.2315,
    2.9898,
    0.51655,
    0.6621,
)

#: 间隔上限（天），防止浮点溢出
MAX_INTERVAL_DAYS: float = 36500.0
#: 稳定度下限，防止除零
MIN_STABILITY: float = 0.01

Rating = Literal[1, 2, 3, 4]
"""1=忘记 2=困难 3=良好 4=简单"""


class CardState(IntEnum):
    """卡片学习阶段。与数据库 ``review_states.state`` 对应。"""

    NEW = 0
    LEARNING = 1
    REVIEW = 2
    RELEARNING = 3


@dataclass(frozen=True, slots=True)
class RunnerConfig:
    """卡片集级别的排程配置。"""

    desired_retention: float = 0.9
    maximum_interval_days: int = 36500
    learning_steps: tuple[int, ...] = (1, 10)
    relearning_steps: tuple[int, ...] = (10,)
    weights: tuple[float, ...] = DEFAULT_WEIGHTS

    def __post_init__(self) -> None:
        if not 0.70 <= self.desired_retention <= 0.99:
            raise ValueError("desired_retention 必须在 [0.70, 0.99] 区间")
        if len(self.weights) != 19:
            raise ValueError(f"FSRS 权重必须是 19 个，实际 {len(self.weights)}")
        if not self.learning_steps:
            raise ValueError("learning_steps 不能为空")


@dataclass(frozen=True, slots=True)
class ReviewState:
    """一张卡片的复习状态快照。"""

    stability: float = 0.0
    difficulty: float = 0.0
    due_at: datetime | None = None
    last_review_at: datetime | None = None
    reps: int = 0
    lapses: int = 0
    state: CardState = CardState.NEW
    step: int = 0


@dataclass(frozen=True, slots=True)
class ReviewOutcome:
    """一次评分后的结果。"""

    state: ReviewState
    interval_days: float
    retrievability: float


# --------------------------------------------------------------------- 基础公式


def retrievability(elapsed_days: float, stability: float) -> float:
    """可提取概率 ``R(t, S) = (1 + FACTOR * t / S) ** DECAY``。"""
    if stability <= 0:
        return 0.0
    if elapsed_days <= 0:
        return 1.0
    return float((1 + FACTOR * elapsed_days / stability) ** DECAY)


def next_interval(stability: float, desired_retention: float) -> float:
    """由目标保留率反解间隔天数：``I = (S / FACTOR) * (r ** (1/DECAY) - 1)``。"""
    if stability <= 0:
        return 0.0
    raw = (stability / FACTOR) * (desired_retention ** (1 / DECAY) - 1)
    return float(min(max(raw, 1.0), MAX_INTERVAL_DAYS))


def initial_stability(rating: Rating, w: tuple[float, ...] = DEFAULT_WEIGHTS) -> float:
    return float(w[rating - 1])


def initial_difficulty(rating: Rating, w: tuple[float, ...] = DEFAULT_WEIGHTS) -> float:
    d = w[4] - math.exp(w[5] * (rating - 1)) + 1
    return float(min(max(d, 1.0), 10.0))


def next_difficulty(
    difficulty: float, rating: Rating, w: tuple[float, ...] = DEFAULT_WEIGHTS
) -> float:
    d = difficulty - w[6] * (rating - 3)
    d = w[7] * initial_difficulty(4, w) + (1 - w[7]) * d
    return float(min(max(d, 1.0), 10.0))


def next_stability_on_recall(
    stability: float,
    difficulty: float,
    recall: float,
    rating: Rating,
    w: tuple[float, ...] = DEFAULT_WEIGHTS,
) -> float:
    """记住后的稳定度增长。"""
    hard_penalty = w[15] if rating == 2 else 1.0
    easy_bonus = w[16] if rating == 4 else 1.0
    s = stability * (
        1
        + math.exp(w[8])
        * (11 - difficulty)
        * stability ** (-w[9])
        * (math.exp(w[10] * (1 - recall)) - 1)
        * hard_penalty
        * easy_bonus
    )
    return float(max(s, MIN_STABILITY))


def next_stability_on_forget(
    stability: float,
    difficulty: float,
    recall: float,
    w: tuple[float, ...] = DEFAULT_WEIGHTS,
) -> float:
    """遗忘后的稳定度衰退。"""
    s = (
        w[11]
        * difficulty ** (-w[12])
        * ((stability + 1) ** w[13] - 1)
        * math.exp(w[14] * (1 - recall))
    )
    return float(max(s, MIN_STABILITY))


# --------------------------------------------------------------------- 主入口


def schedule(
    state: ReviewState,
    rating: Rating,
    now: datetime,
    config: RunnerConfig | None = None,
) -> ReviewOutcome:
    """根据一次评分推进状态。

    Args:
        state: 评分前的状态。
        rating: 1=忘记 2=困难 3=良好 4=简单。
        now: 当前时间（必须带时区）。
        config: 卡片集配置，默认使用标准参数。

    Returns:
        新的状态与本次间隔。

    Raises:
        ValueError: ``now`` 未带时区，或 ``rating`` 不在 1–4。
    """
    if now.tzinfo is None:
        raise ValueError("now 必须带时区")
    if rating not in (1, 2, 3, 4):
        raise ValueError(f"rating 必须是 1–4，实际 {rating}")

    cfg = config or RunnerConfig()
    w = cfg.weights

    if state.state is CardState.NEW:
        return _schedule_new(state, rating, now, cfg, w)
    if state.state in (CardState.LEARNING, CardState.RELEARNING):
        return _schedule_learning(state, rating, now, cfg, w)
    return _schedule_review(state, rating, now, cfg, w)


def _schedule_new(
    state: ReviewState,
    rating: Rating,
    now: datetime,
    cfg: RunnerConfig,
    w: tuple[float, ...],
) -> ReviewOutcome:
    stability = initial_stability(rating, w)
    difficulty = initial_difficulty(rating, w)
    steps = cfg.learning_steps

    if rating == 1:
        due = now + timedelta(minutes=steps[0])
        new_state = ReviewState(
            stability=stability,
            difficulty=difficulty,
            due_at=due,
            last_review_at=now,
            reps=1,
            lapses=0,
            state=CardState.LEARNING,
            step=0,
        )
        return ReviewOutcome(new_state, _minutes_to_days(steps[0]), 1.0)

    if rating in (2, 3):
        step = 0 if rating == 2 else min(1, len(steps) - 1)
        due = now + timedelta(minutes=steps[step])
        new_state = ReviewState(
            stability=stability,
            difficulty=difficulty,
            due_at=due,
            last_review_at=now,
            reps=1,
            lapses=0,
            state=CardState.LEARNING,
            step=step,
        )
        return ReviewOutcome(new_state, _minutes_to_days(steps[step]), 1.0)

    # rating == 4：直接毕业
    interval = next_interval(stability, cfg.desired_retention)
    new_state = ReviewState(
        stability=stability,
        difficulty=difficulty,
        due_at=now + timedelta(days=interval),
        last_review_at=now,
        reps=1,
        lapses=0,
        state=CardState.REVIEW,
        step=0,
    )
    return ReviewOutcome(new_state, interval, 1.0)


def _schedule_learning(
    state: ReviewState,
    rating: Rating,
    now: datetime,
    cfg: RunnerConfig,
    w: tuple[float, ...],
) -> ReviewOutcome:
    steps = cfg.learning_steps if state.state is CardState.LEARNING else cfg.relearning_steps
    step = min(state.step, len(steps) - 1)

    if rating == 1:
        due = now + timedelta(minutes=steps[0])
        new_state = ReviewState(
            stability=state.stability,
            difficulty=next_difficulty(state.difficulty, rating, w),
            due_at=due,
            last_review_at=now,
            reps=state.reps + 1,
            lapses=state.lapses,
            state=state.state,
            step=0,
        )
        return ReviewOutcome(new_state, _minutes_to_days(steps[0]), 1.0)

    if rating == 2:
        due = now + timedelta(minutes=steps[step])
        new_state = ReviewState(
            stability=state.stability,
            difficulty=next_difficulty(state.difficulty, rating, w),
            due_at=due,
            last_review_at=now,
            reps=state.reps + 1,
            lapses=state.lapses,
            state=state.state,
            step=step,
        )
        return ReviewOutcome(new_state, _minutes_to_days(steps[step]), 1.0)

    # rating 3 / 4：推进或毕业
    next_step = step + 1
    if next_step >= len(steps) or rating == 4:
        interval = next_interval(state.stability, cfg.desired_retention)
        new_state = ReviewState(
            stability=state.stability,
            difficulty=next_difficulty(state.difficulty, rating, w),
            due_at=now + timedelta(days=interval),
            last_review_at=now,
            reps=state.reps + 1,
            lapses=state.lapses,
            state=CardState.REVIEW,
            step=0,
        )
        return ReviewOutcome(new_state, interval, 1.0)

    due = now + timedelta(minutes=steps[next_step])
    new_state = ReviewState(
        stability=state.stability,
        difficulty=next_difficulty(state.difficulty, rating, w),
        due_at=due,
        last_review_at=now,
        reps=state.reps + 1,
        lapses=state.lapses,
        state=state.state,
        step=next_step,
    )
    return ReviewOutcome(new_state, _minutes_to_days(steps[next_step]), 1.0)


def _schedule_review(
    state: ReviewState,
    rating: Rating,
    now: datetime,
    cfg: RunnerConfig,
    w: tuple[float, ...],
) -> ReviewOutcome:
    elapsed = 0.0
    if state.last_review_at is not None:
        elapsed = max((now - state.last_review_at).total_seconds() / 86400.0, 0.0)
    recall = retrievability(elapsed, state.stability)

    if rating == 1:
        stability = next_stability_on_forget(state.stability, state.difficulty, recall, w)
        difficulty = next_difficulty(state.difficulty, rating, w)
        step_minutes = cfg.relearning_steps[0]
        new_state = ReviewState(
            stability=stability,
            difficulty=difficulty,
            due_at=now + timedelta(minutes=step_minutes),
            last_review_at=now,
            reps=state.reps + 1,
            lapses=state.lapses + 1,
            state=CardState.RELEARNING,
            step=0,
        )
        return ReviewOutcome(new_state, _minutes_to_days(step_minutes), recall)

    stability = next_stability_on_recall(state.stability, state.difficulty, recall, rating, w)
    difficulty = next_difficulty(state.difficulty, rating, w)
    interval = next_interval(stability, cfg.desired_retention)
    interval = min(interval, float(cfg.maximum_interval_days))
    new_state = ReviewState(
        stability=stability,
        difficulty=difficulty,
        due_at=now + timedelta(days=interval),
        last_review_at=now,
        reps=state.reps + 1,
        lapses=state.lapses,
        state=CardState.REVIEW,
        step=0,
    )
    return ReviewOutcome(new_state, interval, recall)


def _minutes_to_days(minutes: float) -> float:
    return minutes / 1440.0
