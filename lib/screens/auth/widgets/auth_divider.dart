import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// auth_divider.dart
/// ********************************************************************
///
/// A styled "or" divider for the authentication screen.
/// Separates the social sign-in buttons from the guest option.
///
/// Follows Apple Human Interface Guidelines:
/// - Subtle secondary label color
/// - Thin divider lines
/// - Appropriate spacing
///

/// ********************************************************************
/// AuthDivider
/// ********************************************************************
///
/// A horizontal divider with "or" text in the center.
/// Used to separate different authentication options.
///
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = 14 * ResponsiveSizer.fontSizeMultiplier(context);
    final dividerColor = theme.colorScheme.outline.withValues(alpha: 0.5);
    final textColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveSizer.spacing(context) * 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              color: dividerColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacing(context) * 2,
            ),
            child: Text(
              'or',
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.08,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              color: dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}
