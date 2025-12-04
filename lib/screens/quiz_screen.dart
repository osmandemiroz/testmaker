import 'package:flutter/material.dart';
import 'package:testmaker/controllers/quiz_controller.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/result_screen.dart';
import 'package:testmaker/utils/responsive_sizer.dart';
import 'package:testmaker/widgets/quiz_option_card.dart';
import 'package:testmaker/widgets/quiz_progress_bar.dart';

/// ********************************************************************
/// QuizScreen
/// ********************************************************************
///
/// Displays one question at a time with animated transitions between them.
/// The layout is responsive and keeps a focused, card-based design that
/// mirrors Apple's Human Interface Guidelines (clear hierarchy, ample
/// padding, and smooth motion).
///
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    required this.questions,
    super.key,
  });

  final List<Question> questions;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizController(widget.questions);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onOptionSelected(int index) async {
    final isComplete = await _controller.selectOption(index);
    if (isComplete && mounted) {
      await _goToResults();
    }
  }

  Future<void> _goToResults() async {
    // Check if any questions have explanations (AI-generated quiz)
    final hasExplanations = widget.questions.any(
      (Question q) => q.explanation != null && q.explanation!.isNotEmpty,
    );

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return ResultScreen(
            totalQuestions: _controller.totalQuestions,
            correctAnswers: _controller.score,
            incorrectAnswers:
                hasExplanations ? _controller.incorrectAnswers : null,
          );
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final Animation<double> fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Padding(
              padding: ResponsiveSizer.paddingFromConstraints(constraints),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  QuizProgressBar(
                    currentIndex: _controller.currentIndex,
                    total: _controller.totalQuestions,
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 2,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Question ${_controller.currentIndex + 1}',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_controller.currentIndex + 1} of ${_controller.totalQuestions}',
                        style: textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 2,
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: _buildQuestionCard(
                        key: ValueKey<int>(_controller.currentIndex),
                        theme: theme,
                        textTheme: textTheme,
                        constraints: constraints,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required Key key,
    required ThemeData theme,
    required TextTheme textTheme,
    required BoxConstraints constraints,
  }) {
    final question = _controller.currentQuestion;

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(
            constraints,
            multiplier: 2,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: EdgeInsets.all(
        ResponsiveSizer.cardPaddingFromConstraints(constraints),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question.text,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 2.25,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (BuildContext context, int index) {
                final option = question.options[index];
                final isSelected = _controller.selectedIndex == index;
                final isCorrect = question.answerIndex == index;

                return QuizOptionCard(
                  label: option,
                  index: index,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  isRevealed: _controller.revealAnswer,
                  onTap: () => _onOptionSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
