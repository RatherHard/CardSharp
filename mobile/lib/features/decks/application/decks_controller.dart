import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/di/service_providers.dart';
import '../../../core/network/page.dart';
import '../domain/deck.dart';
import '../domain/deck_import.dart';
import 'deck_cover_providers.dart';
import 'deck_list_state.dart';
import 'use_cases/create_deck_use_case.dart';
import 'use_cases/delete_deck_use_case.dart';
import 'use_cases/fetch_decks_use_case.dart';
import 'use_cases/import_deck_use_case.dart';
import 'use_cases/update_deck_use_case.dart';

/// 用例注入点。状态层只依赖用例与 domain 接口，不出现任何 data 层实现
/// （`AGENTS.md` §2.1 分层约定；仓储端口声明在 `core/di/repository_providers.dart`）。
final fetchDecksUseCaseProvider = Provider<FetchDecksUseCase>(
  (Ref ref) => FetchDecksUseCase(ref.watch(deckRepositoryProvider)),
);
final createDeckUseCaseProvider = Provider<CreateDeckUseCase>(
  (Ref ref) => CreateDeckUseCase(ref.watch(deckRepositoryProvider)),
);
final deleteDeckUseCaseProvider = Provider<DeleteDeckUseCase>(
  (Ref ref) => DeleteDeckUseCase(ref.watch(deckRepositoryProvider)),
);
final updateDeckUseCaseProvider = Provider<UpdateDeckUseCase>(
  (Ref ref) => UpdateDeckUseCase(ref.watch(deckRepositoryProvider)),
);

/// 导入用例需要同时用到卡片仓储，属于应用层编排（组合两个 feature 的 domain 接口）。
/// 这是本仓库唯一一处跨 feature 的 application 依赖，注释保留原因。
final importDeckUseCaseProvider = Provider<ImportDeckUseCase>(
  (Ref ref) =>
      ImportDeckUseCase(ref.watch(deckRepositoryProvider), ref.watch(cardRepositoryProvider)),
);

/// 书架列表状态。异步用 [AsyncNotifier]，页面用 `switch` 匹配 AsyncValue。
///
/// 状态类本身在 [DeckListState]（freezed 生成 `copyWith`，`docs/05` §6）。
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

  /// 删除卡片集，并清掉本机保存的封面副本。
  ///
  /// 封面图不在后端契约里（`decks` 只有 `color`），是本机缓存；卡片集没了缓存也要清，
  /// 否则重建同名集或换设备导入时会露出旧图。清理失败不算删除失败，见 [_removeLocalCover]。
  Future<void> delete(String id) async {
    await ref.read(deleteDeckUseCaseProvider).call(id);
    await _removeLocalCover(id);
    await _reload();
  }

  /// 尽力清理本地封面：只是缓存，失败就不管了，下次读到脏记录由服务自己自愈。
  Future<void> _removeLocalCover(String id) async {
    try {
      await ref.read(deckCoverServiceProvider).removeCover(id);
      ref.invalidate(deckCoverPathProvider(id));
    } on Object {
      // 组合根没注入封面服务（纯数据层测试）时这里抛 StateError，忽略即可。
    }
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
