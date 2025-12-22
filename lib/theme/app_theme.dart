import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ********************************************************************
/// app_theme.dart
/// ********************************************************************
///
/// Centralized theme configuration for the TestMaker application.
/// This file defines the light and dark [ThemeData] used across the app
/// so that colors, typography, and component styling are managed from a
/// single, well‑documented location.
///
/// The design intentionally follows Apple's Human Interface Guidelines:
/// - iOS system blue as the primary accent color
/// - SF Pro / system fonts via Material's iOS typography configuration
/// - High contrast, subtle depth, and soft rounded corners
/// - Minimal, content‑first, modern iOS visual language
///
/// If you need to tweak global visuals (colors, typography, buttons,
/// inputs, dialogs, etc.), this is the place to do it.
class AppTheme {
  /// Builds the light theme for iOS‑style appearance.
  static ThemeData light() {
    // iOS system blue color
    const iosBlue = Color(0xFF007AFF);
    const iosSystemGray = Color(0xFF8E8E93);
    const iosSystemGray2 = Color(0xFFAEAEB2);
    const iosSystemGray4 = Color(0xFFD1D1D6);
    const iosSystemGray5 = Color(0xFFE5E5EA);
    const iosSystemGray6 = Color(0xFFF2F2F7);
    const iosLabel = Color(0xFF000000);
    const iosSecondaryLabel = Color(0xFF3C3C43);

    // Create iOS-inspired color scheme
    final colorScheme = ColorScheme.light(
      primary: iosBlue,
      primaryContainer: iosBlue.withValues(alpha: 0.1),
      onPrimaryContainer: iosBlue,
      secondary: iosSystemGray,
      onSecondary: Colors.white,
      secondaryContainer: iosSystemGray5,
      onSecondaryContainer: iosLabel,
      tertiary: iosSystemGray2,
      onTertiary: Colors.white,
      error: const Color(0xFFFF3B30), // iOS red
      errorContainer: const Color(0xFFFF3B30).withValues(alpha: 0.1),
      onErrorContainer: const Color(0xFFFF3B30),
      surfaceContainerHighest: iosSystemGray6,
      surfaceContainerHigh: iosSystemGray5,
      surfaceContainer: Colors.white,
      surfaceContainerLow: iosSystemGray6,
      surfaceContainerLowest: iosSystemGray6,
      onSurfaceVariant: iosSecondaryLabel,
      outline: iosSystemGray4,
      outlineVariant: iosSystemGray5,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Colors.black,
      onInverseSurface: Colors.white,
      inversePrimary: iosBlue.withValues(alpha: 0.2),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: iosSystemGray6,
      // Use system font which will be SF Pro on iOS
      typography: Typography.material2021(
        platform: TargetPlatform.iOS,
      ),
      // iOS-style AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: iosLabel,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: iosLabel,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        iconTheme: IconThemeData(
          color: iosBlue,
          size: 24,
        ),
      ),
      // iOS-style Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.zero,
      ),
      // iOS-style Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: iosBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: iosBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: iosBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: iosSystemGray4, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: iosBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
        ),
      ),
      // iOS-style Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: iosSystemGray6,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: iosBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      // iOS-style Dividers
      dividerTheme: const DividerThemeData(
        color: iosSystemGray4,
        thickness: 0.5,
        space: 1,
      ),
      // iOS-style Dialogs
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: const TextStyle(
          color: iosLabel,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        contentTextStyle: const TextStyle(
          color: iosSecondaryLabel,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
      ),
      // iOS-style Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.37,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
        ),
        displaySmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.38,
        ),
        headlineSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.38,
        ),
        titleSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.24,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
        labelMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.24,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
      ),
    );

    return baseTheme;
  }

  /// Builds the dark theme for iOS‑style appearance.
  static ThemeData dark() {
    // iOS dark mode colors
    const iosBlue = Color(0xFF0A84FF); // Slightly brighter blue in dark mode
    const iosSystemGray = Color(0xFF8E8E93);
    const iosSystemGray2 = Color(0xFF636366);
    const iosSystemGray3 = Color(0xFF48484A);
    const iosSystemGray4 = Color(0xFF3A3A3C);
    const iosSystemGray5 = Color(0xFF3A3A3C);
    const iosSystemGray6 = Color(0xFF1C1C1E);
    const iosLabel = Color(0xFFFFFFFF);
    const iosSecondaryLabel = Color(0xFFEBEBF5);

    // Create iOS dark mode color scheme
    final colorScheme = ColorScheme.dark(
      primary: iosBlue,
      onPrimary: Colors.white,
      primaryContainer: iosBlue.withValues(alpha: 0.2),
      onPrimaryContainer: iosBlue,
      secondary: iosSystemGray,
      onSecondary: Colors.white,
      secondaryContainer: iosSystemGray5,
      onSecondaryContainer: iosLabel,
      tertiary: iosSystemGray2,
      onTertiary: Colors.white,
      error: const Color(0xFFFF453A), // iOS red for dark mode
      onError: Colors.white,
      errorContainer: const Color(0xFFFF453A).withValues(alpha: 0.2),
      onErrorContainer: const Color(0xFFFF453A),
      surface: iosSystemGray5,
      surfaceContainerHighest: iosSystemGray5,
      surfaceContainerHigh: iosSystemGray4,
      surfaceContainer: iosSystemGray5,
      surfaceContainerLow: iosSystemGray6,
      surfaceContainerLowest: iosSystemGray6,
      onSurfaceVariant: iosSecondaryLabel,
      outline: iosSystemGray4,
      outlineVariant: iosSystemGray3,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: iosBlue.withValues(alpha: 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: iosSystemGray6,
      typography: Typography.material2021(
        platform: TargetPlatform.iOS,
      ),
      // iOS-style AppBar (dark)
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: iosSystemGray5,
        foregroundColor: iosLabel,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: iosLabel,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        iconTheme: IconThemeData(
          color: iosBlue,
          size: 24,
        ),
      ),
      // iOS-style Card (dark)
      cardTheme: CardThemeData(
        elevation: 0,
        color: iosSystemGray5,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.zero,
      ),
      // iOS-style Buttons (dark)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: iosBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: iosBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: iosBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: iosSystemGray4, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: iosBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
        ),
      ),
      // iOS-style Input Fields (dark)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: iosSystemGray5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: iosBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF453A), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      // iOS-style Dividers (dark)
      dividerTheme: const DividerThemeData(
        color: iosSystemGray4,
        thickness: 0.5,
        space: 1,
      ),
      // iOS-style Dialogs (dark)
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: iosSystemGray5,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: const TextStyle(
          color: iosLabel,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        contentTextStyle: const TextStyle(
          color: iosSecondaryLabel,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
      ),
      // iOS-style Typography (same for dark mode)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.37,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
        ),
        displaySmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.38,
        ),
        headlineSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.38,
        ),
        titleSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.24,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
        labelMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.24,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}
