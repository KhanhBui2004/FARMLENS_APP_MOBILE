import 'package:farmlens_app/data/services/analysis/comparison_service.dart';
import 'package:farmlens_app/data/services/analysis/segmentation_service.dart';
import 'package:farmlens_app/data/services/analysis/statistics_service.dart';
import 'package:farmlens_app/presentation/history/history_screen.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../home/home_widgets_test.dart' hide buildComparisonFixture;
import 'history_widgets_test.dart';

class FakeSegmentationService extends SegmentationService {
  final Map<String, dynamic> fetchResult;
  final Map<String, dynamic> deleteAllResult;
  final Map<String, dynamic> deleteByIdResult;

  FakeSegmentationService({
    required this.fetchResult,
    this.deleteAllResult = const {'code': 200, 'message': 'deleted'},
    this.deleteByIdResult = const {'code': 200, 'message': 'deleted'},
  });

  @override
  Future<Map<String, dynamic>> fetchSegmentationByUser() async {
    return fetchResult;
  }

  @override
  Future<Map<String, dynamic>> deleteAllSegmentation() async {
    return deleteAllResult;
  }

  @override
  Future<Map<String, dynamic>> deleteSegmentationById(String id) async {
    return deleteByIdResult;
  }
}

class FakeComparisonService extends ComparisonService {
  final Map<String, dynamic> fetchResult;
  final Map<String, dynamic> deleteAllResult;
  final Map<String, dynamic> deleteByIdResult;

  FakeComparisonService({
    required this.fetchResult,
    this.deleteAllResult = const {'code': 200, 'message': 'deleted'},
    this.deleteByIdResult = const {'code': 200, 'message': 'deleted'},
  });

  @override
  Future<Map<String, dynamic>> fetchComparisonByUser() async {
    return fetchResult;
  }

  @override
  Future<Map<String, dynamic>> deleteAllComparisons() async {
    return deleteAllResult;
  }

  @override
  Future<Map<String, dynamic>> deleteComparisonById(String id) async {
    return deleteByIdResult;
  }
}

class FakeStatisticsService extends StatisticsService {
  final Map<String, dynamic> fetchByIdResult;
  final Map<String, dynamic> deleteAllResult;
  final Map<String, dynamic> deleteByIdResult;

  FakeStatisticsService({
    required this.fetchByIdResult,
    this.deleteAllResult = const {'code': 200, 'message': 'deleted'},
    this.deleteByIdResult = const {'code': 200, 'message': 'deleted'},
  });

  @override
  Future<Map<String, dynamic>> fetchStatisticsById(String analysisId) async {
    return fetchByIdResult;
  }

  @override
  Future<Map<String, dynamic>> deleteAllStatistics() async {
    return deleteAllResult;
  }

  @override
  Future<Map<String, dynamic>> deleteStatisticsById(String analysisId) async {
    return deleteByIdResult;
  }
}

void main() {
  testWidgets('HistoryScreen renders main UI and default segmentation tab', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

    await tester.pumpAndSettle();

    expect(find.text('Farmlens History'), findsOneWidget);
    expect(find.text('Segmentation list'), findsOneWidget);
    expect(find.text('Change detection list'), findsOneWidget);
    expect(find.text('No segmentation history yet.'), findsOneWidget);
  });

  testWidgets('HistoryScreen switches to change detection tab', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Change detection list'));
    await tester.pumpAndSettle();

    expect(find.text('No change detection history yet.'), findsOneWidget);
  });

  testWidgets('HistoryScreen menu navigates to home', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HistoryScreen(),
        routes: {
          AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen')),
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('HistoryScreen menu navigates to profile', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HistoryScreen(),
        routes: {
          AppRoutes.profile: (_) =>
              const Scaffold(body: Text('Profile Screen')),
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Profile Screen'), findsOneWidget);
  });

  testWidgets('HistoryScreen loads segmentation history', (tester) async {
    final item = buildSegmentationFixture();

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(
          segmentationService: FakeSegmentationService(
            fetchResult: {
              'code': 200,
              'data': [item],
            },
          ),
          comparisonService: FakeComparisonService(
            fetchResult: const {'code': 200, 'data': []},
          ),
          statisticsService: FakeStatisticsService(
            fetchByIdResult: {'code': 200, 'data': buildStatsFixture()},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Farmlens History'), findsOneWidget);
    expect(find.text('Analysis 1'), findsOneWidget);
    expect(find.text('Date: 2026-06-01'), findsOneWidget);
  });

  testWidgets('HistoryScreen switches and shows change detection history', (
    tester,
  ) async {
    final comparison = buildComparisonFixture();

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(
          segmentationService: FakeSegmentationService(
            fetchResult: const {'code': 200, 'data': []},
          ),
          comparisonService: FakeComparisonService(
            fetchResult: {
              'code': 200,
              'data': [comparison],
            },
          ),
          statisticsService: FakeStatisticsService(
            fetchByIdResult: {'code': 200, 'data': buildStatsFixture()},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Change detection list'));
    await tester.pumpAndSettle();

    expect(find.text('Change detection 1'), findsOneWidget);
    expect(find.textContaining('Cloud cover:'), findsOneWidget);
  });

  testWidgets('HistoryScreen opens segmentation details sheet', (tester) async {
    final item = buildSegmentationFixture();

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(
          segmentationService: FakeSegmentationService(
            fetchResult: {
              'code': 200,
              'data': [item],
            },
          ),
          comparisonService: FakeComparisonService(
            fetchResult: const {'code': 200, 'data': []},
          ),
          statisticsService: FakeStatisticsService(
            fetchByIdResult: {'code': 200, 'data': buildStatsFixture()},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Analysis 1'));
    await tester.pumpAndSettle();

    expect(find.text('Segmentation details'), findsOneWidget);
    expect(find.text('seg-1'), findsOneWidget);
    expect(find.text('Land cover statistics'), findsOneWidget);
  });

  testWidgets('HistoryScreen opens comparison details sheet', (tester) async {
    final comparison = buildComparisonFixture();

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(
          segmentationService: FakeSegmentationService(
            fetchResult: const {'code': 200, 'data': []},
          ),
          comparisonService: FakeComparisonService(
            fetchResult: {
              'code': 200,
              'data': [comparison],
            },
          ),
          statisticsService: FakeStatisticsService(
            fetchByIdResult: {'code': 200, 'data': buildStatsFixture()},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Change detection list'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change detection 1'));
    await tester.pumpAndSettle();

    expect(find.text('Change detection details'), findsOneWidget);
    expect(find.text('cmp-1'), findsOneWidget);
  });
}
