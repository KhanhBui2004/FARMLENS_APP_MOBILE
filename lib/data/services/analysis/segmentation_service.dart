import 'dart:async';

import 'package:dio/dio.dart';
import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SegmentationService {
  final Dio _dio;
  SegmentationService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<Map<String, dynamic>> fetchSegmentation(
    double lat,
    double lng,
    String date,
    double cloudCover,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.post(
        ApiEndpoints.fetchSegmentation,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'lat': lat, 'lng': lng, 'date': date, 'cloud_cover': cloudCover},
      );
      final data = response.data;
      return {
        'code': data['code'],
        'message': data['message'],
        'data': SegmentationModel.fromJson(data['data']),
      };
    } on DioException catch (e) {
      throw Exception('Failed to fetch segmentation data: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchSegmentationByUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        ApiEndpoints.fetchSegmentation,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;

      final List<SegmentationModel> segmentationDatas = (data['data'] as List)
          .map((item) => SegmentationModel.fromJson(item))
          .toList();
          
      return {
        'code': data['code'],
        'message': data['message'],
        'data': segmentationDatas,
      };
    } on DioException catch (e) {
      throw Exception('Failed to fetch segmentation data: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> deleteSegmentationById(
    String segmentationId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        '${ApiEndpoints.fetchSegmentation}/$segmentationId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      return {'code': data['code'], 'message': data['message']};
    } on DioException catch (e) {
      throw Exception('Failed to delete segmentation data: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> deleteAllSegmentation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        ApiEndpoints.fetchSegmentation,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      return {
        'code': data['code'],
        'message': data['message'],
        'count': data['deleted'],
      };
    } on DioException catch (e) {
      throw Exception('Failed to delete segmentation data: ${e.message}');
    }
  }
}
