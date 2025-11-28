import 'package:flutter/material.dart';

import 'package:testmaker/screens/home_screen.dart';

/// ********************************************************************
/// ResultScreen
/// ********************************************************************
///
/// Displays the user's final score and a short summary.
/// We keep the design calm and focused, with a prominent score,
/// clear messaging, and simple actions to retry or go back home.
///
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.totalQuestions,
    required this.correctAnswers,
    super.key,
  });

  final int totalQuestions;
  final int correctAnswers;

  double get _percentage {
    if (totalQuestions == 0) {
      return 0;
    }
    return (correctAnswers / totalQuestions) * 100;
  }

  String get _summaryText {
    final p = _percentage;
    if (p >= 90) {
      return 'Outstanding work!';
    } else if (p >= 70) {
      return 'Great job!';
    } else if (p >= 50) {
      return 'Nice effort – keep practicing.';
    } else {
      return 'Don’t worry, every quiz is a chance to learn.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isCompact = constraints.maxWidth < 600;

            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 24 : 40,
                  vertical: isCompact ? 24 : 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Hero(
                        tag: 'quiz-card',
                        child: _buildScoreCard(theme, textTheme, isCompact),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const HomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Take another quiz',
                            style: textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const HomeScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Back to home',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    ThemeData theme,
    TextTheme textTheme,
    bool isCompact,
  ) {
    final percent = _percentage;

    return Container(
      padding: EdgeInsets.all(isCompact ? 22 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _summaryText,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You answered $correctAnswers out of $totalQuestions '
            'questions correctly.',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
