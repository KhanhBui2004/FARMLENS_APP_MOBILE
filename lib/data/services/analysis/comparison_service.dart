import 'dart:async';

import 'package:dio/dio.dart';
import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';

class ComparisonService {
  final Dio _dio;

  ComparisonService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<Map<String, dynamic>> fetchComparison({
    required double lat,
    required double lng,
    required String date1,
    required String date2,
    required double cloudCover,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.post(
        ApiEndpoints.fetchChangeDetection,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'lat': lat,
          'lng': lng,
          'date1': date1,
          'date2': date2,
          'cloud_cover': cloudCover,
        },
      );
      final data = response.data;
      return {
        'code': data['code'],
        'message': data['message'],
        'data': ComparisonModel.fromJson(data['data']),
      };
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message':
            e.response?.data['message'] ?? 'Failed to fetch comparison data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchComparisonByUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        ApiEndpoints.fetchChangeDetection,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;

      final List<ComparisonModel> comparisonDatas = (data['data'] as List)
          .map((item) => ComparisonModel.fromJson(item))
          .toList();

      return {
        'code': data['code'],
        'message': data['message'],
        'data': comparisonDatas,
      };
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message':
            e.response?.data['message'] ?? 'Failed to fetch comparison data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteComparisonById(String analysisId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        '${ApiEndpoints.fetchChangeDetection}/$analysisId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;

      return {'code': data['code'], 'message': data['message']};
    } on DioException catch (e) {
      return {
        'code': e.response?.statusCode ?? 500,
        'message':
            e.response?.data['message'] ?? 'Failed to delete comparison data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteAllComparisons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        ApiEndpoints.fetchChangeDetection,
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
            e.response?.data['message'] ?? 'Failed to delete comparison data',
      };
    } catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }
}
