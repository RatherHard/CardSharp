import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/in_memory_auth_storage.dart';

/// 登录态持久化：假登录也把「谁登录了」写进本地存储，
/// 这样冷启动不必重新输入账号（password 从不落盘）。
void main() {
  group('登录态持久化', () {
    test('登录成功后把用户名写进存储', () async {
      final InMemoryAuthStorage storage = InMemoryAuthStorage();
      final FakeAuthRepository repository = FakeAuthRepository(storage);

      await repository.signIn(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      expect(storage.username, DevelopmentAccount.username);
    });

    test('用同一份存储新建 Repository 仍视为已登录', () async {
      final InMemoryAuthStorage storage = InMemoryAuthStorage();
      await FakeAuthRepository(storage)
          .signIn(username: DevelopmentAccount.username, password: DevelopmentAccount.password);

      // 模拟冷启动：全新的 Repository 实例，只有存储是同一份。
      final FakeAuthRepository restarted = FakeAuthRepository(storage);
      final user = await restarted.currentUser();

      expect(user, isNotNull);
      expect(user?.username, DevelopmentAccount.username);
    });

    test('退出登录会清空存储', () async {
      final InMemoryAuthStorage storage = InMemoryAuthStorage();
      final FakeAuthRepository repository = FakeAuthRepository(storage);
      await repository.signIn(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      await repository.signOut();

      expect(storage.username, isNull);
      expect(await FakeAuthRepository(storage).currentUser(), isNull);
    });

    test('密码错误不写入存储，并抛 invalidCredentials', () async {
      final InMemoryAuthStorage storage = InMemoryAuthStorage();
      final FakeAuthRepository repository = FakeAuthRepository(storage);

      await expectLater(
        repository.signIn(username: DevelopmentAccount.username, password: 'wrong-password'),
        throwsA(
          isA<AuthException>().having(
            (AuthException error) => error.failure,
            'failure',
            AuthFailure.invalidCredentials,
          ),
        ),
      );
      expect(storage.username, isNull);
    });
  });
}
