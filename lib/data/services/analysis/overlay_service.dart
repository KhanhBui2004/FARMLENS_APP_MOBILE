import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/analysis/overlay_model.dart';
import 'dart:async';

import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayService {
  final Dio _dio;
  OverlayService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<Map<String, dynamic>> fetchOverlay(String analysisId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        ApiEndpoints.fetchOverlay,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {'analysis_id': analysisId},
      );
      final data = response.data;
      return {
        'code': data['code'],
        'message': data['message'],
        'data': OverlayModel.fromJson(data['data']),
      };
    } on DioException catch (e) {
      throw Exception('Failed to fetch overlay data: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> postOverlay(String analysisId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.post(
        ApiEndpoints.fetchOverlay,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'analysis_id': analysisId},
      );
      final data = response.data;

      return {
        'code': data['code'],
        'message': data['message'],
        'data': OverlayModel.fromJson(data['data']),
      };
    } on DioException catch (e) {
      throw Exception('Failed to fetch overlay data: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> deleteOverlay(String analysisId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        '${ApiEndpoints.fetchOverlay}/$analysisId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;

      return {'code': data['code'], 'message': data['message']};
    } on DioException catch (e) {
      throw Exception('Failed to delete overlay data: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> deleteAllOverlay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        ApiEndpoints.fetchOverlay,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;

      return {
        'code': data['code'],
        'message': data['message'],
        'count': data['deleted'],
      };
    } on DioException catch (e) {
      throw Exception('Failed to delete overlay data: ${e.message}');
    }
  }
}
