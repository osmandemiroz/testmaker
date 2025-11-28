import 'package:flutter/material.dart';

import 'package:testmaker/screens/home_screen.dart';

/// ********************************************************************
/// main.dart
/// ********************************************************************
///
/// Root entry point of the TestMaker quiz application.
/// This file configures global app theming and sets up the initial
/// `HomeScreen` route. All quiz-specific logic is encapsulated in
/// dedicated models, services, and screens to keep responsibilities clear.
///
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
      ),
    );

    return MaterialApp(
      title: 'TestMaker',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: baseTheme.colorScheme.surface,
        appBarTheme: baseTheme.appBarTheme.copyWith(
          elevation: 0,
          centerTitle: true,
          backgroundColor: baseTheme.colorScheme.surface,
          foregroundColor: baseTheme.colorScheme.onSurface,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
