import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// guest_button.dart
/// ********************************************************************
///
/// A subtle "Continue as Guest" button for users who don't want to
/// sign in with a social account.
///
/// Follows Apple Human Interface Guidelines:
/// - Text button style (less prominent than social buttons)
/// - iOS blue accent color
/// - Subtle, non-intrusive design
///

/// ********************************************************************
/// GuestButton
/// ********************************************************************
///
/// A text-style button for guest/anonymous sign-in.
/// Designed to be visually subordinate to the social sign-in buttons.
///
class GuestButton extends StatelessWidget {
  const GuestButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = 16 * ResponsiveSizer.fontSizeMultiplier(context);

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveSizer.spacing(context) * 1.5,
          horizontal: ResponsiveSizer.spacing(context) * 2,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            )
          : Text(
              'Continue as Guest',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.41,
              ),
            ),
    );
  }
}
