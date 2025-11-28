import 'package:flutter/material.dart';

/// ********************************************************************
/// QuizOptionCard
/// ********************************************************************
///
/// Single answer option for a quiz question.
///
/// This widget is intentionally highly visual and animated to feel modern
/// and "Apple-like": rounded corners, subtle elevation, and smooth color
/// transitions on selection.
///
class QuizOptionCard extends StatelessWidget {
  const QuizOptionCard({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isRevealed,
    required this.onTap,
    super.key,
  });

  /// Text of the option.
  final String label;

  /// Index of the option in the question's option list.
  final int index;

  /// Whether this option is currently selected.
  final bool isSelected;

  /// Whether this option is the correct answer.
  final bool isCorrect;

  /// Whether answer correctness has been revealed yet.
  ///
  /// Until revealed, options should all look neutral even if one
  /// is the correct answer.
  final bool isRevealed;

  /// Callback when the option is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Base colors derived from the theme for better dark/light support.
    final baseColor = theme.colorScheme.surface;
    final selectedColor = theme.colorScheme.primary.withValues(alpha: 0.12);
    final correctColor = Colors.greenAccent.withValues(alpha: 0.18);
    final incorrectColor = Colors.redAccent.withValues(alpha: 0.16);

    var background = baseColor;
    var borderColor = theme.dividerColor.withValues(alpha: 0.3);
    var textColor = theme.colorScheme.onSurface;

    if (isRevealed) {
      if (isCorrect) {
        background = correctColor;
        borderColor = Colors.greenAccent;
        textColor = theme.colorScheme.onSurface;
      } else if (isSelected) {
        background = incorrectColor;
        borderColor = Colors.redAccent;
        textColor = theme.colorScheme.onSurface;
      }
    } else if (isSelected) {
      background = selectedColor;
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onSurface;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: <Widget>[
                // Circular index "badge" reminiscent of Apple lists.
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.9),
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
