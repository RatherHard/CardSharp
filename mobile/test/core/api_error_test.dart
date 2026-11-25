import 'package:cardsharp/core/network/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiError', () {
    test('能解析后端标准错误体', () {
      final ApiError error = ApiError.fromJson(<String, dynamic>{
        'error': <String, dynamic>{
          'code': 'DECK_NOT_FOUND',
          'message': '卡片集不存在',
          'request_id': 'req_123',
        },
      });

      expect(error.code, 'DECK_NOT_FOUND');
      expect(error.message, '卡片集不存在');
      expect(error.requestId, 'req_123');
      expect(error.isNotFound, isTrue);
    });

    test('结构不符合契约时不抛异常，退化为未知错误', () {
      final ApiError error = ApiError.fromJson(<String, dynamic>{'detail': 'oops'});

      expect(error.code, 'UNKNOWN');
      expect(error.isNotFound, isFalse);
      expect(error.isUnauthorized, isFalse);
    });

    test('识别登录失效', () {
      final ApiError error = ApiError.fromJson(<String, dynamic>{
        'error': <String, dynamic>{'code': 'TOKEN_EXPIRED', 'message': '登录已过期'},
      });

      expect(error.isUnauthorized, isTrue);
    });

    test('识别校验失败', () {
      final ApiError error = ApiError.fromJson(<String, dynamic>{
        'error': <String, dynamic>{'code': 'VALIDATION_FAILED', 'message': 'ciphertext 超长'},
      });

      expect(error.isValidation, isTrue);
    });
  });
}
