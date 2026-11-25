import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cards/application/cards_controller.dart';
import '../data/fake_deck_repository.dart';
import '../domain/deck.dart';
import '../domain/deck_import.dart';
import '../domain/deck_repository.dart';
import 'use_cases/create_deck_use_case.dart';
import 'use_cases/delete_deck_use_case.dart';
import 'use_cases/fetch_decks_use_case.dart';
import 'use_cases/import_deck_use_case.dart';
import 'use_cases/update_deck_use_case.dart';

/// 数据源注入点：接后端时只改这一行（`HttpDeckRepository(ref)`）。
final deckRepositoryProvider = Provider<DeckRepository>((ref) => FakeDeckRepository());

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

/// 书架列表状态。异步用 [AsyncNotifier]，页面用 `switch` 匹配 AsyncValue。
final decksControllerProvider = AsyncNotifierProvider<DecksController, List<Deck>>(
  DecksController.new,
);

class DecksController extends AsyncNotifier<List<Deck>> {
  @override
  Future<List<Deck>> build() => ref.read(fetchDecksUseCaseProvider).call();

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

  /// 更新卡片集，成功后整体重拉，保证列表里看到的是数据源的真实状态。
  /// 方法名不能叫 `update`：AsyncNotifier 已有一个同名成员，会构成非法重写。
  Future<Deck> updateDeck(Deck deck) async {
    final Deck updated = await ref.read(updateDeckUseCaseProvider).call(deck);
    await _reload();
    return updated;
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(() => ref.read(fetchDecksUseCaseProvider).call());
  }

  /// 导入一份卡片集（含卡片），成功后整体重拉。
  Future<Deck> importDeck(DeckImport data) async {
    final Deck deck = await ref.read(importDeckUseCaseProvider).call(data);
    await _reload();
    return deck;
  }
}
