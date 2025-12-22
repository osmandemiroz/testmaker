import 'package:flutter/material.dart';

import 'package:testmaker/screens/home_screen.dart';
import 'package:testmaker/theme/app_theme.dart';

/// ********************************************************************
/// main.dart
/// ********************************************************************
///
/// Root entry point of the TestMaker quiz application.
/// This file configures global app theming and sets up the initial
/// `HomeScreen` route. All quiz-specific logic is encapsulated in
/// dedicated models, services, and screens to keep responsibilities clear.
///
/// The theme follows iOS/iPhone design guidelines with:
/// - iOS system blue (#007AFF) as primary color
/// - iOS-style typography and spacing
/// - iOS-style navigation and controls
/// - iOS Material 3 adaptations
///
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TestMaker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
