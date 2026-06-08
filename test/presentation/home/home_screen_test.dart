import 'package:farmlens_app/presentation/home/home_screen.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen renders main sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          AppRoutes.login: (_) => const Scaffold(body: Text('Login Screen')),
          AppRoutes.history: (_) =>
              const Scaffold(body: Text('History Screen')),
          AppRoutes.profile: (_) =>
              const Scaffold(body: Text('Profile Screen')),
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('FarmLens Dashboard'), findsOneWidget);
    expect(find.text('Operational overview'), findsOneWidget);
    expect(find.text('Satellite map and analysis area'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Select Time'), findsOneWidget);
    expect(find.text('Time Comparison'), findsOneWidget);
    expect(find.text('Run Analysis'), findsOneWidget);
    expect(find.text('Change Detection'), findsOneWidget);
  });

  testWidgets(
    'HomeScreen shows warning when running analysis without location',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Run Analysis'));
      await tester.tap(find.text('Run Analysis'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a location on the map.'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows error when change detection runs without location',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Change Detection'));
      await tester.tap(find.text('Change Detection'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a location on the map.'), findsOneWidget);
    },
  );

  testWidgets('HomeScreen menu navigates to profile', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
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

  testWidgets('HomeScreen menu navigates to history', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          AppRoutes.history: (_) =>
              const Scaffold(body: Text('History Screen')),
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(find.text('History Screen'), findsOneWidget);
  });
}
