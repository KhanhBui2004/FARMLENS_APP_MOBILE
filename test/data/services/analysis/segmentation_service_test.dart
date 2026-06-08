import 'package:dio/dio.dart';
import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/services/analysis/segmentation_service.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_dio.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
  });

  test('SegmentationService.fetchSegmentation parses response model', () async {
    final dio = FakeDio((request) async {
      expect(request.method, 'POST');
      expect(request.path, ApiEndpoints.fetchSegmentation);
      expect(request.headers?['Authorization'], 'Bearer test-token');
      expect(request.data, {
        'lat': 10.5,
        'lng': 106.7,
        'date': '2026-06-01',
        'cloud_cover': 0.2,
      });

      return buildResponse(request.path, {
        'code': 200,
        'message': 'ok',
        'data': {
          '_id': 'seg-1',
          'lat': 10.5,
          'lng': 106.7,
          'date': '2026-06-01',
          'cloud_cover': 0.2,
          'sentinel_url': 'https://example.com/sentinel.png',
          'segmentation_url': 'https://example.com/segmentation.png',
          'region_area_m2': 2300.5,
        },
      });
    });

    final service = SegmentationService(dio: dio);
    final result = await service.fetchSegmentation(
      10.5,
      106.7,
      '2026-06-01',
      0.2,
    );

    expect(result['code'], 200);
    expect(result['message'], 'ok');
    expect(result['data'], isA<SegmentationModel>());
    expect((result['data'] as SegmentationModel).id, 'seg-1');
  });

  test(
    'SegmentationService.fetchSegmentationByUser parses list response',
    () async {
      SharedPreferences.setMockInitialValues({'token': 'test-token'});

      final dio = FakeDio((request) async {
        expect(request.method, 'GET');
        expect(request.path, ApiEndpoints.fetchSegmentation);

        return buildResponse(request.path, {
          'code': 200,
          'message': 'ok',
          'data': [
            {
              '_id': 'seg-1',
              'lat': 10.5,
              'lng': 106.7,
              'date': '2026-06-01',
              'cloud_cover': 0.2,
              'sentinel_url': 'https://example.com/s1.png',
              'segmentation_url': 'https://example.com/s1_seg.png',
              'region_area_m2': 2300.5,
            },
          ],
        });
      });

      final service = SegmentationService(dio: dio);
      final result = await service.fetchSegmentationByUser();

      expect(result['code'], 200);
      expect(result['data'], isA<List>());
      expect((result['data'] as List).first, isA<SegmentationModel>());
    },
  );

  test('SegmentationService.deleteSegmentationById returns success', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      expect(request.method, 'DELETE');
      expect(request.path, '${ApiEndpoints.fetchSegmentation}/seg-123');
      return buildResponse(request.path, {'code': 200, 'message': 'deleted'});
    });

    final service = SegmentationService(dio: dio);
    final result = await service.deleteSegmentationById('seg-123');

    expect(result['code'], 200);
    expect(result['message'], 'deleted');
  });

  test('SegmentationService.deleteAllSegmentation returns count', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      expect(request.method, 'DELETE');
      expect(request.path, ApiEndpoints.fetchSegmentation);
      return buildResponse(request.path, {
        'code': 200,
        'message': 'ok',
        'deleted': 3,
      });
    });

    final service = SegmentationService(dio: dio);
    final result = await service.deleteAllSegmentation();

    expect(result['code'], 200);
    expect(result['count'], 3);
  });

  test(
    'SegmentationService.deleteAllSegmentation handles DioException',
    () async {
      SharedPreferences.setMockInitialValues({'token': 'test-token'});

      final dio = FakeDio((request) async {
        final resp = buildResponse(request.path, {
          'message': 'fail',
        }, statusCode: 400);
        throw DioException(
          requestOptions: RequestOptions(path: request.path),
          response: resp,
        );
      });

      final service = SegmentationService(dio: dio);
      final result = await service.deleteAllSegmentation();

      expect(result['code'], 400);
      expect(result['message'], 'fail');
    },
  );

  test('SegmentationService.fetchSegmentation handles DioException', () async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});

    final dio = FakeDio((request) async {
      final resp = buildResponse(request.path, {
        'message': 'not found',
      }, statusCode: 404);
      throw DioException(
        requestOptions: RequestOptions(path: request.path),
        response: resp,
      );
    });

    final service = SegmentationService(dio: dio);
    final result = await service.fetchSegmentation(0.0, 0.0, '2026-01-01', 0.0);

    expect(result['code'], 404);
    expect(result['message'], 'not found');
  });
}
