import 'package:flutter/material.dart';

/// ********************************************************************
/// OnboardingContent
/// ********************************************************************
///
/// Data model representing the content for each onboarding screen.
/// Contains the visual, textual, and styling information needed to
/// render a single onboarding page.
///
/// This model follows Apple's Human Interface Guidelines by keeping
/// content focused, concise, and visually appealing with progressive
/// disclosure of features across multiple screens.
///
class OnboardingContent {
  const OnboardingContent({
    required this.headline,
    required this.subheadline,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    this.secondaryIcon,
    this.isFinalScreen = false,
    this.imagePath,
    this.useImageInsteadOfIcon = false,
  });

  /// The main headline text displayed prominently at the top
  final String headline;

  /// Supporting text that provides additional context and details
  final String subheadline;

  /// The primary icon or visual element representing this feature
  final IconData icon;

  /// Optional secondary icon for compound visuals (e.g., arrow between icons)
  final IconData? secondaryIcon;

  /// Optional image path for using an image asset instead of icon
  final String? imagePath;

  /// Whether to use the image asset instead of the icon
  final bool useImageInsteadOfIcon;

  /// Background gradient colors for this screen
  final List<Color> gradientColors;

  /// Icon color (can vary per screen for visual interest)
  final Color iconColor;

  /// Whether this is the final screen (shows "Get Started" instead of "Next")
  final bool isFinalScreen;

  /// [getOnboardingPages]
  ///
  /// Returns the list of all onboarding content pages.
  /// These pages progressively introduce the user to TestMaker's
  /// AI-powered features following the plan's 4-screen flow.
  static List<OnboardingContent> getOnboardingPages(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return [
      // Screen 1: Welcome to TestMaker (uses app logo)
      OnboardingContent(
        headline: 'Welcome to TestMaker',
        subheadline:
            'Transform your PDFs into interactive quizzes and flashcards with AI',
        icon: Icons.school_rounded, // Fallback icon
        imagePath: 'assets/logo/app_logo.png',
        useImageInsteadOfIcon: true,
        gradientColors: isDark
            ? [
                const Color(0xFF1a1a2e),
                const Color(0xFF16213e),
              ]
            : [
                const Color(0xFFE3F2FD),
                const Color(0xFFBBDEFB),
              ],
        iconColor: primaryColor,
      ),

      // Screen 2: AI-Powered Quiz Generation
      OnboardingContent(
        headline: 'AI-Powered Quiz Generation',
        subheadline:
            'Upload any PDF and let Google Gemini AI automatically create quiz questions',
        icon: Icons.picture_as_pdf_rounded,
        secondaryIcon: Icons.quiz_rounded,
        gradientColors: isDark
            ? [
                const Color(0xFF0f3460),
                const Color(0xFF16213e),
              ]
            : [
                const Color(0xFFF3E5F5),
                const Color(0xFFE1BEE7),
              ],
        iconColor: const Color(0xFF9C27B0), // Purple for AI/tech feel
      ),

      // Screen 3: AI-Powered Flashcards
      OnboardingContent(
        headline: 'Smart Flashcard Creation',
        subheadline:
            'Automatically generate flashcards from your study materials with 3D flip animations',
        icon: Icons.style_rounded,
        gradientColors: isDark
            ? [
                const Color(0xFF1b4332),
                const Color(0xFF16213e),
              ]
            : [
                const Color(0xFFE8F5E9),
                const Color(0xFFC8E6C9),
              ],
        iconColor: const Color(0xFF4CAF50), // Green for growth/learning
      ),

      // Screen 4: Organize & Track Progress
      OnboardingContent(
        headline: 'Study Smarter, Not Harder',
        subheadline:
            'Organize content in courses, track your progress, and ace your exams',
        icon: Icons.analytics_rounded,
        gradientColors: isDark
            ? [
                const Color(0xFF16213e),
                const Color(0xFF1a1a2e),
              ]
            : [
                const Color(0xFFFFF3E0),
                const Color(0xFFFFE0B2),
              ],
        iconColor: const Color(0xFFFF9800), // Orange for achievement/success
        isFinalScreen: true,
      ),
    ];
  }
}
