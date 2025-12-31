import 'package:flutter/material.dart';

import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/home_screen.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

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
            final isCompact =
                ResponsiveSizer.isCompactFromConstraints(constraints);

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: ResponsiveSizer.paddingFromConstraints(constraints),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveSizer.maxContentWidthFromConstraints(
                            constraints,
                          ) *
                          0.7,
                    ),
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
                          SizedBox(
                            height:
                                ResponsiveSizer.sectionSpacingFromConstraints(
                              constraints,
                            ),
                          ),
                          _buildReviewSection(theme, textTheme, isCompact),
                        ],
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                                BoxConstraints.tightFor(
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ) *
                              3,
                        ),
                        SizedBox(
                          height: ResponsiveSizer.buttonHeight(context),
                          child: ElevatedButton(
                            onPressed: () {
                              // Use a smooth, Cupertino-style animated transition
                              // when returning to the home screen so the flow
                              // feels consistent with the rest of the app.
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder<void>(
                                  pageBuilder: (
                                    BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                  ) {
                                    return const HomeScreen();
                                  },
                                  transitionsBuilder: (
                                    BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                    Widget child,
                                  ) {
                                    final slideCurve = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    );

                                    final slideAnimation = Tween<Offset>(
                                      begin: const Offset(0, 0.04),
                                      end: Offset.zero,
                                    ).animate(slideCurve);

                                    final fadeCurve = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    );

                                    return FadeTransition(
                                      opacity: fadeCurve,
                                      child: SlideTransition(
                                        position: slideAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveSizer.borderRadiusFromConstraints(
                                    constraints,
                                  ),
                                ),
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
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                                BoxConstraints.tightFor(
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ) *
                              1.5,
                        ),
                        SizedBox(
                          height: ResponsiveSizer.buttonHeight(context) - 2,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                PageRouteBuilder<void>(
                                  pageBuilder: (
                                    BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                  ) {
                                    return const HomeScreen();
                                  },
                                  transitionsBuilder: (
                                    BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                    Widget child,
                                  ) {
                                    // Match the same fade + subtle upward slide
                                    // used elsewhere so that even "reset to home"
                                    // feels soft and fluid, in line with Apple's
                                    // motion guidelines.
                                    final slideCurve = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    );

                                    final slideAnimation = Tween<Offset>(
                                      begin: const Offset(0, 0.04),
                                      end: Offset.zero,
                                    ).animate(slideCurve);

                                    final fadeCurve = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    );

                                    return FadeTransition(
                                      opacity: fadeCurve,
                                      child: SlideTransition(
                                        position: slideAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveSizer.borderRadiusFromConstraints(
                                    constraints,
                                  ),
                                ),
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.all(
            ResponsiveSizer.cardPaddingFromConstraints(constraints) * 1.1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(
                constraints,
                multiplier: 1.4,
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.92),
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
                    width: ResponsiveSizer.iconContainerSizeFromConstraints(
                      constraints,
                    ),
                    height: ResponsiveSizer.iconContainerSizeFromConstraints(
                      constraints,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveSizer.borderRadiusFromConstraints(
                          constraints,
                        ),
                      ),
                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                      size:
                          ResponsiveSizer.iconSizeFromConstraints(constraints),
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
              SizedBox(
                height: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 2.25,
                ),
              ),
              Text(
                _summaryText,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              SizedBox(
                height: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 1.5,
                ),
              ),
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
      },
    );
  }

  /// Builds the review section showing incorrect answers with explanations.
  Widget _buildReviewSection(
    ThemeData theme,
    TextTheme textTheme,
    bool isCompact,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.all(
            ResponsiveSizer.cardPaddingFromConstraints(constraints),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
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
                    size: ResponsiveSizer.iconSizeFromConstraints(constraints),
                  ),
                  SizedBox(
                    width: ResponsiveSizer.spacingFromConstraints(constraints),
                  ),
                  Text(
                    'Review Incorrect Answers',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 2.5,
                ),
              ),
              ...incorrectAnswers!.asMap().entries.map<Widget>(
                (MapEntry<int, Map<String, dynamic>> entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final question = data['question'] as Question;
                  final selectedIndices =
                      (data['selectedIndices'] as List).cast<int>();

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < incorrectAnswers!.length - 1 ? 20 : 0,
                    ),
                    child: _buildReviewItem(
                      theme,
                      textTheme,
                      question,
                      selectedIndices,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a single review item for an incorrect answer.
  Widget _buildReviewItem(
    ThemeData theme,
    TextTheme textTheme,
    Question question,
    List<int> selectedIndices,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.all(
            ResponsiveSizer.cardPaddingFromConstraints(constraints),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(constraints),
            ),
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
              SizedBox(
                height: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 1.5,
                ),
              ),
              // Selected answer(s) (incorrect because they didn't match perfectly)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.error,
                    size: ResponsiveSizer.iconSizeFromConstraints(constraints),
                  ),
                  SizedBox(
                    width: ResponsiveSizer.spacingFromConstraints(constraints),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Your answer${selectedIndices.length > 1 ? 's' : ''}:',
                          style: textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...selectedIndices.map(
                          (i) => Text(
                            question.options[i],
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 1.5,
                ),
              ),
              // Correct answer(s)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: ResponsiveSizer.iconSizeFromConstraints(constraints),
                  ),
                  SizedBox(
                    width: ResponsiveSizer.spacingFromConstraints(constraints),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Correct answer${question.answerIndices.length > 1 ? 's' : ''}:',
                          style: textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...question.answerIndices.map(
                          (i) => Text(
                            question.options[i],
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
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
                SizedBox(
                  height: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveSizer.cardPaddingFromConstraints(constraints) *
                        0.75,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(constraints),
                    ),
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          constraints,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 1.5,
                        ),
                      ),
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
      },
    );
  }
}
