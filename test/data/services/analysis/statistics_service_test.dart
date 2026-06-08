import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/data/services/analysis/statistics_service.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_dio.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
  });

  test('StatisticsService.fetchStatistics parses response model', () async {
    final dio = FakeDio((request) async {
      expect(request.method, 'POST');
      expect(request.path, ApiEndpoints.fetchStatistics);
      expect(request.headers?['Authorization'], 'Bearer test-token');
      expect(request.data, {'analysis_id': 'analysis-1'});

      return buildResponse(request.path, {
        'code': 200,
        'message': 'ok',
        'data': {
          '_id': 'stats-1',
          'analysis_id': 'analysis-1',
          'created_at': '2026-06-08T00:00:00Z',
          'image_size': {'width': 1024, 'height': 768},
          'classes': {
            'agriculture': {
              'pixel_count': 120,
              'area_km2': 1.2,
              'percentage': 12.5,
            },
          },
          'total_pixels': 2048,
          'unmatched_pixels': 8,
          'pixel_area_m2': 2.5,
          'region_area_m2': 4096.0,
        },
      });
    });

    final service = StatisticsService(dio: dio);
    final result = await service.fetchStatistics(analysisId: 'analysis-1');

    expect(result['code'], 200);
    expect(result['message'], 'ok');
    expect(result['data'], isA<StatisticsModel>());
    expect(
      (result['data'] as StatisticsModel).classes.agriculture?.pixel_count,
      120,
    );
  });

  test('StatisticsService.fetchStatisticsById parses response model', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      expect(request.method, 'GET');
      expect(request.path, ApiEndpoints.fetchStatistics);

      return buildResponse(request.path, {
        'code': 200,
        'message': 'ok',
        'data': {
          '_id': 'stats-2',
          'analysis_id': 'analysis-2',
          'created_at': '2026-06-08T00:00:00Z',
          'image_size': {'width': 512, 'height': 512},
          'classes': {},
          'total_pixels': 0,
          'unmatched_pixels': 0,
          'pixel_area_m2': 0,
          'region_area_m2': 0,
        },
      });
    });

    final service = StatisticsService(dio: dio);
    final result = await service.fetchStatisticsById('analysis-2');

    expect(result['code'], 200);
    expect(result['data'], isA<StatisticsModel>());
    expect((result['data'] as StatisticsModel).id, 'stats-2');
  });

  test('StatisticsService.fetchStatistics works without analysisId', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      expect(request.method, 'POST');
      expect(request.path, ApiEndpoints.fetchStatistics);
      expect(request.headers?['Authorization'], 'Bearer test-token');

      // analysisId null thì payload phải rỗng
      expect(request.data, <String, dynamic>{});

      return buildResponse(request.path, {
        'code': 200,
        'message': 'ok',
        'data': {
          '_id': 'stats-null',
          'analysis_id': 'analysis-null',
          'created_at': '2026-06-08T00:00:00Z',
          'image_size': {'width': 100, 'height': 100},
          'classes': {},
          'total_pixels': 0,
          'unmatched_pixels': 0,
          'pixel_area_m2': 0,
          'region_area_m2': 0,
        },
      });
    });

    final service = StatisticsService(dio: dio);
    final result = await service.fetchStatistics();

    expect(result['code'], 200);
    expect(result['data'], isA<StatisticsModel>());
  });

  test('StatisticsService.fetchStatisticsById handles DioException', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      final resp = buildResponse(request.path, {
        'message': 'statistics not found',
      }, statusCode: 404);

      throw DioException(
        requestOptions: RequestOptions(path: request.path),
        response: resp,
      );
    });

    final service = StatisticsService(dio: dio);
    final result = await service.fetchStatisticsById('missing-analysis');

    expect(result['code'], 404);
    expect(result['message'], 'statistics not found');
  });

  test(
    'StatisticsService.deleteStatisticsById returns message on success',
    () async {
      SharedPreferences.setMockInitialValues({'token': 'test-token'});

      final dio = FakeDio((request) async {
        expect(request.method, 'DELETE');
        expect(request.path, '${ApiEndpoints.fetchStatistics}/analysis-3');
        return buildResponse(request.path, {'code': 200, 'message': 'deleted'});
      });

      final service = StatisticsService(dio: dio);
      final result = await service.deleteStatisticsById('analysis-3');

      expect(result['code'], 200);
      expect(result['message'], 'deleted');
    },
  );

  test('StatisticsService.deleteStatisticsById handles DioException', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      final resp = buildResponse(request.path, {
        'message': 'delete failed',
      }, statusCode: 500);
      throw DioException(
        requestOptions: RequestOptions(path: request.path),
        response: resp,
      );
    });

    final service = StatisticsService(dio: dio);
    final result = await service.deleteStatisticsById('analysis-4');

    expect(result['code'], 500);
    expect(result['message'], 'delete failed');
  });

  test('StatisticsService.deleteAllStatistics returns deleted count', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      expect(request.method, 'DELETE');
      expect(request.path, ApiEndpoints.fetchStatistics);
      expect(request.headers?['Authorization'], 'Bearer test-token');

      return buildResponse(request.path, {
        'code': 200,
        'message': 'all deleted',
        'deleted': 3,
      });
    });

    final service = StatisticsService(dio: dio);
    final result = await service.deleteAllStatistics();

    expect(result['code'], 200);
    expect(result['message'], 'all deleted');
    expect(result['count'], 3);
  });

  test('StatisticsService.deleteAllStatistics handles DioException', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      final resp = buildResponse(request.path, {
        'message': 'delete all failed',
      }, statusCode: 500);

      throw DioException(
        requestOptions: RequestOptions(path: request.path),
        response: resp,
      );
    });

    final service = StatisticsService(dio: dio);
    final result = await service.deleteAllStatistics();

    expect(result['code'], 500);
    expect(result['message'], 'delete all failed');
  });

  test('StatisticsService.fetchStatistics handles DioException', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      final resp = buildResponse(request.path, {
        'message': 'server error',
      }, statusCode: 500);
      throw DioException(
        requestOptions: RequestOptions(path: request.path),
        response: resp,
      );
    });

    final service = StatisticsService(dio: dio);
    final result = await service.fetchStatistics(analysisId: 'analysis-1');

    expect(result['code'], 500);
    expect(result['message'], 'server error');
  });
}
