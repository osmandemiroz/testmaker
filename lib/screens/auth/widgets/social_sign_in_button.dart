import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// social_sign_in_button.dart
/// ********************************************************************
///
/// A beautiful, Apple HIG-compliant social sign-in button widget.
/// Used for Google and Apple sign-in options with consistent styling.
///
/// Features:
/// - iOS-style rounded corners and subtle shadows
/// - Smooth press animation
/// - Loading state with spinner
/// - Platform-appropriate styling
/// - Official Google and Apple SVG icons
///

/// Type of social sign-in provider
enum SocialSignInProvider {
  /// Google sign-in
  google,

  /// Apple sign-in
  apple,
}

/// ********************************************************************
/// SocialSignInButton
/// ********************************************************************
///
/// A styled button for social authentication providers.
/// Follows Apple Human Interface Guidelines with:
/// - 10px border radius (iOS standard)
/// - Subtle shadow for depth
/// - Provider-specific colors and icons
/// - Loading state indicator
///
class SocialSignInButton extends StatefulWidget {
  const SocialSignInButton({
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// The social sign-in provider
  final SocialSignInProvider provider;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state
  final bool isLoading;

  @override
  State<SocialSignInButton> createState() => _SocialSignInButtonState();
}

class _SocialSignInButtonState extends State<SocialSignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // [SocialSignInButton.initState] - Initialize press animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Gets the provider-specific configuration
  _ProviderConfig get _config {
    final iconSize = ResponsiveSizer.iconSize(context) * 1.2;

    switch (widget.provider) {
      case SocialSignInProvider.google:
        return _ProviderConfig(
          text: 'Continue with Google',
          icon: SvgPicture.asset(
            'assets/icons/ic_google.svg',
            width: iconSize,
            height: iconSize,
          ),
          backgroundColor: Colors.white,
          textColor: const Color(0xFF1F1F1F),
          borderColor: const Color(0xFFDADCE0),
        );
      case SocialSignInProvider.apple:
        // Apple button adapts to dark/light mode
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return _ProviderConfig(
          text: 'Continue with Apple',
          icon: SvgPicture.asset(
            'assets/icons/ic_apple.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              isDark ? Colors.black : Colors.white,
              BlendMode.srcIn,
            ),
          ),
          backgroundColor: isDark ? Colors.white : Colors.black,
          textColor: isDark ? Colors.black : Colors.white,
          borderColor: isDark ? Colors.white : Colors.black,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final buttonHeight = ResponsiveSizer.buttonHeight(context) * 1.2;
    final borderRadius = ResponsiveSizer.borderRadius(context);
    final fontSize = 17 * ResponsiveSizer.fontSizeMultiplier(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              height: buttonHeight,
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: config.borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: config.textColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        config.icon,
                        SizedBox(width: ResponsiveSizer.spacing(context) * 1.2),
                        Text(
                          config.text,
                          style: TextStyle(
                            color: config.textColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuration for a social sign-in provider
class _ProviderConfig {
  const _ProviderConfig({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  final String text;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
}
