import 'package:flutter/material.dart';

/// ********************************************************************
/// ParallaxLayer
/// ********************************************************************
///
/// A reusable widget that creates parallax scrolling effects by
/// translating child widgets based on page scroll position.
///
/// Parallax creates depth perception by moving background elements
/// slower than foreground elements, creating a beautiful 3D-like
/// effect that aligns with Apple's design philosophy of delightful,
/// physics-based animations.
///
/// Usage:
/// ```dart
/// ParallaxLayer(
///   pageOffset: _pageController.page ?? 0.0,
///   currentPageIndex: 0,
///   parallaxSpeed: 0.5, // Background moves at 50% speed
///   child: MyWidget(),
/// )
/// ```
///
class ParallaxLayer extends StatelessWidget {
  const ParallaxLayer({
    required this.pageOffset,
    required this.currentPageIndex,
    required this.child,
    super.key,
    this.parallaxSpeed = 1.0,
    this.verticalOffset = 0.0,
    this.enableFade = false,
  });

  /// The current scroll offset from the PageController
  /// (e.g., 0.0 = page 0, 0.5 = halfway between page 0 and 1, 1.0 = page 1)
  final double pageOffset;

  /// The index of the page this layer belongs to
  final int currentPageIndex;

  /// Speed multiplier for the parallax effect
  /// - 0.0 = no movement (static background)
  /// - 0.5 = moves at half speed (slow background)
  /// - 1.0 = moves at normal speed (standard scroll)
  /// - 1.5 = moves faster than scroll (foreground emphasis)
  final double parallaxSpeed;

  /// The child widget to apply parallax effect to
  final Widget child;

  /// Optional vertical offset for layering elements
  final double verticalOffset;

  /// Optional opacity fade based on scroll position
  final bool enableFade;

  @override
  Widget build(BuildContext context) {
    // Calculate the offset relative to this page's position
    // When pageOffset equals currentPageIndex, the page is centered
    final pageOffsetFromCenter = pageOffset - currentPageIndex;

    // Calculate horizontal translation based on parallax speed
    // Multiply by screen width to get pixel offset
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalOffset =
        -pageOffsetFromCenter * screenWidth * parallaxSpeed;

    // Calculate opacity if fade is enabled
    // Fade out as the page moves away from center
    var opacity = 1.0;
    if (enableFade) {
      // Full opacity when centered, fade out as we move away
      opacity = (1.0 - pageOffsetFromCenter.abs()).clamp(0.0, 1.0);
    }

    return Transform.translate(
      offset: Offset(horizontalOffset, verticalOffset),
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }
}

/// ********************************************************************
/// ParallaxScaleLayer
/// ********************************************************************
///
/// A variant of ParallaxLayer that adds scale animation in addition
/// to translation. Useful for creating zoom effects as pages scroll.
///
/// This creates a more dynamic feel where elements grow or shrink
/// during transitions, following iOS's emphasis on fluid motion.
///
class ParallaxScaleLayer extends StatelessWidget {
  const ParallaxScaleLayer({
    required this.pageOffset,
    required this.currentPageIndex,
    required this.child,
    super.key,
    this.parallaxSpeed = 1.0,
    this.scaleSpeed = 0.2,
    this.verticalOffset = 0.0,
  });

  /// The current scroll offset from the PageController
  final double pageOffset;

  /// The index of the page this layer belongs to
  final int currentPageIndex;

  /// Speed multiplier for the parallax effect
  final double parallaxSpeed;

  /// Scale multiplier (1.0 = no scale, 1.2 = grows 20%)
  final double scaleSpeed;

  /// The child widget to apply parallax effect to
  final Widget child;

  /// Optional vertical offset for layering elements
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    // Calculate the offset relative to this page's position
    final pageOffsetFromCenter = pageOffset - currentPageIndex;

    // Calculate horizontal translation
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalOffset =
        -pageOffsetFromCenter * screenWidth * parallaxSpeed;

    // Calculate scale based on distance from center
    // Scale down as page moves away, scale up when centered
    final scale = 1.0 + (scaleSpeed * (1.0 - pageOffsetFromCenter.abs()));

    return Transform.translate(
      offset: Offset(horizontalOffset, verticalOffset),
      child: Transform.scale(
        scale: scale.clamp(0.5, 1.5), // Prevent extreme scaling
        child: child,
      ),
    );
  }
}
