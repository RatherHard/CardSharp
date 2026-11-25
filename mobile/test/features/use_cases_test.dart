import 'package:cardsharp/core/network/page.dart';
import 'package:cardsharp/features/auth/application/use_cases/sign_in_use_case.dart';
import 'package:cardsharp/features/auth/application/use_cases/sign_out_use_case.dart';
import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:cardsharp/features/decks/application/use_cases/create_deck_use_case.dart';
import 'package:cardsharp/features/decks/application/use_cases/delete_deck_use_case.dart';
import 'package:cardsharp/features/decks/application/use_cases/fetch_decks_use_case.dart';
import 'package:cardsharp/features/decks/data/fake_deck_repository.dart';
import 'package:cardsharp/features/decks/domain/deck.dart';
import 'package:flutter_test/flutter_test.dart';

/// 用例层是薄壳，但仍要验证「调对了实现、错误原样冒泡」，
/// 否则接后端换实现时用例层出错不会被测试发现。
void main() {
  group('认证用例', () {
    test('SignIn 把账号密码交给仓储并返回用户', () async {
      final repository = FakeAuthRepository();
      final useCase = SignInUseCase(repository);

      final user = await useCase(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      expect(user.username, DevelopmentAccount.username);
    });

    test('SignIn 把仓储的认证失败原样抛给上层', () async {
      final useCase = SignInUseCase(FakeAuthRepository());

      await expectLater(
        useCase(username: DevelopmentAccount.username, password: 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });

    test('SignOut 清掉仓储里的登录态', () async {
      final repository = FakeAuthRepository();
      await repository.signIn(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      await SignOutUseCase(repository)();

      expect(await repository.currentUser(), isNull);
    });
  });

  group('卡片集用例', () {
    test('FetchDecks 返回种子数据', () async {
      final useCase = FetchDecksUseCase(FakeDeckRepository());

      final PagedResult<Deck> page = await useCase();

      expect(page.items, hasLength(6));
      expect(page.nextCursor, isNull);
    });

    test('CreateDeck 返回带 id 与零卡片数的新卡片集', () async {
      final useCase = CreateDeckUseCase(FakeDeckRepository());

      final deck = await useCase(title: '  新建的  ');

      expect(deck.title, '新建的');
      expect(deck.cardCount, 0);
      expect(deck.id, isNotEmpty);
    });

    test('DeleteDeck 删除不存在的 id 时抛 StateError', () async {
      final useCase = DeleteDeckUseCase(FakeDeckRepository());

      await expectLater(useCase('not-exist'), throwsA(isA<StateError>()));
    });
  });
}
