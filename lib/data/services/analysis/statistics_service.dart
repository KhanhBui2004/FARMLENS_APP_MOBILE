// import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';

class StatisticsService {
  final Dio _dio;
  // StatisticsService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  StatisticsService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> fetchStatistics({
    String? analysisId,
    String? segmentationBase64,
    double? pixelAreaM2,
  }) async {
    try {
      final payload = <String, dynamic>{
        'analysis_id': analysisId,
        'segmentation_base64': segmentationBase64,
        'pixel_area_m2': pixelAreaM2,
      };
      payload.removeWhere((key, value) => value == null);
      final response = await _dio.post(
        ApiEndpoints.fetchStatistics,
        data: payload,
      );
      final data = response.data;
      return {
        'code': data['code'],
        'message': data['message'],
        'data': StatisticsModel.fromJson(data['data']),
      };
    } on DioException catch (e) {
      throw Exception('Failed to fetch statistics data: ${e.message}');
    }
  }
}