import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// auth_text_field.dart
/// ********************************************************************
///
/// A beautiful, Apple HIG-compliant text field for authentication forms.
/// Features:
/// - iOS-style rounded corners
/// - Animated label
/// - Password visibility toggle
/// - Error state styling
/// - Responsive sizing
///

/// ********************************************************************
/// AuthTextField
/// ********************************************************************
///
/// Custom styled text field for the authentication screen.
/// Follows Apple Human Interface Guidelines.
///
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
    this.prefixIcon,
    super.key,
  });

  /// Controller for the text field
  final TextEditingController controller;

  /// Label text displayed above the field
  final String label;

  /// Hint text displayed inside the field
  final String? hintText;

  /// Keyboard type for the field
  final TextInputType keyboardType;

  /// Whether the text should be obscured (for passwords)
  final bool obscureText;

  /// Action button on the keyboard
  final TextInputAction textInputAction;

  /// Validation function
  final String? Function(String?)? validator;

  /// Callback when the field is submitted
  final void Function(String)? onFieldSubmitted;

  /// Autofill hints for the field
  final Iterable<String>? autofillHints;

  /// Optional prefix icon
  final IconData? prefixIcon;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  /// Tracks whether password is visible
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = ResponsiveSizer.borderRadius(context);
    final fontSize = 17 * ResponsiveSizer.fontSizeMultiplier(context);
    final labelFontSize = 13 * ResponsiveSizer.fontSizeMultiplier(context);
    final isDark = theme.brightness == Brightness.dark;

    // Color scheme following Apple HIG
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.1);
    final focusedBorderColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            letterSpacing: -0.08,
          ),
        ),

        SizedBox(height: ResponsiveSizer.spacing(context) * 0.5),

        // Text Field
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && !_isPasswordVisible,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          autofillHints: widget.autofillHints,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacing(context) * 1.5,
              vertical: ResponsiveSizer.spacing(context) * 1.5,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: ResponsiveSizer.iconSize(context) * 0.9,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: ResponsiveSizer.iconSize(context) * 0.9,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: focusedBorderColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            errorStyle: TextStyle(
              fontSize: labelFontSize * 0.9,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}
