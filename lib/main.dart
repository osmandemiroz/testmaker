import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:testmaker/controllers/auth_controller.dart';
import 'package:testmaker/firebase_options.dart';
import 'package:testmaker/utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load();
  } on Exception catch (e) {
    if (kDebugMode) {
      print('Warning: Could not load .env file: $e');
    }
  }

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthController _authController;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _appRouter = AppRouter(authController: _authController);
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TestMaker',
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // iOS Blue
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: '.SF Pro Display', // Use system font if possible
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84FF), // iOS Light Blue (for Dark Mode)
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1C1E), // iOS Secondary System Background
        ),
        useMaterial3: true,
        fontFamily: '.SF Pro Display',
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          color: const Color(0xFF2C2C2E), // iOS Tertiary System Background
        ),
      ),
    );
  }
}
