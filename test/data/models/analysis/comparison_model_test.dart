import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ComparisonModel.fromJson parses timeline and nested classes', () {
    final model = ComparisonModel.fromJson({
      'id': 'cmp-1',
      'lat': 11.0,
      'lng': 106.0,
      'dates': ['2026-05-01', '2026-06-01'],
      'cloud_cover': 0.22,
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
            'water': {'area_km2': 0.2},
          },
        },
      ],
    });

    expect(model.id, 'cmp-1');
    expect(model.lat, 11.0);
    expect(model.lng, 106.0);
    expect(model.dates, ['2026-05-01', '2026-06-01']);
    expect(model.cloudCover, 0.22);
    expect(model.createdAt, '2026-06-08T00:00:00Z');
    expect(model.timeline, hasLength(1));
    expect(model.timeline.first.date, '2026-05-01');
    expect(model.timeline.first.imageSize['width'], 640);
    expect(model.timeline.first.totalPixels, 1000);
    expect(model.timeline.first.classes.agriculture?.areaKm2, 1.4);
    expect(model.timeline.first.classes.water?.areaKm2, 0.2);
  });
}
