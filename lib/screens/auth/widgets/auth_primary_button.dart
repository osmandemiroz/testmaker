import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// auth_primary_button.dart
/// ********************************************************************
///
/// A beautiful primary action button for authentication screens.
/// Features:
/// - iOS-style rounded corners and gradient
/// - Press animation with scale effect
/// - Loading state with spinner
/// - Disabled state styling
///

/// ********************************************************************
/// AuthPrimaryButton
/// ********************************************************************
///
/// Primary action button for login/register forms.
/// Follows Apple Human Interface Guidelines.
///
class AuthPrimaryButton extends StatefulWidget {
  const AuthPrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Button text
  final String text;

  /// Callback when pressed (null to disable)
  final VoidCallback? onPressed;

  /// Whether the button shows loading state
  final bool isLoading;

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // [AuthPrimaryButton.initState] - Initialize press animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonHeight = ResponsiveSizer.buttonHeight(context) * 1.2;
    final borderRadius = ResponsiveSizer.borderRadius(context);
    final fontSize = 17 * ResponsiveSizer.fontSizeMultiplier(context);

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _animationController.forward() : null,
        onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
        onTapCancel: isEnabled ? () => _animationController.reverse() : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: buttonHeight,
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.85),
                        ],
                      )
                    : null,
                color: isEnabled
                    ? null
                    : theme.colorScheme.primary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.41,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
