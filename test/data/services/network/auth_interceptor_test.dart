import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:farmlens_app/data/services/network/auth_interceptor.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';

import '../../../helpers/fake_dio.dart';

// Tests exercise the interceptor through a real `Dio` instance so we
// avoid implementing `ErrorInterceptorHandler` manually or importing
// dio internals. `FakeDio` provides a customizable adapter for responses.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('onError with non-401 results in thrown DioException', () async {
    final dio = FakeDio((request) async {
      return buildResponse(request.path, {'message': 'bad'}, statusCode: 500);
    });

    dio.interceptors.add(AuthInterceptor());

    try {
      await dio.get('/x');
      fail('Expected a DioException');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 500);
    }
  });

  test('onError 401 without refresh token throws 401', () async {
    SharedPreferences.setMockInitialValues({});

    final dio = FakeDio((request) async {
      return buildResponse(request.path, {'message': 'unauth'}, statusCode: 401);
    });

    dio.interceptors.add(AuthInterceptor());

    try {
      await dio.get('/x');
      fail('Expected a DioException');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 401);
    }
  });

  test('onError 401 with refresh token refreshes and retries', () async {
    SharedPreferences.setMockInitialValues({'refreshToken': 'r1'});

    final refreshDio = FakeDio((request) async {
      if (request.path == ApiEndpoints.refresh) {
        return buildResponse(request.path, {'token': 'new-token'});
      }
      return buildResponse(request.path, {'message': 'ok'});
    });

    // main Dio: returns 401 unless Authorization header has new-token
    final dio = FakeDio((request) async {
      if (request.path == '/protected') {
        final auth = request.headers?['Authorization'] as String?;
        if (auth != null && auth.contains('new-token')) {
          return buildResponse(request.path, {'data': 'ok'});
        }
        return buildResponse(request.path, {'message': 'unauth'}, statusCode: 401);
      }
      return buildResponse(request.path, {'message': 'ok'});
    });

    dio.interceptors.add(AuthInterceptor(refreshDio: refreshDio));

    final resp = await dio.get('/protected');

    expect(resp.statusCode, 200);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), 'new-token');
  });

  test('onError 401 with refresh failure clears prefs', () async {
    SharedPreferences.setMockInitialValues({
      'refreshToken': 'r1',
      'token': 'old',
    });

    final refreshDio = FakeDio((request) async {
      final resp = buildResponse(request.path, {'message': 'bad refresh'}, statusCode: 400);
      throw DioException(requestOptions: RequestOptions(path: request.path), response: resp);
    });

    final dio = FakeDio((request) async {
      return buildResponse(request.path, {'message': 'unauth'}, statusCode: 401);
    });

    dio.interceptors.add(AuthInterceptor(refreshDio: refreshDio));

    try {
      await dio.get('/protected');
      fail('Expected a DioException due to failed refresh');
    } on DioException catch (_) {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), isNull);
    }
  });
}
