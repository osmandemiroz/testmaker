import 'package:flutter/material.dart';

/// ********************************************************************
/// QuizProgressBar
/// ********************************************************************
///
/// A slim, animated bar that visually communicates the user's progress
/// through the quiz. This leans on Apple's design language: minimal,
/// clear, with subtle motion rather than loud, distracting animation.
///
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    required this.currentIndex,
    required this.total,
    super.key,
  });

  /// Zero-based index of the current question.
  final int currentIndex;

  /// Total number of questions in the quiz.
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Guard against divide-by-zero and clamp the progress value.
    final progress =
        total == 0 ? 0 : ((currentIndex + 1) / total).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress.toDouble()),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double value, Widget? child) {
              return FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
