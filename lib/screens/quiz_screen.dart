import 'package:flutter/material.dart';
import 'package:testmaker/controllers/quiz_controller.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/models/quiz_result.dart';
import 'package:testmaker/screens/result_screen.dart';
import 'package:testmaker/services/quiz_result_service.dart';
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
    this.courseId,
    this.quizIndex,
    this.quizName,
    super.key,
  });

  final List<Question> questions;
  final String? courseId;
  final int? quizIndex;
  final String? quizName;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizController _controller;
  bool _isNavigatingForward = true; // Track navigation direction for animations
  final QuizResultService _resultService = QuizResultService();
  final DateTime _startTime = DateTime.now();

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

  void _onOptionSelected(int index) {
    // Record the answer and reveal correctness, but don't move on automatically
    _controller.selectOption(index);
  }

  /// Handles swipe gesture to move to the next question.
  ///
  /// Only allows swiping forward if an answer has been selected and revealed.
  Future<void> _onSwipeToNext() async {
    if (!_controller.revealAnswer) {
      // Can't swipe forward if no answer has been selected yet
      return;
    }

    _isNavigatingForward = true;
    final isComplete = _controller.moveToNextQuestion();
    if (isComplete && mounted) {
      await _goToResults();
    }
  }

  /// Handles swipe gesture to move to the previous question.
  ///
  /// Can be called at any time to navigate back to previous questions.
  void _onSwipeToPrevious() {
    _isNavigatingForward = false;
    _controller.moveToPreviousQuestion();
  }

  Future<void> _goToResults() async {
    // Save quiz result if course and quiz information is available
    if (widget.courseId != null &&
        widget.quizIndex != null &&
        widget.quizName != null) {
      final duration = DateTime.now().difference(_startTime).inSeconds;
      final result = QuizResult(
        courseId: widget.courseId!,
        quizIndex: widget.quizIndex!,
        quizName: widget.quizName!,
        score: _controller.score,
        totalQuestions: _controller.totalQuestions,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        duration: duration,
      );

      try {
        await _resultService.saveQuizResult(result);
      } on Exception catch (e) {
        // Silently fail - don't interrupt the user experience
        // In production, you might want to log this error
        if (mounted) {
          debugPrint('[QuizScreen._goToResults] Failed to save result: $e');
        }
      }
    }

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
                    child: GestureDetector(
                      // Detect horizontal swipe gestures to navigate between questions
                      onHorizontalDragEnd: (DragEndDetails details) {
                        if (details.primaryVelocity != null) {
                          // Swipe left to move to next question
                          if (details.primaryVelocity! < -500) {
                            _onSwipeToNext();
                          }
                          // Swipe right to move to previous question
                          else if (details.primaryVelocity! > 500) {
                            _onSwipeToPrevious();
                          }
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (
                          Widget? currentChild,
                          List<Widget> previousChildren,
                        ) {
                          // Stack both widgets to allow simultaneous animation
                          return Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          // Create smooth, Apple-like transition with slide, fade, and scale
                          // This handles the entering widget animation
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          );

                          // Slide animation - direction depends on navigation direction
                          // More pronounced for better visual feedback
                          final slideOffset = _isNavigatingForward
                              ? const Offset(
                                  0.25,
                                  0,
                                ) // Slide in from right when going forward
                              : const Offset(
                                  -0.25,
                                  0,
                                ); // Slide in from left when going backward

                          final offsetAnimation = Tween<Offset>(
                            begin: slideOffset,
                            end: Offset.zero,
                          ).animate(curvedAnimation);

                          // Scale animation for depth effect (subtle Apple-style)
                          final scaleAnimation = Tween<double>(
                            begin: 0.92,
                            end: 1,
                          ).animate(curvedAnimation);

                          // Opacity for smooth fade-in
                          final opacityAnimation = Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(curvedAnimation);

                          // Combine all animations for a smooth, polished transition
                          // Following Apple's Human Interface Guidelines for smooth motion
                          return SlideTransition(
                            position: offsetAnimation,
                            child: FadeTransition(
                              opacity: opacityAnimation,
                              child: ScaleTransition(
                                scale: scaleAnimation,
                                child: child,
                              ),
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
                  // Disable tap if answer has already been revealed
                  onTap: _controller.revealAnswer
                      ? null
                      : () => _onOptionSelected(index),
                );
              },
            ),
          ),
          // Show swipe hints when answer is revealed
          if (_controller.revealAnswer)
            AnimatedOpacity(
              opacity: _controller.revealAnswer ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Show swipe right hint if not on first question
                    if (!_controller.isFirstQuestion) ...<Widget>[
                      Icon(
                        Icons.swipe_right,
                        size: 16,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(
                        width: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 0.75,
                        ),
                      ),
                      Text(
                        'Previous',
                        style: textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 1.5,
                        ),
                      ),
                    ],
                    // Show swipe left hint if not on last question
                    if (!_controller.isLastQuestion) ...<Widget>[
                      Icon(
                        Icons.swipe_left,
                        size: 16,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(
                        width: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 0.75,
                        ),
                      ),
                      Text(
                        'Next',
                        style: textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
