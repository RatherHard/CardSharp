/// 本期假登录使用的内置账号。
///
/// 放在 domain 而不是 data：登录页需要把它展示给使用者，而 presentation 只允许
/// 依赖 domain / application，不能反向依赖 data 实现（否则接后端换实现时页面要跟着改）。
abstract final class DevelopmentAccount {
  static const String username = 'test';
  static const String password = '123456';
}
