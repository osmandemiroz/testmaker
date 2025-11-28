import 'package:flutter/material.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/result_screen.dart';
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
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _revealAnswer = false;
  bool _isTransitioning = false;

  Question get _currentQuestion => widget.questions[_currentIndex];

  Future<void> _onOptionSelected(int index) async {
    if (_isTransitioning || _revealAnswer) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      _revealAnswer = true;
      _isTransitioning = true;
    });

    if (index == _currentQuestion.answerIndex) {
      _score += 1;
    }

    // Short pause so the user can see the feedback colors before moving on.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex += 1;
        _selectedIndex = null;
        _revealAnswer = false;
        _isTransitioning = false;
      });
    } else {
      await _goToResults();
    }
  }

  Future<void> _goToResults() async {
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return ResultScreen(
            totalQuestions: widget.questions.length,
            correctAnswers: _score,
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
            final isCompact = constraints.maxWidth < 600;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 32,
                vertical: isCompact ? 16 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  QuizProgressBar(
                    currentIndex: _currentIndex,
                    total: widget.questions.length,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Text(
                        'Question ${_currentIndex + 1}',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_currentIndex + 1} of ${widget.questions.length}',
                        style: textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                        key: ValueKey<int>(_currentIndex),
                        theme: theme,
                        textTheme: textTheme,
                        isCompact: isCompact,
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
    required bool isCompact,
  }) {
    final question = _currentQuestion;

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: EdgeInsets.all(isCompact ? 18 : 22),
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
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (BuildContext context, int index) {
                final option = question.options[index];
                final isSelected = _selectedIndex == index;
                final isCorrect = question.answerIndex == index;

                return QuizOptionCard(
                  label: option,
                  index: index,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  isRevealed: _revealAnswer,
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
