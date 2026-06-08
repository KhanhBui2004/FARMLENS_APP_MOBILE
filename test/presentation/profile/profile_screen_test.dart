import 'dart:convert';

import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:farmlens_app/data/models/auth/user_model.dart';
import 'package:farmlens_app/presentation/profile/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads user data into form fields', (tester) async {
    final user = User(
      id: '1',
      username: 'u1',
      email: 'u1@example.com',
      fullName: 'User One',
    );

    SharedPreferences.setMockInitialValues({'user': jsonEncode(user.toJson())});

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Profile Settings'), findsOneWidget);

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    expect(fields.length, greaterThanOrEqualTo(5));

    expect(fields[0].controller?.text, 'User One');
    expect(fields[1].controller?.text, 'u1');
    expect(fields[2].controller?.text, 'u1@example.com');
  });

  testWidgets('shows validation errors when required fields empty', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    // Tap the Save Changes button
    expect(find.text('Save Changes'), findsOneWidget);
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('shows password mismatch error', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'User One');
    await tester.enterText(fields.at(1), 'u1');
    await tester.enterText(fields.at(2), 'u1@example.com');
    await tester.enterText(fields.at(3), '123456');
    await tester.enterText(fields.at(4), 'abcdef');

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('valid form saves without validation errors', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'User One');
    await tester.enterText(fields.at(1), 'u1');
    await tester.enterText(fields.at(2), 'u1@example.com');
    await tester.enterText(fields.at(3), '123456');
    await tester.enterText(fields.at(4), '123456');

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is required'), findsNothing);
    expect(find.text('Username is required'), findsNothing);
    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Passwords do not match'), findsNothing);
  });

  testWidgets('handles invalid stored user json safely', (tester) async {
    SharedPreferences.setMockInitialValues({'user': '{invalid-json'});

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Profile Settings'), findsOneWidget);

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    expect(fields[0].controller?.text, '');
    expect(fields[1].controller?.text, '');
    expect(fields[2].controller?.text, '');
  });

  testWidgets('ProfileScreen menu navigates to home', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
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

  testWidgets('ProfileScreen menu navigates to history', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
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
