import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/quiz_screen.dart';
import 'package:testmaker/services/quiz_service.dart';

/// ********************************************************************
/// HomeScreen
/// ********************************************************************
///
/// Entry point of the quiz experience.
///
/// The design aims to feel at home on iOS and macOS:
///  - Generous use of white space
///  - Soft rounded rectangles
///  - Subtle gradients and blurs instead of heavy borders
///  - Smooth hero-style card animation when starting the quiz
///
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuizService _quizService = const QuizService();

  bool _isLoading = false;
  bool _isCustomLoading = false;
  String? _error;

  Future<void> _startQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questions = await _quizService.loadQuestions(); // [HomeScreen]

      if (!mounted) {
        return;
      }

      if (questions.isEmpty) {
        setState(() {
          _error = 'No questions found in the quiz file.';
          _isLoading = false;
        });
        return;
      }

      await Navigator.of(context).push(
        _createQuizRoute(questions),
      );

      // After returning from the quiz we simply stop the loader.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      // Helpful logging prefix to indicate where this print comes from.
      // This follows the user's preference for including the function name.
      // ignore: avoid_print
      print('[HomeScreen._startQuiz] Failed to load quiz: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Unable to load the quiz. Please check the JSON file.';
        _isLoading = false;
      });
    }
  }

  /// Starts a quiz based on a JSON file the user selects from their device.
  Future<void> _startQuizFromFile() async {
    setState(() {
      _isCustomLoading = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled the picker; we simply stop the loading state
        // without showing an error.
        if (mounted) {
          setState(() {
            _isCustomLoading = false;
          });
        }
        return;
      }

      final file = result.files.first;
      final filePath = file.path;

      if (filePath == null) {
        if (mounted) {
          setState(() {
            _error = 'Selected file path could not be read.';
            _isCustomLoading = false;
          });
        }
        return;
      }

      final questions = await _quizService.loadQuestionsFromFile(filePath);

      if (!mounted) {
        return;
      }

      if (questions.isEmpty) {
        setState(() {
          _error = 'The selected JSON did not contain any questions.';
          _isCustomLoading = false;
        });
        return;
      }

      await Navigator.of(context).push(
        _createQuizRoute(questions),
      );

      if (mounted) {
        setState(() {
          _isCustomLoading = false;
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._startQuizFromFile] Failed to load custom quiz: $e');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _error =
            'Unable to read that JSON file.\nPlease make sure it contains a list of questions.';
        _isCustomLoading = false;
      });
    }
  }

  /// Custom route that gently fades and slides the quiz screen in,
  /// in line with Apple's preference for meaningful but tasteful motion.
  Route<void> _createQuizRoute(List<Question> questions) {
    return PageRouteBuilder<void>(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return QuizScreen(questions: questions);
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        final Animation<double> fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 24 : 40,
                  vertical: isCompact ? 24 : 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TestMaker',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create and take beautiful, focused quizzes.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Hero(
                        tag: 'quiz-card',
                        child: _buildHeroCard(theme, textTheme, isCompact),
                      ),
                      const SizedBox(height: 24),
                      _buildUploadArea(theme, textTheme, isCompact),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _startQuiz,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            disabledBackgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            disabledForegroundColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isLoading
                                ? SizedBox(
                                    key: const ValueKey<String>('loader'),
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Start Quiz',
                                    key: const ValueKey<String>('label'),
                                    style: textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
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

  Widget _buildHeroCard(
    ThemeData theme,
    TextTheme textTheme,
    bool isCompact,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.all(isCompact ? 20 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                ),
                child: Text(
                  'JSON-powered',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Modern quiz\nexperience',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Questions are loaded from a simple JSON file so you can '
            'swap in new tests without touching the code.',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  /// Small, focused area that lets the user bring their own quiz JSON.
  ///
  /// Visually this is lighter than the main hero card, but still follows
  /// the same Apple-influenced language: soft corners, subtle border,
  /// and a single clear call-to-action button.
  Widget _buildUploadArea(
    ThemeData theme,
    TextTheme textTheme,
    bool isCompact,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isCompact ? 14 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.upload_file_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Use your own JSON',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pick a .json file with questions, choices and answers.',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: _isCustomLoading ? null : _startQuizFromFile,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: _isCustomLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Text(
                      'Choose file',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
