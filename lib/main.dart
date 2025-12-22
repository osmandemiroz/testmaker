import 'package:flutter/material.dart';

import 'package:testmaker/screens/home_screen.dart';
import 'package:testmaker/screens/onboarding/onboarding_screen.dart';
import 'package:testmaker/services/onboarding_service.dart';
import 'package:testmaker/theme/app_theme.dart';

/// ********************************************************************
/// main.dart
/// ********************************************************************
///
/// Root entry point of the TestMaker quiz application.
/// This file configures global app theming and sets up the initial
/// route based on whether the user has completed onboarding.
///
/// On first launch, the app shows a beautiful onboarding flow that
/// introduces users to TestMaker's AI-powered features with parallax
/// animations and Apple-inspired design.
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Track whether we've completed the initial onboarding check
  bool _isInitialized = false;

  /// Whether the user has completed onboarding
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    // [_MyAppState.initState]
    // Check onboarding status on app startup
    _checkOnboardingStatus();
  }

  /// [_checkOnboardingStatus]
  ///
  /// Checks if the user has completed onboarding and updates state.
  /// This determines whether to show the onboarding flow or home screen.
  Future<void> _checkOnboardingStatus() async {
    final hasCompleted = await OnboardingService.hasCompletedOnboarding();
    setState(() {
      _hasCompletedOnboarding = hasCompleted;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TestMaker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Show splash/loading while checking onboarding status
      home: _isInitialized
          ? (_hasCompletedOnboarding
              ? const HomeScreen()
              : const OnboardingScreen())
          : const _SplashScreen(),
    );
  }
}

/// ********************************************************************
/// _SplashScreen
/// ********************************************************************
///
/// Simple splash screen shown while checking onboarding status.
/// Displays the app name with a minimal design matching the theme.
///
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.school_rounded,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'TestMaker',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
