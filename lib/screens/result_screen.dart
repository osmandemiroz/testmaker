import 'package:flutter/material.dart';

import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/home_screen.dart';

/// ********************************************************************
/// ResultScreen
/// ********************************************************************
///
/// Displays the user's final score and a short summary.
/// For AI-generated quizzes, also shows a review section with incorrect
/// answers and explanations.
/// We keep the design calm and focused, with a prominent score,
/// clear messaging, and simple actions to retry or go back home.
///
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.totalQuestions,
    required this.correctAnswers,
    this.incorrectAnswers,
    super.key,
  });

  final int totalQuestions;
  final int correctAnswers;
  final List<Map<String, dynamic>>? incorrectAnswers;

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

            return SingleChildScrollView(
              child: Center(
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
                        // Review section for AI-generated quizzes
                        if (incorrectAnswers != null &&
                            incorrectAnswers!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 32),
                          _buildReviewSection(theme, textTheme, isCompact),
                        ],
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

  /// Builds the review section showing incorrect answers with explanations.
  Widget _buildReviewSection(
    ThemeData theme,
    TextTheme textTheme,
    bool isCompact,
  ) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 20 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.reviews_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Review Incorrect Answers',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...incorrectAnswers!.asMap().entries.map<Widget>(
            (MapEntry<int, Map<String, dynamic>> entry) {
              final index = entry.key;
              final data = entry.value;
              final question = data['question'] as Question;
              final selectedIndex = data['selectedIndex'] as int;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < incorrectAnswers!.length - 1 ? 20 : 0,
                ),
                child: _buildReviewItem(
                  theme,
                  textTheme,
                  question,
                  selectedIndex,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds a single review item for an incorrect answer.
  Widget _buildReviewItem(
    ThemeData theme,
    TextTheme textTheme,
    Question question,
    int selectedIndex,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Question text
          Text(
            question.text,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Selected answer (incorrect)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.close_rounded,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your answer:',
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.options[selectedIndex],
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Correct answer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Correct answer:',
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.options[question.answerIndex],
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Explanation
          if (question.explanation != null &&
              question.explanation!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Explanation:',
                          style: textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.explanation!,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
