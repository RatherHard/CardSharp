import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_deck_repository.dart';
import '../domain/deck.dart';
import '../domain/deck_repository.dart';
import 'use_cases/create_deck_use_case.dart';
import 'use_cases/delete_deck_use_case.dart';
import 'use_cases/fetch_decks_use_case.dart';

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

  Future<void> _reload() async {
    state = await AsyncValue.guard(() => ref.read(fetchDecksUseCaseProvider).call());
  }
}
