import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/services/analysis/comparison_service.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_dio.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
  });

  test('ComparisonService.fetchComparison parses response model', () async {
    final dio = FakeDio((request) async {
      expect(request.method, 'POST');
      expect(request.path, ApiEndpoints.fetchChangeDetection);
      expect(request.headers?['Authorization'], 'Bearer test-token');
      expect(request.data, {
        'lat': 11.0,
        'lng': 106.0,
        'date1': '2026-05-01',
        'date2': '2026-06-01',
        'cloud_cover': 0.3,
      });

      return buildResponse(request.path, {
        'code': 200,
        'message': 'ok',
        'data': {
          'id': 'cmp-1',
          'lat': 11.0,
          'lng': 106.0,
          'dates': ['2026-05-01', '2026-06-01'],
          'cloud_cover': 0.3,
          'created_at': '2026-06-08T00:00:00Z',
          'timeline': [
            {
              'date': '2026-05-01',
              'image_size': {'width': 640, 'height': 480},
              'total_pixels': 1000,
              'region_area_m2': 1200.5,
              'pixel_area_m2': 1.2,
              'classes': {
                'agriculture': {'area_km2': 1.4},
              },
            },
          ],
        },
      });
    });

    final service = ComparisonService(dio: dio);
    final result = await service.fetchComparison(
      lat: 11.0,
      lng: 106.0,
      date1: '2026-05-01',
      date2: '2026-06-01',
      cloudCover: 0.3,
    );

    expect(result['code'], 200);
    expect(result['message'], 'ok');
    expect(result['data'], isA<ComparisonModel>());
    expect((result['data'] as ComparisonModel).timeline, hasLength(1));
  });

  test('ComparisonService.fetchComparison handles DioException', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      final resp = buildResponse(request.path, {
        'message': 'service down',
      }, statusCode: 503);
      throw DioException(
        requestOptions: RequestOptions(path: request.path),
        response: resp,
      );
    });

    final service = ComparisonService(dio: dio);
    final result = await service.fetchComparison(
      lat: 0.0,
      lng: 0.0,
      date1: '2026-01-01',
      date2: '2026-02-01',
      cloudCover: 0.0,
    );

    expect(result['code'], 503);
    expect(result['message'], 'service down');
  });

  test(
    'ComparisonService.fetchComparisonByUser parses list response',
    () async {
      SharedPreferences.setMockInitialValues({'token': 'test-token'});

      final dio = FakeDio((request) async {
        expect(request.method, 'GET');
        expect(request.path, ApiEndpoints.fetchChangeDetection);

        return buildResponse(request.path, {
          'code': 200,
          'message': 'ok',
          'data': [
            {
              'id': 'cmp-1',
              'lat': 11.0,
              'lng': 106.0,
              'dates': ['2026-05-01', '2026-06-01'],
              'cloud_cover': 0.3,
              'created_at': '2026-06-08T00:00:00Z',
              'timeline': [],
            },
          ],
        });
      });

      final service = ComparisonService(dio: dio);
      final result = await service.fetchComparisonByUser();

      expect(result['code'], 200);
      expect(result['data'], isA<List>());
      expect((result['data'] as List).first, isA<ComparisonModel>());
    },
  );

  test('ComparisonService.deleteComparisonById returns success', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      expect(request.method, 'DELETE');
      expect(request.path, '${ApiEndpoints.fetchChangeDetection}/cmp-123');
      return buildResponse(request.path, {'code': 200, 'message': 'deleted'});
    });

    final service = ComparisonService(dio: dio);
    final result = await service.deleteComparisonById('cmp-123');

    expect(result['code'], 200);
    expect(result['message'], 'deleted');
  });

  test('ComparisonService.deleteAllComparisons returns count', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      expect(request.method, 'DELETE');
      expect(request.path, ApiEndpoints.fetchChangeDetection);
      return buildResponse(request.path, {
        'code': 200,
        'message': 'ok',
        'deleted': 7,
      });
    });

    final service = ComparisonService(dio: dio);
    final result = await service.deleteAllComparisons();

    expect(result['code'], 200);
    expect(result['count'], 7);
  });

  test('ComparisonService.deleteAllComparisons handles DioException', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      final resp = buildResponse(request.path, {
        'message': 'bad',
      }, statusCode: 400);
      throw DioException(
        requestOptions: RequestOptions(path: request.path),
        response: resp,
      );
    });

    final service = ComparisonService(dio: dio);
    final result = await service.deleteAllComparisons();

    expect(result['code'], 400);
    expect(result['message'], 'bad');
  });
}
