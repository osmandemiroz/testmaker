import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:testmaker/controllers/auth_controller.dart';
import 'package:testmaker/firebase_options.dart';
import 'package:testmaker/screens/auth/auth_screen.dart';
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
/// route based on:
/// 1. Whether the user has completed onboarding
/// 2. Whether the user is authenticated (via Firebase Auth)
///
/// App Flow:
/// - First launch: Onboarding → Auth → Home
/// - Returning user (not signed in): Auth → Home
/// - Returning user (signed in): Home
///
/// The theme follows iOS/iPhone design guidelines with:
/// - iOS system blue (#007AFF) as primary color
/// - iOS-style typography and spacing
/// - iOS-style navigation and controls
/// - iOS Material 3 adaptations
///

/// Main entry point - initializes Firebase before running the app
Future<void> main() async {
  // [main] Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // [main] Load environment variables from .env file
  // This must happen before Firebase initialization to load API keys
  await dotenv.load();

  // [main] Initialize Firebase with options from environment variables
  // API keys are securely stored in .env file (not in version control)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Track whether we've completed the initial checks
  bool _isInitialized = false;

  /// Whether the user has completed onboarding
  bool _hasCompletedOnboarding = false;

  /// Whether the user is authenticated
  bool _isAuthenticated = false;

  /// Auth controller for checking auth state
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    // [_MyAppState.initState]
    // Initialize auth controller and check onboarding/auth status on startup
    _authController = AuthController();
    _initializeApp();
  }

  /// [_initializeApp]
  ///
  /// Performs all initialization checks:
  /// 1. Checks onboarding completion status
  /// 2. Checks if user is already authenticated
  Future<void> _initializeApp() async {
    // Check onboarding status
    final hasCompleted = await OnboardingService.hasCompletedOnboarding();

    // Check authentication status (from AuthController which reads Firebase)
    final isAuthenticated = _authController.isAuthenticated;

    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = hasCompleted;
        _isAuthenticated = isAuthenticated;
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  /// [_getInitialScreen]
  ///
  /// Determines which screen to show based on:
  /// 1. Onboarding completion
  /// 2. Authentication status
  Widget _getInitialScreen() {
    // Not yet onboarded? Show onboarding
    if (!_hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // Onboarded but not authenticated? Show auth screen
    if (!_isAuthenticated) {
      return const AuthScreen();
    }

    // Authenticated? Show home screen
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TestMaker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Show splash/loading while initializing
      home: _isInitialized ? _getInitialScreen() : const _SplashScreen(),
    );
  }
}

/// ********************************************************************
/// _SplashScreen
/// ********************************************************************
///
/// Simple splash screen shown while checking onboarding and auth status.
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
