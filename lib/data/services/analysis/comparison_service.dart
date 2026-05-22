import 'dart:async';

import 'package:dio/dio.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';

class ComparisonService {
	final Dio _dio;

	ComparisonService({Dio? dio}) : _dio = dio ?? Dio();

	Future<Map<String, dynamic>> fetchComparison({
		required double lat,
		required double lng,
		required String date1,
		required String date2,
		required double cloudCover,
	}) async {
		try {
			final response = await _dio.post(
				ApiEndpoints.fetchChangeDetection,
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
			throw Exception('Failed to fetch comparison data: ${e.message}');
		}
	}
}
