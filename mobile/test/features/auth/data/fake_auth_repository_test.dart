import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_auth_storage.dart';

void main() {
  group('FakeAuthRepository', () {
    test('未登录时 currentUser 返回 null', () async {
      expect(await FakeAuthRepository(InMemoryAuthStorage()).currentUser(), isNull);
    });

    test('内置账号可登录，返回对应用户名', () async {
      final repository = FakeAuthRepository(InMemoryAuthStorage());

      final user = await repository.signIn(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      expect(user.username, DevelopmentAccount.username);
      expect((await repository.currentUser())?.id, DevelopmentAccount.username);
    });

    test('账号前后空格被忽略', () async {
      final repository = FakeAuthRepository(InMemoryAuthStorage());

      final user = await repository.signIn(
        username: '  ${DevelopmentAccount.username} ',
        password: DevelopmentAccount.password,
      );

      expect(user.username, DevelopmentAccount.username);
    });

    test('密码错误抛 AuthException', () async {
      final repository = FakeAuthRepository(InMemoryAuthStorage());

      expect(
        () => repository.signIn(username: DevelopmentAccount.username, password: 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.failure,
            'failure',
            AuthFailure.invalidCredentials,
          ),
        ),
      );
    });

    test('账号错误抛 AuthException 且不会进入登录态', () async {
      final repository = FakeAuthRepository(InMemoryAuthStorage());

      await expectLater(
        repository.signIn(username: 'admin', password: DevelopmentAccount.password),
        throwsA(isA<AuthException>()),
      );
      expect(await repository.currentUser(), isNull);
    });

    test('密码大小写与尾随空格敏感', () async {
      final repository = FakeAuthRepository(InMemoryAuthStorage());

      expect(
        () => repository.signIn(
          username: DevelopmentAccount.username,
          password: '${DevelopmentAccount.password} ',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('登录后 signOut 清空登录态', () async {
      final repository = FakeAuthRepository(InMemoryAuthStorage());
      await repository.signIn(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      await repository.signOut();

      expect(await repository.currentUser(), isNull);
    });
  });
}
