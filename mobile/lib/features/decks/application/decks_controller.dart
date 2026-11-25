import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/page.dart';
import '../../cards/application/cards_controller.dart';
import '../../cards/data/fake_card_repository.dart';
import '../../cards/domain/card_repository.dart';
import '../data/fake_deck_repository.dart';
import '../domain/deck.dart';
import '../domain/deck_import.dart';
import '../domain/deck_repository.dart';
import 'use_cases/create_deck_use_case.dart';
import 'use_cases/delete_deck_use_case.dart';
import 'use_cases/fetch_decks_use_case.dart';
import 'use_cases/import_deck_use_case.dart';
import 'use_cases/update_deck_use_case.dart';

/// 数据源注入点：接后端时只改这一处（`HttpDeckRepository(ref)`）。
///
/// 假实现注入 `cardCounter`：卡片数由卡片仓储统计，避免假仓储之间互相依赖。
/// 接后端后这个参数不再需要——统计由服务端 `decks.stats` 提供。
final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  final CardRepository cards = ref.watch(cardRepositoryProvider);
  return FakeDeckRepository(kSeedDecks, cards is FakeCardRepository ? cards.countFor : null);
});

/// 用例注入点。状态层只依赖用例，不直接碰仓储实现（`AGENTS.md` §5.2 分层约定）。
final fetchDecksUseCaseProvider = Provider<FetchDecksUseCase>(
  (ref) => FetchDecksUseCase(ref.watch(deckRepositoryProvider)),
);
final createDeckUseCaseProvider = Provider<CreateDeckUseCase>(
  (ref) => CreateDeckUseCase(ref.watch(deckRepositoryProvider)),
);
final deleteDeckUseCaseProvider = Provider<DeleteDeckUseCase>(
  (ref) => DeleteDeckUseCase(ref.watch(deckRepositoryProvider)),
);
final updateDeckUseCaseProvider = Provider<UpdateDeckUseCase>(
  (ref) => UpdateDeckUseCase(ref.watch(deckRepositoryProvider)),
);

/// 导入用例需要同时用到卡片仓储，属于应用层编排（组合两个 feature 的仓储）。
/// 这是本仓库唯一一处跨 feature 的 application 依赖，注释保留原因。
final importDeckUseCaseProvider = Provider<ImportDeckUseCase>(
  (ref) => ImportDeckUseCase(ref.watch(deckRepositoryProvider), ref.watch(cardRepositoryProvider)),
);

/// 书架列表状态：已加载的卡片集 + 下一页游标。
///
/// 用状态类而不是裸 `List<Deck>`：`hasMore` 与 `loadingMore` 也属于列表状态，
/// 放在页面里各存一份会重复，且容易与数据不同步。
class DeckListState {
  const DeckListState({required this.decks, this.nextCursor, this.loadingMore = false});

  final List<Deck> decks;

  /// 下一页游标；null 表示已到底。
  final String? nextCursor;

  /// 正在加载下一页。
  final bool loadingMore;

  bool get hasMore => nextCursor != null;

  DeckListState copyWith({List<Deck>? decks, String? nextCursor, bool? loadingMore}) =>
      DeckListState(
        decks: decks ?? this.decks,
        nextCursor: nextCursor ?? this.nextCursor,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// 书架列表状态。异步用 [AsyncNotifier]，页面用 `switch` 匹配 AsyncValue。
final decksControllerProvider = AsyncNotifierProvider<DecksController, DeckListState>(
  DecksController.new,
);

class DecksController extends AsyncNotifier<DeckListState> {
  @override
  Future<DeckListState> build() => _fetchFirstPage();

  Future<DeckListState> _fetchFirstPage() async {
    final PagedResult<Deck> page = await ref.read(fetchDecksUseCaseProvider).call();
    return DeckListState(decks: page.items, nextCursor: page.nextCursor);
  }

  /// 滚动到底部时加载下一页。重复调用安全：正在加载或没有下一页时直接返回。
  Future<void> loadMore() async {
    final DeckListState? current = switch (state) {
      AsyncData<DeckListState>(:final DeckListState value) => value,
      _ => null,
    };
    if (current == null || !current.hasMore || current.loadingMore) {
      return;
    }
    state = AsyncData<DeckListState>(current.copyWith(loadingMore: true));
    try {
      final PagedResult<Deck> next = await ref
          .read(fetchDecksUseCaseProvider)
          .call(cursor: current.nextCursor);
      state = AsyncData<DeckListState>(
        DeckListState(decks: <Deck>[...current.decks, ...next.items], nextCursor: next.nextCursor),
      );
    } on Object {
      // 加载下一页失败不该清空已看到的内容，只把 loading 复位。
      state = AsyncData<DeckListState>(current.copyWith(loadingMore: false));
    }
  }

  /// 新建后整体重拉，保持「顺序由数据源决定」这条约定。
  Future<Deck> create(String title) async {
    final deck = await ref.read(createDeckUseCaseProvider).call(title: title);
    await _reload();
    return deck;
  }

  Future<void> delete(String id) async {
    await ref.read(deleteDeckUseCaseProvider).call(id);
    await _reload();
  }

  /// 更新卡片集（局部字段），成功后整体重拉，保证列表里看到的是数据源的真实状态。
  /// 方法名不能叫 `update`：AsyncNotifier 已有一个同名成员，会构成非法重写。
  Future<Deck> updateDeck(String id, {String? title, String? description, String? color}) async {
    final Deck updated = await ref
        .read(updateDeckUseCaseProvider)
        .call(id, title: title, description: description, color: color);
    await _reload();
    return updated;
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(_fetchFirstPage);
  }

  /// 导入一份卡片集（含卡片），成功后整体重拉。
  Future<Deck> importDeck(DeckImport data) async {
    final Deck deck = await ref.read(importDeckUseCaseProvider).call(data);
    await _reload();
    return deck;
  }
}
