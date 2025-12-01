import 'package:flutter/material.dart';

/// ********************************************************************
/// ResponsiveSizer
/// ********************************************************************
///
/// A comprehensive responsive sizing utility that provides consistent
/// dimensions across all screen sizes following Apple's Human Interface
/// Guidelines.
///
/// This utility class:
///  - Defines breakpoints for mobile, tablet, and desktop
///  - Provides responsive width, height, padding, and spacing values
///  - Scales text sizes appropriately for different screen sizes
///  - Maintains consistent design proportions across devices
///
/// Breakpoints:
///  - Mobile: < 600px width
///  - Tablet: 600px - 1024px width
///  - Desktop: > 1024px width
///
class ResponsiveSizer {
  /// Private constructor to prevent instantiation.
  ResponsiveSizer._();

  /// Mobile breakpoint (below this is considered mobile).
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint (between mobile and desktop).
  static const double tabletBreakpoint = 1024;

  /// Base width for scaling calculations (iPhone 14 Pro width).
  static const double baseWidth = 393;

  /// Base height for scaling calculations (iPhone 14 Pro height).
  static const double baseHeight = 852;

  /// Gets the current screen width from the context.
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Gets the current screen height from the context.
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Gets the current screen width from BoxConstraints.
  static double widthFromConstraints(BoxConstraints constraints) {
    return constraints.maxWidth;
  }

  /// Gets the current screen height from BoxConstraints.
  static double heightFromConstraints(BoxConstraints constraints) {
    return constraints.maxHeight;
  }

  /// Determines if the current screen is mobile-sized.
  static bool isMobile(BuildContext context) {
    return width(context) < mobileBreakpoint;
  }

  /// Determines if the current screen is mobile-sized from constraints.
  static bool isMobileFromConstraints(BoxConstraints constraints) {
    return constraints.maxWidth < mobileBreakpoint;
  }

  /// Determines if the current screen is tablet-sized.
  static bool isTablet(BuildContext context) {
    final w = width(context);
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  /// Determines if the current screen is tablet-sized from constraints.
  static bool isTabletFromConstraints(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  /// Determines if the current screen is desktop-sized.
  static bool isDesktop(BuildContext context) {
    return width(context) >= tabletBreakpoint;
  }

  /// Determines if the current screen is desktop-sized from constraints.
  static bool isDesktopFromConstraints(BoxConstraints constraints) {
    return constraints.maxWidth >= tabletBreakpoint;
  }

  /// Determines if the current screen is compact (mobile or small tablet).
  static bool isCompact(BuildContext context) {
    return width(context) < mobileBreakpoint;
  }

  /// Determines if the current screen is compact from constraints.
  static bool isCompactFromConstraints(BoxConstraints constraints) {
    return constraints.maxWidth < mobileBreakpoint;
  }

  /// Gets responsive width as a percentage of screen width.
  ///
  /// [percentage] should be between 0.0 and 1.0 (e.g., 0.5 for 50%).
  static double w(BuildContext context, double percentage) {
    return width(context) * percentage;
  }

  /// Gets responsive width as a percentage from constraints.
  static double wFromConstraints(
    BoxConstraints constraints,
    double percentage,
  ) {
    return constraints.maxWidth * percentage;
  }

  /// Gets responsive height as a percentage of screen height.
  ///
  /// [percentage] should be between 0.0 and 1.0 (e.g., 0.5 for 50%).
  static double h(BuildContext context, double percentage) {
    return height(context) * percentage;
  }

  /// Gets responsive height as a percentage from constraints.
  static double hFromConstraints(
    BoxConstraints constraints,
    double percentage,
  ) {
    return constraints.maxHeight * percentage;
  }

  /// Gets responsive horizontal padding based on screen size.
  ///
  /// Mobile: 16-24px
  /// Tablet: 24-32px
  /// Desktop: 32-40px
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 24;
    } else {
      return 32;
    }
  }

  /// Gets responsive horizontal padding from constraints.
  static double horizontalPaddingFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return 16;
    } else if (isTabletFromConstraints(constraints)) {
      return 24;
    } else {
      return 32;
    }
  }

  /// Gets responsive vertical padding based on screen size.
  ///
  /// Mobile: 16-20px
  /// Tablet: 20-24px
  /// Desktop: 24-32px
  static double verticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 20;
    } else {
      return 24;
    }
  }

  /// Gets responsive vertical padding from constraints.
  static double verticalPaddingFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return 16;
    } else if (isTabletFromConstraints(constraints)) {
      return 20;
    } else {
      return 24;
    }
  }

  /// Gets responsive padding (symmetric) based on screen size.
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: verticalPadding(context),
    );
  }

  /// Gets responsive padding from constraints.
  static EdgeInsets paddingFromConstraints(BoxConstraints constraints) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPaddingFromConstraints(constraints),
      vertical: verticalPaddingFromConstraints(constraints),
    );
  }

  /// Gets responsive spacing between elements.
  ///
  /// Mobile: 8-12px
  /// Tablet: 12-16px
  /// Desktop: 16-20px
  static double spacing(BuildContext context, {double multiplier = 1.0}) {
    double baseSpacing;
    if (isMobile(context)) {
      baseSpacing = 8.0;
    } else if (isTablet(context)) {
      baseSpacing = 12.0;
    } else {
      baseSpacing = 16.0;
    }
    return baseSpacing * multiplier;
  }

  /// Gets responsive spacing from constraints.
  static double spacingFromConstraints(
    BoxConstraints constraints, {
    double multiplier = 1.0,
  }) {
    double baseSpacing;
    if (isMobileFromConstraints(constraints)) {
      baseSpacing = 8.0;
    } else if (isTabletFromConstraints(constraints)) {
      baseSpacing = 12.0;
    } else {
      baseSpacing = 16.0;
    }
    return baseSpacing * multiplier;
  }

  /// Gets responsive font size multiplier.
  ///
  /// Mobile: 1.0x (base size)
  /// Tablet: 1.1x
  /// Desktop: 1.2x
  static double fontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Gets responsive font size multiplier from constraints.
  static double fontSizeMultiplierFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return 1;
    } else if (isTabletFromConstraints(constraints)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Gets responsive border radius.
  ///
  /// Mobile: 12-16px
  /// Tablet: 16-20px
  /// Desktop: 20-24px
  static double borderRadius(BuildContext context, {double multiplier = 1.0}) {
    double baseRadius;
    if (isMobile(context)) {
      baseRadius = 12.0;
    } else if (isTablet(context)) {
      baseRadius = 16.0;
    } else {
      baseRadius = 20.0;
    }
    return baseRadius * multiplier;
  }

  /// Gets responsive border radius from constraints.
  static double borderRadiusFromConstraints(
    BoxConstraints constraints, {
    double multiplier = 1.0,
  }) {
    double baseRadius;
    if (isMobileFromConstraints(constraints)) {
      baseRadius = 12.0;
    } else if (isTabletFromConstraints(constraints)) {
      baseRadius = 16.0;
    } else {
      baseRadius = 20.0;
    }
    return baseRadius * multiplier;
  }

  /// Gets responsive icon size.
  ///
  /// Mobile: 20-24px
  /// Tablet: 24-28px
  /// Desktop: 28-32px
  static double iconSize(BuildContext context, {double multiplier = 1.0}) {
    double baseSize;
    if (isMobile(context)) {
      baseSize = 20.0;
    } else if (isTablet(context)) {
      baseSize = 24.0;
    } else {
      baseSize = 28.0;
    }
    return baseSize * multiplier;
  }

  /// Gets responsive icon size from constraints.
  static double iconSizeFromConstraints(
    BoxConstraints constraints, {
    double multiplier = 1.0,
  }) {
    double baseSize;
    if (isMobileFromConstraints(constraints)) {
      baseSize = 20.0;
    } else if (isTabletFromConstraints(constraints)) {
      baseSize = 24.0;
    } else {
      baseSize = 28.0;
    }
    return baseSize * multiplier;
  }

  /// Gets responsive button height.
  ///
  /// Mobile: 44-48px
  /// Tablet: 48-52px
  /// Desktop: 52-56px
  static double buttonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 44;
    } else if (isTablet(context)) {
      return 48;
    } else {
      return 52;
    }
  }

  /// Gets responsive button height from constraints.
  static double buttonHeightFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return 44;
    } else if (isTabletFromConstraints(constraints)) {
      return 48;
    } else {
      return 52;
    }
  }

  /// Gets responsive card padding.
  ///
  /// Mobile: 16-18px
  /// Tablet: 20-22px
  /// Desktop: 24-26px
  static double cardPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 20;
    } else {
      return 24;
    }
  }

  /// Gets responsive card padding from constraints.
  static double cardPaddingFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return 16;
    } else if (isTabletFromConstraints(constraints)) {
      return 20;
    } else {
      return 24;
    }
  }

  /// Gets responsive sidebar width.
  ///
  /// Mobile: 280px (drawer)
  /// Tablet: 25% of screen width (clamped 240-280px)
  /// Desktop: 25% of screen width (clamped 280-320px)
  static double sidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return 280;
    } else if (isTablet(context)) {
      return (width(context) * 0.25).clamp(240.0, 280.0);
    } else {
      return (width(context) * 0.25).clamp(280.0, 320.0);
    }
  }

  /// Gets responsive sidebar width from constraints.
  static double sidebarWidthFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return 280;
    } else if (isTabletFromConstraints(constraints)) {
      return (constraints.maxWidth * 0.25).clamp(240.0, 280.0);
    } else {
      return (constraints.maxWidth * 0.25).clamp(280.0, 320.0);
    }
  }

  /// Gets responsive max content width.
  ///
  /// Mobile: Full width
  /// Tablet: 700px
  /// Desktop: 800px
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 700;
    } else {
      return 800;
    }
  }

  /// Gets responsive max content width from constraints.
  static double maxContentWidthFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return double.infinity;
    } else if (isTabletFromConstraints(constraints)) {
      return 700;
    } else {
      return 800;
    }
  }

  /// Gets responsive dialog max width.
  ///
  /// Mobile: 90% of screen width (max 400px)
  /// Tablet: 400px
  /// Desktop: 450px
  static double dialogMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return (width(context) * 0.9).clamp(300.0, 400.0);
    } else if (isTablet(context)) {
      return 400;
    } else {
      return 450;
    }
  }

  /// Gets responsive dialog max width from constraints.
  static double dialogMaxWidthFromConstraints(BoxConstraints constraints) {
    if (isMobileFromConstraints(constraints)) {
      return (constraints.maxWidth * 0.9).clamp(300.0, 400.0);
    } else if (isTabletFromConstraints(constraints)) {
      return 400;
    } else {
      return 450;
    }
  }

  /// Scales a value based on screen width.
  ///
  /// Uses the base width (393px) as reference for scaling.
  static double scaleWidth(BuildContext context, double value) {
    final screenWidth = width(context);
    return (value * screenWidth) / baseWidth;
  }

  /// Scales a value based on screen width from constraints.
  static double scaleWidthFromConstraints(
    BoxConstraints constraints,
    double value,
  ) {
    final screenWidth = constraints.maxWidth;
    return (value * screenWidth) / baseWidth;
  }

  /// Scales a value based on screen height.
  ///
  /// Uses the base height (852px) as reference for scaling.
  static double scaleHeight(BuildContext context, double value) {
    final screenHeight = height(context);
    return (value * screenHeight) / baseHeight;
  }

  /// Scales a value based on screen height from constraints.
  static double scaleHeightFromConstraints(
    BoxConstraints constraints,
    double value,
  ) {
    final screenHeight = constraints.maxHeight;
    return (value * screenHeight) / baseHeight;
  }
}
