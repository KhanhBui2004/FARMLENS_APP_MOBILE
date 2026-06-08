import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('StatisticsModel.fromJson parses nested image size and classes', () {
    final model = StatisticsModel.fromJson({
      '_id': 'stats-1',
      'analysis_id': 'analysis-9',
      'created_at': '2026-06-08T00:00:00Z',
      'image_size': {'width': 1024, 'height': 768},
      'classes': {
        'agriculture': {
          'pixel_count': 1200,
          'area_km2': 3.5,
          'percentage': 42.5,
        },
        'forest': {
          'pixel_count': 800,
          'area_km2': 2.1,
          'percentage': 28.4,
        },
      },
      'total_pixels': 4096,
      'unmatched_pixels': 16,
      'pixel_area_m2': 12.5,
      'region_area_m2': 5120.0,
    });

    expect(model.id, 'stats-1');
    expect(model.analysisId, 'analysis-9');
    expect(model.createdAt, '2026-06-08T00:00:00Z');
    expect(model.imageSize.width, 1024);
    expect(model.imageSize.height, 768);
    expect(model.classes.agriculture?.pixel_count, 1200);
    expect(model.classes.agriculture?.area_km2, 3.5);
    expect(model.classes.agriculture?.percentage, 42.5);
    expect(model.classes.forest?.pixel_count, 800);
    expect(model.classes.water, isNull);
    expect(model.totalPixels, 4096);
    expect(model.unmatchedPixels, 16);
    expect(model.pixelAreaM2, 12.5);
    expect(model.regionAreaM2, 5120.0);
  });
}
