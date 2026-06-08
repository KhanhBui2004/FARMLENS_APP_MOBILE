import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/presentation/history/widgets/change_detection_list.dart';
import 'package:farmlens_app/presentation/history/widgets/history_card.dart';
import 'package:farmlens_app/presentation/history/widgets/history_tab_selector.dart';
import 'package:farmlens_app/presentation/history/widgets/segmentation_list.dart';
import 'package:farmlens_app/presentation/history/widgets/comparison_details_sheet.dart';
import 'package:farmlens_app/presentation/history/widgets/segmentation_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../home/home_widgets_test.dart';

SegmentationModel buildSegmentationFixture() {
  return SegmentationModel.fromJson({
    '_id': 'seg-1',
    'lat': 10.5,
    'lng': 106.7,
    'date': '2026-06-01',
    'cloud_cover': 0.2,
    'sentinel_url': 'https://example.com/sentinel.png',
    'segmentation_url': 'https://example.com/segmentation.png',
    'region_area_m2': 2300.5,
  });
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
        },
      },
    ],
  });
}

void main() {
  testWidgets('HistoryCard shows content and handles tap/delete', (
    tester,
  ) async {
    var tapped = false;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryCard(
            title: 'Analysis 1',
            subtitle: 'Date: 2026-06-01',
            lines: const ['Line 1', 'Line 2'],
            onTap: () => tapped = true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('Analysis 1'), findsOneWidget);
    expect(find.text('Line 1'), findsOneWidget);

    await tester.tap(find.text('Analysis 1'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(tapped, isTrue);
    expect(deleted, isTrue);
  });

  testWidgets('HistoryTabSelector switches between tabs', (tester) async {
    var segmentationTapped = false;
    var changeDetectionTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryTabSelector(
            isSegmentationTab: true,
            onSegmentationTap: () => segmentationTapped = true,
            onChangeDetectionTap: () => changeDetectionTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Segmentation list'), findsOneWidget);
    expect(find.text('Change detection list'), findsOneWidget);

    await tester.tap(find.text('Segmentation list'));
    await tester.pump();
    await tester.tap(find.text('Change detection list'));
    await tester.pump();

    expect(segmentationTapped, isTrue);
    expect(changeDetectionTapped, isTrue);
  });

  testWidgets('SegmentationList handles empty and populated states', (
    tester,
  ) async {
    var deleteAll = false;
    SegmentationModel? tappedItem;
    SegmentationModel? deletedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SegmentationList(
            items: const [],
            onDeleteAll: () {},
            onItemTap: (_) {},
            onDeleteItem: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('No segmentation history yet.'), findsOneWidget);

    final item = buildSegmentationFixture();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SegmentationList(
            items: [item],
            onDeleteAll: () => deleteAll = true,
            onItemTap: (value) => tappedItem = value,
            onDeleteItem: (value) => deletedItem = value,
          ),
        ),
      ),
    );

    expect(find.text('Your History'), findsOneWidget);
    expect(find.text('Analysis 1'), findsOneWidget);
    expect(find.text('Date: 2026-06-01'), findsOneWidget);

    await tester.tap(find.text('Analysis 1'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    await tester.tap(find.text('Delete all'));
    await tester.pump();

    expect(tappedItem, item);
    expect(deletedItem, item);
    expect(deleteAll, isTrue);
  });

  testWidgets('SegmentationDetailsSheet shows details and statistics', (
    tester,
  ) async {
    final item = buildSegmentationFixture();
    final stats = buildStatsFixture();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SegmentationDetailsSheet(
            item: item,
            statisticsFuture: Future.value(stats),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Segmentation details'), findsOneWidget);
    expect(find.text('Analysis ID'), findsOneWidget);
    expect(find.text('seg-1'), findsOneWidget);
    expect(find.text('Segmentation Date'), findsOneWidget);
    expect(find.text('2026-06-01'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('10.5000, 106.7000'), findsOneWidget);
    expect(find.text('Land cover statistics'), findsOneWidget);
    expect(find.text('Agriculture'), findsWidgets);
    expect(find.text('55.00%'), findsOneWidget);
    expect(find.text('3.500 km2'), findsOneWidget);
  });

  testWidgets('ChangeDetectionList handles empty and populated states', (
    tester,
  ) async {
    var deleteAll = false;
    ComparisonModel? tappedItem;
    ComparisonModel? deletedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeDetectionList(
            items: const [],
            onDeleteAll: () {},
            onItemTap: (_) {},
            onDeleteItem: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('No change detection history yet.'), findsOneWidget);

    final item = buildComparisonFixture();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeDetectionList(
            items: [item],
            onDeleteAll: () => deleteAll = true,
            onItemTap: (value) => tappedItem = value,
            onDeleteItem: (value) => deletedItem = value,
          ),
        ),
      ),
    );

    expect(find.text('Your History'), findsOneWidget);
    expect(find.text('Change detection 1'), findsOneWidget);
    expect(find.textContaining('Cloud cover:'), findsOneWidget);

    await tester.tap(find.text('Change detection 1'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    await tester.tap(find.text('Delete all'));
    await tester.pump();

    expect(tappedItem, item);
    expect(deletedItem, item);
    expect(deleteAll, isTrue);
  });

  testWidgets('ComparisonDetailsSheet shows comparison details', (
    tester,
  ) async {
    final item = buildComparisonFixture();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ComparisonDetailsSheet(item: item)),
      ),
    );

    expect(find.text('Change detection details'), findsOneWidget);
    expect(find.text('Analysis ID'), findsOneWidget);
    expect(find.text('cmp-1'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('11.0000, 106.0000'), findsOneWidget);
    expect(find.text('Cloud cover'), findsOneWidget);
    expect(find.text('0.3%'), findsOneWidget);
    expect(find.text('Change timeline'), findsOneWidget);
    expect(find.text('2026-05-01'), findsOneWidget);
    expect(find.text('2026-06-01'), findsOneWidget);
    expect(find.text('Agriculture'), findsWidgets);
  });
}
