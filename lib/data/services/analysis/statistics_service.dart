// import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  final Dio _dio;
  StatisticsService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<Map<String, dynamic>> fetchStatistics({String? analysisId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final payload = <String, dynamic>{'analysis_id': analysisId};
      payload.removeWhere((key, value) => value == null);
      final response = await _dio.post(
        ApiEndpoints.fetchStatistics,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload,
      );
      final data = response.data;
      return {
        'code': data['code'],
        'message': data['message'],
        'data': StatisticsModel.fromJson(data['data']),
      };
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message':
            e.response?.data['message'] ?? 'Failed to fetch statistics data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchStatisticsById(String analysisId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        ApiEndpoints.fetchStatistics,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {'analysis_id': analysisId},
      );
      final data = response.data;

      return {
        'code': data['code'],
        'message': data['message'],
        'data': StatisticsModel.fromJson(data['data']),
      };
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message':
            e.response?.data['message'] ?? 'Failed to fetch statistics data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteStatisticsById(String analysisId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        '${ApiEndpoints.fetchStatistics}/$analysisId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;

      return {'code': data['code'], 'message': data['message']};
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message':
            e.response?.data['message'] ?? 'Failed to delete statistics data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteAllStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        ApiEndpoints.fetchStatistics,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;

      return {
        'code': data['code'],
        'message': data['message'],
        'count': data['deleted'],
      };
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message':
            e.response?.data['message'] ?? 'Failed to delete statistics data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }
}
