import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SegmentationModel.fromJson parses API payload', () {
    final model = SegmentationModel.fromJson({
      '_id': 'seg-1',
      'lat': 10.25,
      'lng': 106.75,
      'date': '2026-06-08',
      'cloud_cover': 0.15,
      'sentinel_url': 'https://example.com/sentinel.png',
      'segmentation_url': 'https://example.com/segmentation.png',
      'region_area_m2': 2300.5,
    });

    expect(model.id, 'seg-1');
    expect(model.lat, 10.25);
    expect(model.lng, 106.75);
    expect(model.date, '2026-06-08');
    expect(model.cloudCover, 0.15);
    expect(model.sentinelImageUrl, 'https://example.com/sentinel.png');
    expect(model.segmentationUrl, 'https://example.com/segmentation.png');
    expect(model.regionAreaM2, 2300.5);
  });
}
