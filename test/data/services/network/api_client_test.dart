import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/data/services/network/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiClient includes AuthInterceptor', () {
    final has = ApiClient.dio.interceptors
        .whereType<AuthInterceptor>()
        .isNotEmpty;
    expect(has, isTrue);
  });
}
