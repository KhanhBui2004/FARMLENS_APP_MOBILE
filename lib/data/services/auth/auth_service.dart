import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/auth/user_model.dart';
import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;
  AuthService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'identifier': identifier, 'password': password},
      );

      final User user = User.fromJson(response.data['user']);

      final token = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('refreshToken', refreshToken);
      await prefs.setString('userid', user.id);
      await prefs.setString('user', jsonEncode(user.toJson()));
      return {
        'code': response.data['code'],
        'message': response.data['message'],
        'user': user,
      };
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message': e.response?.data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );
      final data = response.data;
      return {'code': data['code'], 'message': data['message']};
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message': e.response?.data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
    String? fullName,
    String? password,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (username != null) body['username'] = username;
      if (email != null) body['email'] = email;
      if (fullName != null) body['full_name'] = fullName;
      if (password != null) body['password'] = password;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.patch(
        ApiEndpoints.profile,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: body,
      );

      final data = response.data;

      if (data['code'] == 200) {
        final updatedUser = User.fromJson(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(updatedUser.toJson()));
      }
      return {'code': data['code'], 'message': data['message']};
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message': e.response?.data['message'] ?? 'Profile update failed',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
