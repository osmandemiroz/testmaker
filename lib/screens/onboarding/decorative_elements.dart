import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';
import 'package:testmaker/widgets/parallax_layer.dart';

/// ********************************************************************
/// DecorativeElements
/// ********************************************************************
///
/// Decorative background elements that add visual depth to onboarding
/// pages through parallax effects. These floating shapes create a
/// sense of depth and movement as users swipe between pages.
///
/// Following Apple's design principles, these elements are:
/// - Subtle and non-intrusive
/// - Complement the content without competing for attention
/// - Use soft colors and gentle animations
/// - Create visual interest through layering
///
class DecorativeElements extends StatelessWidget {
  const DecorativeElements({
    required this.pageOffset,
    required this.pageIndex,
    required this.primaryColor,
    super.key,
  });

  /// The current page offset from PageController
  final double pageOffset;

  /// The index of the page these elements belong to
  final int pageIndex;

  /// Primary color for the decorative elements
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    // Use responsive sizing for decorative elements
    final screenWidth = ResponsiveSizer.width(context);
    final screenHeight = ResponsiveSizer.height(context);
    
    // Scale circle sizes based on screen size
    final largeCircle = ResponsiveSizer.scaleWidth(context, 140);
    final mediumCircle = ResponsiveSizer.scaleWidth(context, 100);
    final smallCircle = ResponsiveSizer.scaleWidth(context, 80);

    // Reduced to 3 circles for better performance
    return Stack(
      children: <Widget>[
        // Background layer - slowest parallax
        RepaintBoundary(
          child: ParallaxLayer(
            pageOffset: pageOffset,
            currentPageIndex: pageIndex,
            parallaxSpeed: 0.3,
            child: _buildCircle(
              size: largeCircle,
              left: -screenWidth * 0.1,
              top: screenHeight * 0.12,
              color: primaryColor.withValues(alpha: 0.04),
            ),
          ),
        ),

        // Middle layer - medium parallax
        RepaintBoundary(
          child: ParallaxLayer(
            pageOffset: pageOffset,
            currentPageIndex: pageIndex,
            parallaxSpeed: 0.5,
            child: _buildCircle(
              size: mediumCircle,
              right: -screenWidth * 0.05,
              top: screenHeight * 0.22,
              color: primaryColor.withValues(alpha: 0.06),
            ),
          ),
        ),

        // Foreground layer - faster parallax
        RepaintBoundary(
          child: ParallaxLayer(
            pageOffset: pageOffset,
            currentPageIndex: pageIndex,
            parallaxSpeed: 0.8,
            child: _buildCircle(
              size: smallCircle,
              right: screenWidth * 0.08,
              bottom: screenHeight * 0.18,
              color: primaryColor.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  /// [_buildCircle]
  ///
  /// Builds a single decorative circle with optimized gradient.
  /// Uses absolute positioning to place circles around the screen.
  Widget _buildCircle({
    required double size,
    required Color color,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: IgnorePointer(
        // Prevents hit testing for better performance
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0),
              ],
              stops: const [0.3, 1.0], // Sharper gradient for less blur
            ),
          ),
        ),
      ),
    );
  }
}
