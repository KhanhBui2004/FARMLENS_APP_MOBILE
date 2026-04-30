import 'package:farmlens_app/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmLens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F8E5A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8F4),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
