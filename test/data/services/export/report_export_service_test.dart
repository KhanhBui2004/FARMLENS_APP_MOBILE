import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/data/services/export/report_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

StatisticsModel buildStatisticsFixture() {
  return StatisticsModel(
    id: 'stats-1',
    analysisId: 'analysis-1',
    createdAt: '2026-06-09T00:00:00Z',
    imageSize: ImageSizeModel(width: 1024, height: 768),
    classes: ClassesModel(
      agriculture: ClassStatsModel(
        pixel_count: 1200,
        area_km2: 3.5,
        percentage: 55.0,
      ),
      barren: ClassStatsModel(pixel_count: 100, area_km2: 0.4, percentage: 5.0),
      forest: ClassStatsModel(
        pixel_count: 600,
        area_km2: 2.1,
        percentage: 20.0,
      ),
      rangeland: ClassStatsModel(
        pixel_count: 120,
        area_km2: 0.7,
        percentage: 6.0,
      ),
      unknown: null,
      urban: ClassStatsModel(pixel_count: 300, area_km2: 1.2, percentage: 10.0),
      water: ClassStatsModel(pixel_count: 80, area_km2: 0.3, percentage: 4.0),
    ),
    totalPixels: 2400,
    unmatchedPixels: 0,
    pixelAreaM2: 2.5,
    regionAreaM2: 6000.0,
  );
}

ComparisonModel buildComparisonFixture() {
  return ComparisonModel.fromJson({
    'id': 'cmp-1',
    'lat': 11.0,
    'lng': 106.0,
    'dates': ['2026-05-01', '2026-06-01'],
    'cloud_cover': 0.3,
    'created_at': '2026-06-09T00:00:00Z',
    'timeline': [
      {
        'date': '2026-05-01',
        'image_size': {'width': 640, 'height': 480},
        'total_pixels': 1000,
        'region_area_m2': 1200.5,
        'pixel_area_m2': 1.2,
        'classes': {
          'agriculture': {'area_km2': 1.4},
          'forest': {'area_km2': 0.8},
        },
      },
      {
        'date': '2026-06-01',
        'image_size': {'width': 640, 'height': 480},
        'total_pixels': 1000,
        'region_area_m2': 1200.5,
        'pixel_area_m2': 1.2,
        'classes': {
          'agriculture': {'area_km2': 1.9},
          'forest': {'area_km2': 0.5},
        },
      },
    ],
  });
}

void main() {
  test('buildPdfReport generates bytes without image URLs', () async {
    final service = ReportExportService();

    final bytes = await service.buildPdfReport(
      stats: buildStatisticsFixture(),
      segmentationId: 'seg-1',
      analysisDate: DateTime(2026, 6, 9),
      lat: 11.0,
      lng: 106.0,
      cloudCoverage: 18.0,
      calculatedArea: 125.5,
      sentinelImageUrl: null,
      segmentationImageUrl: null,
      comparisonResult: buildComparisonFixture(),
    );

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));
  });
}
