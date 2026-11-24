import 'package:cardsharp/features/auth/data/fake_auth_repository.dart';
import 'package:cardsharp/features/auth/domain/auth_repository.dart';
import 'package:cardsharp/features/auth/domain/development_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeAuthRepository', () {
    test('未登录时 currentUser 返回 null', () async {
      expect(await FakeAuthRepository().currentUser(), isNull);
    });

    test('内置账号可登录，返回对应用户名', () async {
      final repository = FakeAuthRepository();

      final user = await repository.signIn(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      expect(user.username, DevelopmentAccount.username);
      expect((await repository.currentUser())?.id, DevelopmentAccount.username);
    });

    test('账号前后空格被忽略', () async {
      final repository = FakeAuthRepository();

      final user = await repository.signIn(
        username: '  ${DevelopmentAccount.username} ',
        password: DevelopmentAccount.password,
      );

      expect(user.username, DevelopmentAccount.username);
    });

    test('密码错误抛 AuthException', () async {
      final repository = FakeAuthRepository();

      expect(
        () => repository.signIn(username: DevelopmentAccount.username, password: 'wrong'),
        throwsA(
          isA<AuthException>().having((AuthException e) => e.message, 'message', '用户名或密码不正确'),
        ),
      );
    });

    test('账号错误抛 AuthException 且不会进入登录态', () async {
      final repository = FakeAuthRepository();

      await expectLater(
        repository.signIn(username: 'admin', password: DevelopmentAccount.password),
        throwsA(isA<AuthException>()),
      );
      expect(await repository.currentUser(), isNull);
    });

    test('密码大小写与尾随空格敏感', () async {
      final repository = FakeAuthRepository();

      expect(
        () => repository.signIn(
          username: DevelopmentAccount.username,
          password: '${DevelopmentAccount.password} ',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('登录后 signOut 清空登录态', () async {
      final repository = FakeAuthRepository();
      await repository.signIn(
        username: DevelopmentAccount.username,
        password: DevelopmentAccount.password,
      );

      await repository.signOut();

      expect(await repository.currentUser(), isNull);
    });
  });
}
