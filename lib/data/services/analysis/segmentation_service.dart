import 'dart:async';

import 'package:dio/dio.dart';
// import 'package:farmlens_app/data/services/network/api_client.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';

class SegmentationService {
  final Dio _dio;
  // SegmentationService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  SegmentationService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> fetchSegmentation(
    double lat,
    double lng,
    String startDate,
    String endDate,
    double cloudCover,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.fetchSegmentation,
        data: {
          'lat': lat,
          'lng': lng,
          'start_date': startDate,
          'end_date': endDate,
          'cloud_cover': cloudCover,
        },
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
}
