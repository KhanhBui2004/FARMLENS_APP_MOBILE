import 'package:farmlens_app/presentation/auth/login_screen.dart';
import 'package:farmlens_app/presentation/auth/register_screen.dart';
import 'package:farmlens_app/presentation/change_detection/change_detection_screen.dart';
import 'package:farmlens_app/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.changeDetection:
        return MaterialPageRoute(builder: (_) => const ChangeDetectionScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}