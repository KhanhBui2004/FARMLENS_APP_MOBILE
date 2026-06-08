import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/auth/user_model.dart';
import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_dio.dart';

void main() {
  test('AuthService.login stores session data and returns user', () async {
    SharedPreferences.setMockInitialValues({});

    final dio = FakeDio((request) async {
      expect(request.method, 'POST');
      expect(request.path, ApiEndpoints.login);
      expect(request.data, {
        'identifier': 'demo-user',
        'password': 'secret123',
      });

      return buildResponse(request.path, {
        'code': 200,
        'message': 'Login successful',
        'access_token': 'access-token',
        'refresh_token': 'refresh-token',
        'user': {
          'id': 'user-1',
          'username': 'demo-user',
          'email': 'demo@example.com',
          'full_name': 'Demo User',
        },
      });
    });

    final service = AuthService(dio: dio);
    final result = await service.login('demo-user', 'secret123');

    expect(result['code'], 200);
    expect(result['message'], 'Login successful');
    expect(result['user'], isA<User>());

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), 'access-token');
    expect(prefs.getString('refreshToken'), 'refresh-token');
    expect(prefs.getString('userid'), 'user-1');
    expect(jsonDecode(prefs.getString('user')!) as Map<String, dynamic>, {
      'id': 'user-1',
      'username': 'demo-user',
      'email': 'demo@example.com',
      'full_name': 'Demo User',
    });
  });

  test('AuthService.logout clears stored preferences', () async {
    SharedPreferences.setMockInitialValues({
      'token': 'persisted-token',
      'refreshToken': 'persisted-refresh',
      'userid': 'user-1',
      'user': '{"id":"user-1"}',
    });

    final service = AuthService(dio: Dio());
    await service.logout();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
    expect(prefs.getString('refreshToken'), isNull);
    expect(prefs.getString('userid'), isNull);
    expect(prefs.getString('user'), isNull);
  });

  test(
    'AuthService.login handles DioException and returns error map',
    () async {
      SharedPreferences.setMockInitialValues({});

      final dio = FakeDio((request) async {
        // simulate server returning 401 with message
        final resp = buildResponse(request.path, {
          'message': 'Invalid credentials',
        }, statusCode: 401);
        throw DioException(
          requestOptions: RequestOptions(path: request.path),
          response: resp,
        );
      });

      final service = AuthService(dio: dio);
      final result = await service.login('bad-user', 'bad-pass');

      expect(result['code'], 401);
      expect(result['message'], 'Invalid credentials');
    },
  );

  test('AuthService.register returns success response', () async {
    final dio = FakeDio((request) async {
      expect(request.method, 'POST');
      expect(request.path, ApiEndpoints.register);
      expect(request.data, {
        'username': 'demo-user',
        'email': 'demo@example.com',
        'password': 'secret123',
        'full_name': 'Demo User',
      });

      return buildResponse(request.path, {
        'code': 200,
        'message': 'Registration successful',
      });
    });

    final service = AuthService(dio: dio);

    final result = await service.register(
      username: 'demo-user',
      email: 'demo@example.com',
      password: 'secret123',
      fullName: 'Demo User',
    );

    expect(result['code'], 200);
    expect(result['message'], 'Registration successful');
  });

  test(
    'AuthService.register handles DioException and returns error map',
    () async {
      final dio = FakeDio((request) async {
        final resp = buildResponse(request.path, {
          'message': 'Email already exists',
        }, statusCode: 400);

        throw DioException(
          requestOptions: RequestOptions(path: request.path),
          response: resp,
        );
      });

      final service = AuthService(dio: dio);

      final result = await service.register(
        username: 'demo-user',
        email: 'demo@example.com',
        password: 'secret123',
        fullName: 'Demo User',
      );

      expect(result['code'], 400);
      expect(result['message'], 'Email already exists');
    },
  );
}
