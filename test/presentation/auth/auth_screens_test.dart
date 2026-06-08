import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/presentation/auth/login_screen.dart';
import 'package:farmlens_app/presentation/auth/register_screen.dart';
import 'package:farmlens_app/presentation/auth/welcome_screen.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthService extends AuthService {
  final Map<String, dynamic> loginResult;
  final Map<String, dynamic> registerResult;

  FakeAuthService({
    this.loginResult = const {'code': 200},
    this.registerResult = const {'code': 200},
  });

  @override
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    return loginResult;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    return registerResult;
  }
}

void main() {
  testWidgets('WelcomeScreen renders primary call to actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WelcomeScreen())),
    );

    expect(find.text('Farmlens'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('LoginScreen renders login form labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoginScreen())),
    );

    expect(find.text('Login Here'), findsOneWidget);
    expect(
      find.text('Welcome back! Please login to your account.'),
      findsOneWidget,
    );
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation errors when empty', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Username or email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('LoginScreen submits successfully and navigates home', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen')),
        },
        home: LoginScreen(
          authService: FakeAuthService(loginResult: const {'code': 200}),
        ),
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'u1');
    await tester.enterText(fields.at(1), '123456');

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('RegisterScreen renders registration form labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegisterScreen())),
    );

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('RegisterScreen shows validation errors when empty', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    await tester.ensureVisible(find.text('Register'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });

  testWidgets('RegisterScreen shows password mismatch error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'User One');
    await tester.enterText(fields.at(1), 'u1@example.com');
    await tester.enterText(fields.at(2), 'u1');
    await tester.enterText(fields.at(3), '123456');
    await tester.enterText(fields.at(4), 'abcdef');

    await tester.ensureVisible(find.text('Register'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('RegisterScreen submits successfully and navigates login', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.login: (_) => const Scaffold(body: Text('Login Screen')),
        },
        home: RegisterScreen(
          authService: FakeAuthService(registerResult: const {'code': 200}),
        ),
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'User One');
    await tester.enterText(fields.at(1), 'u1@example.com');
    await tester.enterText(fields.at(2), 'u1');
    await tester.enterText(fields.at(3), '123456');
    await tester.enterText(fields.at(4), '123456');

    await tester.ensureVisible(find.text('Register'));
    await tester.pump();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}
