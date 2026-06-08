import 'package:farmlens_app/utils/router/app_router.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp(String initialRoute) {
    return MaterialApp(
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  testWidgets('routes welcome screen for root route', (tester) async {
    await tester.pumpWidget(buildApp(AppRoutes.welcome));
    await tester.pumpAndSettle();

    expect(find.text('Farmlens'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('routes login screen for login route', (tester) async {
    await tester.pumpWidget(buildApp(AppRoutes.login));
    await tester.pumpAndSettle();

    expect(find.text('Login Here'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('routes register screen for register route', (tester) async {
    await tester.pumpWidget(buildApp(AppRoutes.register));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('routes profile screen for profile route', (tester) async {
    await tester.pumpWidget(buildApp(AppRoutes.profile));
    await tester.pumpAndSettle();

    expect(find.text('Profile Settings'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  test('generateRoute returns MaterialPageRoute for known routes', () {
    final routes = [
      AppRoutes.welcome,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.home,
      AppRoutes.history,
      AppRoutes.profile,
    ];

    for (final routeName in routes) {
      final route = AppRouter.generateRoute(RouteSettings(name: routeName));
      expect(route, isA<MaterialPageRoute>());
    }
  });

  testWidgets('shows fallback text for unknown route', (tester) async {
    await tester.pumpWidget(buildApp('/unknown-route'));
    await tester.pumpAndSettle();

    expect(find.text('No route defined for /unknown-route'), findsOneWidget);
  });

  test('AppRouter has navigator key', () {
    expect(AppRouter.navigatorKey, isA<GlobalKey<NavigatorState>>());
  });

  testWidgets('routes history screen for history route', (tester) async {
    await tester.pumpWidget(buildApp(AppRoutes.history));
    await tester.pumpAndSettle();

    expect(find.text('Farmlens History'), findsOneWidget);
    expect(find.text('Segmentation list'), findsOneWidget);
    expect(find.text('Change detection list'), findsOneWidget);
  });
}
