import 'package:go_router/go_router.dart';
import 'package:testmaker/controllers/auth_controller.dart';
import 'package:testmaker/screens/auth/auth_screen.dart';
import 'package:testmaker/screens/home_screen.dart';
import 'package:testmaker/screens/onboarding/onboarding_screen.dart';
import 'package:testmaker/services/onboarding_service.dart';

/// Routes for the application.
class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';
  static const String share = '/share/:id';
}

/// Global router for the application.
class AppRouter {
  AppRouter({
    required AuthController authController,
  }) : _authController = authController;

  final AuthController _authController;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _authController,
    redirect: (context, state) async {
      // Handle custom URI scheme redirection
      final fullPath = state.uri.toString();
      if (fullPath.startsWith('testmaker://share/')) {
        final id = fullPath.replaceFirst('testmaker://share/', '');
        return '/share/$id';
      }

      final hasCompletedOnboarding =
          await OnboardingService.hasCompletedOnboarding();
      if (!hasCompletedOnboarding &&
          state.matchedLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      if (hasCompletedOnboarding && !_authController.isAuthenticated) {
        if (state.matchedLocation != AppRoutes.auth) {
          return AppRoutes.auth;
        }
      }

      if (_authController.isAuthenticated &&
          state.matchedLocation == AppRoutes.auth) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.share,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return HomeScreen(sharedContentId: id);
        },
      ),
    ],
  );
}
