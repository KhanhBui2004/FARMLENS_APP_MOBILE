import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/presentation/home/widgets/actions_panel.dart';
import 'package:farmlens_app/presentation/home/widgets/chart_panel.dart';
import 'package:farmlens_app/presentation/home/widgets/comparison_panel.dart';
import 'package:farmlens_app/presentation/home/widgets/export_section.dart';
// import 'package:farmlens_app/presentation/home/widgets/stats_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

StatisticsModel buildStatsFixture() {
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
    currentAreaAssessment: null,
    surveyRegion: null,
    centerXRatio: null,
    centerYRatio: null,
    markerXRatio: null,
    markerYRatio: null,
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
  testWidgets('StatsActions triggers each action callback', (tester) async {
    var first = false;
    var second = false;
    var run = false;
    var change = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatsActions(
            onSelectFirstTime: () => first = true,
            onSelectSecondTime: () => second = true,
            onRunAnalysis: () => run = true,
            onChangeDetection: () => change = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Select Time'));
    await tester.pump();
    await tester.tap(find.text('Time Comparison'));
    await tester.pump();
    await tester.tap(find.text('Run Analysis'));
    await tester.pump();
    await tester.tap(find.text('Change Detection'));
    await tester.pump();

    expect(first, isTrue);
    expect(second, isTrue);
    expect(run, isTrue);
    expect(change, isTrue);
  });

  testWidgets('ExportSection handles enabled and exporting states', (
    tester,
  ) async {
    var exportFormat = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportSection(
            onExport: (format) => exportFormat = format,
            canExport: true,
            isExporting: false,
          ),
        ),
      ),
    );

    expect(find.text('Report export'), findsOneWidget);
    expect(find.text('Export PDF Report'), findsOneWidget);

    await tester.tap(find.text('Export PDF Report'));
    await tester.pump();

    expect(exportFormat, 'PDF');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExportSection(onExport: (_) {}, canExport: false)),
      ),
    );

    expect(
      find.text('Run segmentation analysis first to enable report export.'),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportSection(
            onExport: (_) {},
            canExport: true,
            isExporting: true,
          ),
        ),
      ),
    );

    expect(find.text('Exporting...'), findsOneWidget);
  });

  testWidgets('ChartPanel renders chart legend for valid statistics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ChartPanel(latestStats: buildStatsFixture())),
      ),
    );

    expect(find.text('Land cover distribution'), findsOneWidget);
    expect(find.textContaining('Agriculture (55.0%)'), findsOneWidget);
    expect(find.textContaining('Forest (20.0%)'), findsOneWidget);
    expect(find.textContaining('Water (4.0%)'), findsOneWidget);
  });

  testWidgets('ChartPanel shows empty and zero-state messages', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChartPanel(latestStats: null))),
    );

    expect(find.text('Land cover distribution'), findsNothing);

    final zeroStats = StatisticsModel(
      id: 'stats-zero',
      analysisId: 'analysis-zero',
      createdAt: '2026-06-09T00:00:00Z',
      imageSize: ImageSizeModel(width: 1, height: 1),
      classes: ClassesModel(
        agriculture: null,
        barren: null,
        forest: null,
        rangeland: null,
        unknown: null,
        urban: null,
        water: null,
      ),
      totalPixels: 0,
      unmatchedPixels: 0,
      pixelAreaM2: 0,
      regionAreaM2: 0,
      currentAreaAssessment: null,
      surveyRegion: null,
      centerXRatio: null,
      centerYRatio: null,
      markerXRatio: null,
      markerYRatio: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ChartPanel(latestStats: zeroStats)),
      ),
    );

    expect(
      find.text('No land cover statistics available yet.'),
      findsOneWidget,
    );
  });

  testWidgets('ComparisonPanel renders comparison table', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComparisonPanel(result: buildComparisonFixture(), error: null),
        ),
      ),
    );

    expect(find.text('Land cover comparison'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('01/05/2026'), findsOneWidget);
    expect(find.text('01/06/2026'), findsOneWidget);
    expect(find.text('Agriculture'), findsOneWidget);
    expect(find.text('0.50'), findsWidgets);
  });

  testWidgets('ComparisonPanel renders empty and error states', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ComparisonPanel(result: null, error: null)),
      ),
    );

    expect(find.text('Land cover comparison'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ComparisonPanel(result: null, error: 'Failed to load data'),
        ),
      ),
    );

    expect(find.text('Failed to load data'), findsOneWidget);
  });
}
