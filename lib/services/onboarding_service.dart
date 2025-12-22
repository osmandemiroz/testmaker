import 'package:shared_preferences/shared_preferences.dart';

/// ********************************************************************
/// OnboardingService
/// ********************************************************************
///
/// Service responsible for managing onboarding state persistence.
/// Uses SharedPreferences to track whether the user has completed
/// the onboarding flow on first launch.
///
/// This ensures the onboarding experience is shown only once,
/// improving user experience by not repeatedly showing introductory
/// content on subsequent app launches.
///
class OnboardingService {
  /// SharedPreferences key for tracking onboarding completion status
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';

  /// [hasCompletedOnboarding]
  ///
  /// Checks if the user has completed the onboarding flow.
  /// Returns `true` if onboarding has been completed, `false` otherwise.
  /// Returns `false` by default for first-time users.
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  /// [markOnboardingComplete]
  ///
  /// Marks the onboarding flow as completed.
  /// This persists the state so onboarding won't be shown again
  /// on future app launches.
  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  /// [resetOnboarding]
  ///
  /// Resets the onboarding state (for testing purposes).
  /// This allows the onboarding flow to be shown again.
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasCompletedOnboardingKey);
  }
}
