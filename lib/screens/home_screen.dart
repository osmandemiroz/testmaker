// ignore_for_file: use_if_null_to_convert_nulls_to_bools, document_ignores, leading_newlines_in_multiline_strings

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/flashcard_screen.dart';
import 'package:testmaker/screens/pdf_viewer_screen.dart';
import 'package:testmaker/screens/quiz_screen.dart';
import 'package:testmaker/services/question_generator_service.dart';
import 'package:testmaker/services/quiz_service.dart';
import 'package:testmaker/utils/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// ********************************************************************
/// HomeScreen
/// ********************************************************************
///
/// Main entry point with a left sidebar menu for course management.
///
/// The design follows Apple's Human Interface Guidelines:
///  - Clean sidebar navigation on the left
///  - Main content area on the right
///  - Smooth animations and transitions
///  - Generous use of white space
///  - Soft rounded rectangles and subtle shadows
///
/// Features:
///  - Create and manage course sections
///  - Upload quizzes to courses
///  - Start quizzes from courses
///  - Quick access to sample quiz
///
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  final Set<String> _expandedPdfs = <String>{};
  // Track which modules (courses) are expanded to show their contents
  final Set<String> _expandedModules = <String>{};
  // GlobalKey to control drawer programmatically on mobile
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Track swipe indicator animation
  bool _showSwipeIndicator = false;
  Timer? _swipeIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller
      ..addListener(_onControllerChanged)
      ..initialize();
    
    // Start swipe indicator animation to help users discover the menu
    _startSwipeIndicatorAnimation();
  }

  @override
  void dispose() {
    _swipeIndicatorTimer?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        // Modules come closed by default - users can expand them manually
        // No automatic expansion of modules
      });
    }
  }

  /// Starts the swipe indicator animation sequence.
  ///
  /// Shows an animated arrow that moves from left to right to indicate
  /// users can swipe from the left edge to open the menu.
  /// The indicator appears after 4-5 seconds and cycles a few times.
  void _startSwipeIndicatorAnimation() {
    // Wait for the first frame to ensure everything is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Additional delay to ensure everything is fully rendered
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        
        // Show indicator after 4-5 seconds (randomized for natural feel)
        final randomDelay = 4000 + (DateTime.now().millisecond % 1000);
        _swipeIndicatorTimer = Timer(
          Duration(milliseconds: randomDelay),
          () {
            if (mounted) {
              _showSwipeIndicatorCycle();
            }
          },
        );
      });
    });
  }

  /// Shows the swipe indicator animation cycle.
  ///
  /// The indicator appears and animates 2-3 times to help users discover
  /// the swipe gesture, then disappears.
  void _showSwipeIndicatorCycle() {
    if (!mounted) return;
    
    setState(() {
      _showSwipeIndicator = true;
    });
    
    // Hide after showing for a few cycles (about 3-4 seconds total)
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _showSwipeIndicator = false;
        });
      }
    });
  }

  /// Creates a new course with the given name.
  Future<void> _createCourse(String name) async {
    await _controller.createCourse(name);
  }

  /// Shows a dialog to rename an item (quiz, PDF, or flashcard set).
  Future<void> _showRenameDialog({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 1.67,
                  ),
                ),
              ),
              title: Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter a name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(constraints),
                    ),
                  ),
                ),
                onSubmitted: (String value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(context).pop(value.trim());
                  }
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.of(context).pop(name);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await onSave(result);
    }
  }

  /// Shows a dialog for pasting text content (quiz or flashcard).
  Future<String?> _showTextInputDialog({
    required String title,
    required String hint,
    required String label,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 1.67,
                  ),
                ),
              ),
              title: Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: ResponsiveSizer.maxContentWidthFromConstraints(
                  constraints,
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 15,
                  minLines: 10,
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveSizer.borderRadiusFromConstraints(
                          constraints,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.of(context).pop(text);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  /// Shows a beautifully designed dialog to create a new course.
  Future<void> _showCreateCourseDialog() async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return _CreateCourseDialog(controller: textController);
      },
    );

    if (result != null && result.isNotEmpty) {
      await _createCourse(result);
    }
  }

  /// Deletes a course from local storage.
  Future<void> _deleteCourse(Course course) async {
    await _controller.deleteCourse(course.id);
  }

  /// Uploads a PDF file to the selected course.
  Future<void> _uploadPdfToCourse(Course? course) async {
    if (course == null) return;
    _controller.selectCourse(course);
    await _controller.uploadPdfToCourse();
  }

  /// Opens a PDF viewer for the given PDF path.
  Future<void> _viewPdf(String pdfPath, String title) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PdfViewerScreen(
          pdfPath: pdfPath,
          title: title,
        ),
      ),
    );
  }

  /// Generates questions from a PDF file using the LLM.
  Future<void> _generateQuestionsFromPdf(Course course, String pdfPath) async {
    // Check if API key is set
    final hasApiKey = await QuestionGeneratorService.hasApiKey();
    if (!hasApiKey) {
      final apiKeySet = await _showApiKeyDialog();
      if (!apiKeySet) {
        return; // User cancelled
      }
    }

    // Ask for question count
    final questionCount = await _showQuestionCountDialog();
    if (questionCount == null) {
      return; // User cancelled
    }

    _controller.selectCourse(course);
    final success = await _controller.generateQuestionsFromPdf(
      pdfPath,
      questionCount,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully generated $questionCount questions!'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Shows a dialog to set the Google AI API key.
  ///
  /// Returns true if the API key was successfully set, false if cancelled.
  Future<bool> _showApiKeyDialog() async {
    final controller = TextEditingController();
    final currentKey = await QuestionGeneratorService.getApiKey() ?? '';

    if (!mounted) {
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 1.67,
                  ),
                ),
              ),
              title: Text(
                'API Key Required',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'To generate questions from PDFs, you need a Google AI API key.',
                      style: textTheme.bodyMedium,
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 2,
                      ),
                    ),
                    TextField(
                      controller: controller..text = currentKey,
                      decoration: InputDecoration(
                        labelText: 'Google AI API Key',
                        hintText: 'Enter your API key',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 1.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://makersuite.google.com/app/apikey',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.open_in_new,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          constraints,
                          multiplier: 0.67,
                        ),
                      ),
                      label: const Text('Get API Key'),
                    ),
                    SizedBox(
                      height:
                          ResponsiveSizer.spacingFromConstraints(constraints),
                    ),
                    Text(
                      'Get your free API key from:\nhttps://makersuite.google.com/app/apikey',
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (controller.text.trim().isNotEmpty) {
                      await QuestionGeneratorService.setApiKey(
                        controller.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('API key saved successfully!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  /// Shows a dialog to ask the user how many questions to generate.
  ///
  /// Returns the question count if confirmed, null if cancelled.
  Future<int?> _showQuestionCountDialog() async {
    final controller = TextEditingController(text: '10');

    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 1.67,
                  ),
                ),
              ),
              title: Text(
                'Number of Questions',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'How many questions would you like to generate from this PDF?',
                      style: textTheme.bodyMedium,
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 2,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Question Count',
                        hintText: 'Enter a number (e.g., 10)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height:
                          ResponsiveSizer.spacingFromConstraints(constraints),
                    ),
                    Text(
                      'Recommended: 5-20 questions',
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    final count = int.tryParse(text);
                    if (count != null && count > 0 && count <= 50) {
                      Navigator.of(context).pop(count);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a number between 1 and 50',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  /// Shows the settings dialog with options to change the API key.
  Future<void> _showSettingsDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const _SettingsDialog();
      },
    );
  }

  /// Deletes a PDF from a course.
  ///
  /// Immediately updates the local state to remove the PDF from the UI,
  /// then performs the async deletion and reloads from storage.
  Future<void> _deletePdfFromCourse(Course course, int pdfIndex) async {
    _controller.selectCourse(course);
    await _controller.deletePdfFromCourse(pdfIndex);
  }

  /// Deletes a quiz from a course.
  Future<void> _deleteQuizFromCourse(Course course, int quizIndex) async {
    _controller.selectCourse(course);
    await _controller.deleteQuizFromCourse(quizIndex);
  }

  /// Shows a dialog to paste quiz content and add it to the selected course.
  Future<void> _addQuizToCourse(Course? course) async {
    if (course == null) return;
    _controller.selectCourse(course);

    final result = await _showTextInputDialog(
      title: 'Add Quiz',
      hint:
          'Paste your quiz content here...\n\nThe app will automatically convert it to the correct format.\n\nYou can paste:\n• Content from AI agents\n• Simple text format',
      label: 'Quiz Content',
    );

    if (result != null && result.isNotEmpty) {
      await _controller.addQuizFromText(result);
      if (mounted && _controller.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz added successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Starts a quiz from the selected course and quiz index.
  ///
  /// Questions and options are shuffled before starting the quiz to prevent
  /// users from memorizing positions. A new random order is generated each time.
  Future<void> _startQuizFromCourse(Course course, int quizIndex) async {
    if (quizIndex < 0 || quizIndex >= course.quizzes.length) {
      return;
    }

    final questions = course.quizzes[quizIndex];
    if (questions.isEmpty) {
      return;
    }

    // Shuffle questions and options to prevent memorization
    final shuffledQuestions = QuestionUtils.shuffleQuestions(questions);

    await Navigator.of(context).push(
      _createQuizRoute(shuffledQuestions),
    );
  }

  /// Shows a dialog to paste flashcard content and add it to the selected course.
  Future<void> _addFlashcardsToCourse(Course? course) async {
    if (course == null) return;
    _controller.selectCourse(course);

    final result = await _showTextInputDialog(
      title: 'Add Flashcards',
      hint:
          'Paste your flashcard content here...\n\nThe app will automatically convert it to the correct format.\n\nYou can paste:\n• Content from AI agents\n• Simple text format',
      label: 'Flashcard Content',
    );

    if (result != null && result.isNotEmpty) {
      await _controller.addFlashcardsFromText(result);
      if (mounted && _controller.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flashcards added successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Generates flashcards from a PDF file using the LLM.
  Future<void> _generateFlashcardsFromPdf(Course course, String pdfPath) async {
    // Check if API key is set
    final hasApiKey = await QuestionGeneratorService.hasApiKey();
    if (!hasApiKey) {
      final apiKeySet = await _showApiKeyDialog();
      if (!apiKeySet) {
        return; // User cancelled
      }
    }

    // Ask for flashcard count
    final flashcardCount = await _showFlashcardCountDialog();
    if (flashcardCount == null) {
      return; // User cancelled
    }

    _controller.selectCourse(course);
    final success = await _controller.generateFlashcardsFromPdf(
      pdfPath,
      flashcardCount,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully generated $flashcardCount flashcards!'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Shows a dialog to ask the user how many flashcards to generate.
  ///
  /// Returns the flashcard count if confirmed, null if cancelled.
  Future<int?> _showFlashcardCountDialog() async {
    final controller = TextEditingController(text: '10');

    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 1.67,
                  ),
                ),
              ),
              title: Text(
                'Number of Flashcards',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'How many flashcards would you like to generate from this PDF?',
                      style: textTheme.bodyMedium,
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 2,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Flashcard Count',
                        hintText: 'Enter a number (e.g., 10)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height:
                          ResponsiveSizer.spacingFromConstraints(constraints),
                    ),
                    Text(
                      'Recommended: 10-30 flashcards',
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    final count = int.tryParse(text);
                    if (count != null && count > 0 && count <= 100) {
                      Navigator.of(context).pop(count);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a number between 1 and 100',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  /// Starts a flashcard session from the selected course and flashcard set index.
  ///
  /// Flashcards are shuffled before starting to prevent users from memorizing positions.
  Future<void> _startFlashcardsFromCourse(
    Course course,
    int flashcardSetIndex,
  ) async {
    if (flashcardSetIndex < 0 ||
        flashcardSetIndex >= course.flashcards.length) {
      return;
    }

    final flashcards = course.flashcards[flashcardSetIndex];
    if (flashcards.isEmpty) {
      return;
    }

    // Shuffle flashcards to prevent memorization
    final shuffledFlashcards = FlashcardUtils.shuffleFlashcards(flashcards);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => FlashcardScreen(
          flashcards: shuffledFlashcards,
        ),
      ),
    );
  }

  /// Starts the default sample quiz.
  Future<void> _startQuiz() async {
    try {
      const quizService = QuizService();
      final questions = await quizService.loadQuestions();

      if (!mounted) {
        return;
      }

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No questions found in the quiz content.'),
            ),
          );
        }
        return;
      }

      // Shuffle questions and options to prevent memorization
      final shuffledQuestions = QuestionUtils.shuffleQuestions(questions);

      await Navigator.of(context).push(
        _createQuizRoute(shuffledQuestions),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._startQuiz] Failed to load quiz: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load the quiz. Please check the content format.',
            ),
          ),
        );
      }
    }
  }

  /// Custom route that gently fades and slides the quiz screen in.
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
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Use ResponsiveSizer to determine if we should use compact layout
            final isCompact =
                ResponsiveSizer.isCompactFromConstraints(constraints);

            // On compact screens, use a drawer instead of a sidebar.
            if (isCompact) {
              return _buildCompactLayout(theme);
            }

            // On larger screens, use a persistent sidebar.
            return Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildSidebar(theme, constraints),
                    Expanded(
                      child: _buildMainContent(theme),
                    ),
                  ],
                ),
                // Swipe indicator overlay
                if (_showSwipeIndicator)
                  _buildSwipeIndicator(theme, constraints),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _controller.selectedCourse != null
          ? _buildFloatingActionButton(theme, textTheme)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Builds a swipe indicator that animates from left to right.
  ///
  /// This indicator appears on the left edge of the screen and animates
  /// horizontally to indicate users can swipe from left to right to open the menu.
  Widget _buildSwipeIndicator(ThemeData theme, BoxConstraints constraints) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          width: 60,
          alignment: Alignment.centerLeft,
          child: _SwipeIndicatorArrow(theme: theme),
        ),
      ),
    );
  }

  /// Builds the sidebar menu for course navigation.
  Widget _buildSidebar(ThemeData theme, BoxConstraints constraints) {
    final textTheme = theme.textTheme;
    final sidebarWidth =
        ResponsiveSizer.sidebarWidthFromConstraints(constraints);

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header with clickable logo to go to main screen
          Padding(
            padding: EdgeInsets.all(
              ResponsiveSizer.cardPaddingFromConstraints(constraints),
            ),
            child: Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {
                    _controller
                      ..selectCourse(null)
                      ..clearError();
                    // Close the drawer if it's open (for compact layout)
                    // This ensures the drawer closes after navigating to home
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.of(context).pop();
                    }
                  },
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 0.5,
                      ),
                      vertical: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'TestMaker',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 0.5,
                          ),
                        ),
                        Text(
                          'Your courses',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            height: ResponsiveSizer.dividerHeightFromConstraints(constraints),
          ),
          // Course list
          Expanded(
            child: _controller.isLoadingCourses
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _controller.courses.isEmpty
                    ? _buildEmptyCoursesState(theme, textTheme, constraints)
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ),
                        ),
                        itemCount: _controller.courses.length,
                        itemBuilder: (BuildContext context, int index) {
                          final course = _controller.courses[index];
                          final isSelected =
                              _controller.selectedCourse?.id == course.id;

                          return _buildCourseItemWithSwipe(
                            theme,
                            textTheme,
                            course,
                            isSelected,
                          );
                        },
                      ),
          ),
          Divider(
            height: ResponsiveSizer.dividerHeightFromConstraints(constraints),
          ),
          // Add course button
          Padding(
            padding: EdgeInsets.all(
              ResponsiveSizer.cardPaddingFromConstraints(constraints),
            ),
            child: FilledButton.icon(
              onPressed: _showCreateCourseDialog,
              icon: Icon(
                Icons.add,
                size: ResponsiveSizer.iconSizeFromConstraints(constraints),
              ),
              label: const Text('New Course'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 2,
                  ),
                  vertical: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 1.5,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single course item in the sidebar with swipe-to-delete.
  Widget _buildCourseItemWithSwipe(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    bool isSelected,
  ) {
    return Dismissible(
      key: Key('course_${course.id}'),
      direction: DismissDirection.endToStart,
      background: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacingFromConstraints(constraints),
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 0.5,
              ),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints),
              ),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
              right: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2.5,
              ),
            ),
            child: Icon(
              Icons.delete_outlined,
              color: theme.colorScheme.onError,
              size: ResponsiveSizer.iconSizeFromConstraints(constraints),
            ),
          );
        },
      ),
      confirmDismiss: (DismissDirection direction) async {
        // Show confirmation dialog before deleting
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final theme = Theme.of(context);
            final textTheme = theme.textTheme;

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                        multiplier: 1.67,
                      ),
                    ),
                  ),
                  title: Text(
                    'Delete Course?',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete "${course.name}"? '
                    'This action cannot be undone.',
                    style: textTheme.bodyMedium,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
        );

        return confirmed ?? false;
      },
      onDismissed: (DismissDirection direction) {
        _deleteCourse(course);
      },
      child: _buildCourseItem(theme, textTheme, course, isSelected),
    );
  }

  /// Builds a single course item in the sidebar.
  Widget _buildCourseItem(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    bool isSelected,
  ) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () {
            _controller
              ..selectCourse(course)
              ..clearError();
            // Close the drawer if it's open (for compact layout)
            // This ensures the drawer closes after selecting a course
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.of(context).pop();
            }
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal:
                      ResponsiveSizer.spacingFromConstraints(constraints),
                  vertical: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 0.5,
                  ),
                ),
                padding:
                    ResponsiveSizer.listItemPaddingFromConstraints(constraints),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.folder_outlined,
                      size:
                          ResponsiveSizer.iconSizeFromConstraints(constraints),
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            course.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (course.quizCount > 0)
                            Text(
                              '${course.quizCount} quiz${course.quizCount == 1 ? '' : 'zes'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Builds the empty state when no courses exist.
  Widget _buildEmptyCoursesState(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    return Center(
      child: Padding(
        padding: ResponsiveSizer.emptyStatePaddingFromConstraints(constraints),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_outlined,
              size: ResponsiveSizer.emptyStateIconSizeFromConstraints(
                constraints,
              ),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            Text(
              'No courses yet',
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(constraints),
            ),
            Text(
              'Create your first course to get started',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main content area.
  Widget _buildMainContent(ThemeData theme) {
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: ResponsiveSizer.paddingFromConstraints(constraints),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    ResponsiveSizer.maxContentWidthFromConstraints(constraints),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (_controller.selectedCourse == null) ...<Widget>[
                    // Show modules view instead of welcome content
                    _buildModulesView(theme, textTheme, constraints),
                  ] else ...<Widget>[
                    _buildCourseContent(theme, textTheme, constraints),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the welcome content when no course is selected.
  ///
  /// NOTE: This method is currently unused as the home screen now shows
  /// modules by default. Kept for potential future use or reference.
  // ignore: unused_element
  Widget _buildWelcomeContent(ThemeData theme, TextTheme textTheme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header row with title and settings button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Welcome to TestMaker',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                        ),
                      ),
                      Text(
                        'Create and take beautiful, focused quizzes.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Settings button in upper right corner
                IconButton(
                  onPressed: _showSettingsDialog,
                  icon: Icon(
                    Icons.settings_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  tooltip: 'Settings',
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.all(
                      ResponsiveSizer.spacingFromConstraints(constraints),
                    ),
                    minimumSize: Size(
                      ResponsiveSizer.iconContainerSizeFromConstraints(
                        constraints,
                      ),
                      ResponsiveSizer.iconContainerSizeFromConstraints(
                        constraints,
                      ),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            SizedBox(
              height:
                  ResponsiveSizer.sectionSpacingFromConstraints(constraints),
            ),
            Hero(
              tag: 'quiz-card',
              child: _buildHeroCard(theme, textTheme, constraints),
            ),
            SizedBox(
              height:
                  ResponsiveSizer.sectionSpacingFromConstraints(constraints),
            ),
            _buildUploadArea(theme, textTheme, constraints),
            if (_controller.error != null)
              Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 1.5,
                  ),
                ),
                child: Text(
                  _controller.error!,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            SizedBox(
              height:
                  ResponsiveSizer.sectionSpacingFromConstraints(constraints),
            ),
            SizedBox(
              height: ResponsiveSizer.buttonHeightFromConstraints(constraints) +
                  ResponsiveSizer.spacingFromConstraints(constraints),
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  disabledForegroundColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(constraints),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 3,
                    ),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Start Sample Quiz',
                    style: textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the modules view showing all courses with their contents visible.
  ///
  /// This replaces the welcome screen and displays all modules (courses)
  /// with their quizzes, flashcards, and PDFs visible by default.
  Widget _buildModulesView(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    // If no courses exist, show empty state
    if (_controller.courses.isEmpty) {
      return _buildEmptyModulesState(theme, textTheme, constraints);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header with title and settings button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Modules',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                    ),
                  ),
                  Text(
                    'All your courses and their contents',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Settings button in upper right corner
            IconButton(
              onPressed: _showSettingsDialog,
              icon: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              tooltip: 'Settings',
              style: IconButton.styleFrom(
                padding: EdgeInsets.all(
                  ResponsiveSizer.spacingFromConstraints(constraints),
                ),
                minimumSize: Size(
                  ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                  ),
                  ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                  ),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
        ),
        // List of all modules (courses) with their contents
        ..._controller.courses.map<Widget>(
          (Course course) => _buildModuleCard(
            theme,
            textTheme,
            course,
            constraints,
          ),
        ),
        SizedBox(
          height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
        ),
        // Content Templates section for creating quizzes and flashcards
        _buildJsonTemplatesSection(theme, textTheme, constraints),
      ],
    );
  }

  /// Builds a single module card showing the course and its contents.
  Widget _buildModuleCard(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    BoxConstraints constraints,
  ) {
    final isExpanded = _expandedModules.contains(course.id);

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
          multiplier: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Module header - clickable to expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedModules.remove(course.id);
                } else {
                  _expandedModules.add(course.id);
                }
              });
            },
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints),
              ),
              topRight: Radius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(
                ResponsiveSizer.cardPaddingFromConstraints(constraints),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.folder,
                    color: theme.colorScheme.primary,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 1.4,
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
                          course.name,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (course.quizCount > 0 ||
                            course.flashcardSetCount > 0 ||
                            course.pdfCount > 0)
                          Text(
                            [
                              if (course.quizCount > 0)
                                '${course.quizCount} quiz${course.quizCount == 1 ? '' : 'zes'}',
                              if (course.flashcardSetCount > 0)
                                '${course.flashcardSetCount} flashcard set${course.flashcardSetCount == 1 ? '' : 's'}',
                              if (course.pdfCount > 0)
                                '${course.pdfCount} PDF${course.pdfCount == 1 ? '' : 's'}',
                            ].join(' • '),
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Module contents - visible when expanded with smooth animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveSizer.cardPaddingFromConstraints(constraints),
                      0,
                      ResponsiveSizer.cardPaddingFromConstraints(constraints),
                      ResponsiveSizer.cardPaddingFromConstraints(constraints),
                    ),
                    child: _buildModuleContents(
                      theme,
                      textTheme,
                      course,
                      constraints,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Builds the contents of a module (quizzes, flashcards, PDFs).
  Widget _buildModuleContents(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    BoxConstraints constraints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // PDFs section
        if (course.pdfs.isNotEmpty) ...<Widget>[
          Text(
            'Study Materials',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          ...course.pdfs.asMap().entries.map<Widget>(
            (MapEntry<int, String> entry) {
              final index = entry.key;
              final pdfPath = entry.value;
              final fileName = pdfPath.split('/').last;
              final pdfName = course.getPdfName(index, pdfPath);

              return _buildModulePdfItem(
                theme,
                textTheme,
                course,
                pdfIndex: index,
                fileName: fileName,
                pdfPath: pdfPath,
                pdfName: pdfName,
                constraints: constraints,
              );
            },
          ),
          SizedBox(
            height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
          ),
        ],
        // Quizzes section
        if (course.quizzes.isNotEmpty) ...<Widget>[
          Text(
            'Quizzes',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          ...course.quizzes.asMap().entries.map<Widget>(
            (MapEntry<int, List<Question>> entry) {
              final index = entry.key;
              final questions = entry.value;
              final quizName = course.getQuizName(index);

              return _buildModuleQuizItem(
                theme,
                textTheme,
                course,
                quizIndex: index,
                quizName: quizName,
                questionCount: questions.length,
                constraints: constraints,
              );
            },
          ),
          SizedBox(
            height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
          ),
        ],
        // Flashcards section
        if (course.flashcards.isNotEmpty) ...<Widget>[
          Text(
            'Flashcards',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          ...course.flashcards.asMap().entries.map<Widget>(
            (MapEntry<int, List<Flashcard>> entry) {
              final index = entry.key;
              final flashcards = entry.value;
              final flashcardSetName = course.getFlashcardSetName(index);

              return _buildModuleFlashcardItem(
                theme,
                textTheme,
                course,
                flashcardSetIndex: index,
                flashcardSetName: flashcardSetName,
                flashcardCount: flashcards.length,
                constraints: constraints,
              );
            },
          ),
        ],
        // Empty state if module has no content
        if (course.quizzes.isEmpty &&
            course.flashcards.isEmpty &&
            course.pdfs.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            child: Center(
              child: Text(
                'No content yet. Add quizzes, flashcards, or PDFs to this module.',
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds an empty state when no modules exist.
  Widget _buildEmptyModulesState(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Empty state message
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_outlined,
              size: ResponsiveSizer.iconSizeFromConstraints(
                constraints,
                multiplier: 4,
              ),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            Text(
              'No modules yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(constraints),
            ),
            Text(
              'Swipe from the left or tap the menu to create your first module',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            // Button to create first module
            FilledButton.icon(
              onPressed: _showCreateCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Module'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 2,
                  ),
                  vertical: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
        ),
        // Content Templates section - also show when no modules exist
        _buildJsonTemplatesSection(theme, textTheme, constraints),
      ],
    );
  }

  /// Builds the content templates section with ready-made prompts for quizzes and flashcards.
  ///
  /// This section provides users with prompts they can use with AI agents
  /// to generate quiz and flashcard content, which they can then paste
  /// directly into the application.
  Widget _buildJsonTemplatesSection(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section header
        Text(
          'Content Templates',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: ResponsiveSizer.spacingFromConstraints(
            constraints,
            multiplier: 1.5,
          ),
        ),
        Text(
          'Generate prompts for AI agents to create quiz and flashcard content. '
          'Select the type and count, then copy the prompt to use with your AI agent. '
          'Paste the generated content directly into the app - no files needed!',
          style: textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(
          height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
        ),
        // Quiz template button with staggered animation
        _buildTemplateButton(
          theme: theme,
          textTheme: textTheme,
          constraints: constraints,
          title: 'Quiz Template',
          icon: Icons.quiz,
          onTap: () => _showQuizPromptDialog(theme, textTheme, constraints),
          animationDelay: 0,
        ),
        SizedBox(
          height: ResponsiveSizer.spacingFromConstraints(
            constraints,
            multiplier: 1.5,
          ),
        ),
        // Flashcard template button with staggered animation
        _buildTemplateButton(
          theme: theme,
          textTheme: textTheme,
          constraints: constraints,
          title: 'Flashcard Template',
          icon: Icons.style,
          onTap: () =>
              _showFlashcardPromptDialog(theme, textTheme, constraints),
          animationDelay: 100,
        ),
      ],
    );
  }

  /// Builds a template button that opens a prompt generation dialog.
  ///
  /// Includes smooth animations for a polished user experience:
  /// - Staggered entrance animation (fade in + slide up)
  /// - Smooth transitions on interaction
  Widget _buildTemplateButton({
    required ThemeData theme,
    required TextTheme textTheme,
    required BoxConstraints constraints,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required int animationDelay,
  }) {
    return _AnimatedTemplateButton(
      delay: Duration(milliseconds: animationDelay),
      child: Card(
        elevation: 0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(constraints),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(
                ResponsiveSizer.cardPaddingFromConstraints(constraints),
              ),
              child: Row(
                children: <Widget>[
                  // Icon
                  Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 1.4,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 1.5,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: ResponsiveSizer.iconSizeFromConstraints(constraints),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a dialog to generate a quiz prompt for AI agents.
  Future<void> _showQuizPromptDialog(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) async {
    // Quiz types
    final quizTypes = <String>[
      'Multiple Choice',
      'True/False',
      'Fill in the Blank',
      'Short Answer',
    ];
    String? selectedType;
    int? count;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final theme = Theme.of(context);
            final textTheme = theme.textTheme;

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                        multiplier: 1.67,
                      ),
                    ),
                  ),
                  title: Text(
                    'Generate Quiz Prompt',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: SizedBox(
                    width: ResponsiveSizer.maxContentWidthFromConstraints(
                      constraints,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Quiz type selection
                        Text(
                          'Quiz Type:',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ),
                        ),
                        ...quizTypes.map<Widget>(
                          (String type) => RadioListTile<String>(
                            title: Text(type),
                            value: type,
                            groupValue: selectedType,
                            onChanged: (String? value) {
                              setState(() {
                                selectedType = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 1.5,
                          ),
                        ),
                        // Count input
                        Text(
                          'Number of Questions:',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter number (1-50)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveSizer.borderRadiusFromConstraints(
                                  constraints,
                                ),
                              ),
                            ),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              count = int.tryParse(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: selectedType != null &&
                              count != null &&
                              count! > 0 &&
                              count! <= 50
                          ? () {
                              Navigator.of(context).pop(<String, dynamic>{
                                'type': selectedType,
                                'count': count,
                              });
                            }
                          : null,
                      child: const Text('Generate'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      final prompt = _generateQuizPrompt(
        result['type'] as String,
        result['count'] as int,
      );
      await Clipboard.setData(ClipboardData(text: prompt));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Show the prompt to the user
        await _showPromptPreview(theme, textTheme, constraints, prompt, 'Quiz');
      }
    }
  }

  /// Shows a dialog to generate a flashcard prompt for AI agents.
  Future<void> _showFlashcardPromptDialog(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) async {
    // Flashcard types
    final flashcardTypes = <String>[
      'Q&A',
      'Definition',
      'Concept Explanation',
      'Term & Definition',
    ];
    String? selectedType;
    int? count;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final theme = Theme.of(context);
            final textTheme = theme.textTheme;

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                        multiplier: 1.67,
                      ),
                    ),
                  ),
                  title: Text(
                    'Generate Flashcard Prompt',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: SizedBox(
                    width: ResponsiveSizer.maxContentWidthFromConstraints(
                      constraints,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Flashcard type selection
                        Text(
                          'Flashcard Type:',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ),
                        ),
                        ...flashcardTypes.map<Widget>(
                          (String type) => RadioListTile<String>(
                            title: Text(type),
                            value: type,
                            groupValue: selectedType,
                            onChanged: (String? value) {
                              setState(() {
                                selectedType = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 1.5,
                          ),
                        ),
                        // Count input
                        Text(
                          'Number of Flashcards:',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter number (1-50)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveSizer.borderRadiusFromConstraints(
                                  constraints,
                                ),
                              ),
                            ),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              count = int.tryParse(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: selectedType != null &&
                              count != null &&
                              count! > 0 &&
                              count! <= 50
                          ? () {
                              Navigator.of(context).pop(<String, dynamic>{
                                'type': selectedType,
                                'count': count,
                              });
                            }
                          : null,
                      child: const Text('Generate'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      final prompt = _generateFlashcardPrompt(
        result['type'] as String,
        result['count'] as int,
      );
      await Clipboard.setData(ClipboardData(text: prompt));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Show the prompt to the user
        await _showPromptPreview(
          theme,
          textTheme,
          constraints,
          prompt,
          'Flashcard',
        );
      }
    }
  }

  /// Shows a preview of the generated prompt.
  Future<void> _showPromptPreview(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
    String prompt,
    String title,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 1.67,
                  ),
                ),
              ),
              title: Text(
                '$title Prompt Generated',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: ResponsiveSizer.maxContentWidthFromConstraints(
                  constraints,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'The prompt has been copied to your clipboard. '
                      'Paste it into your AI agent to generate the content, '
                      'then paste the result back into the app.',
                      style: textTheme.bodyMedium,
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 1.5,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 20,
                        ),
                      ),
                      padding: EdgeInsets.all(
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 1.5,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizer.borderRadiusFromConstraints(
                            constraints,
                          ),
                        ),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          prompt,
                          style: textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Generates a quiz prompt for AI agents based on type and count.
  String _generateQuizPrompt(String type, int count) {
    final typeInstructions = <String, String>{
      'Multiple Choice':
          'Each question should have 4 answer options with one correct answer.',
      'True/False':
          'Each question should have exactly 2 options: "True" and "False".',
      'Fill in the Blank':
          'Each question should have 4 answer options where one is the correct fill-in answer.',
      'Short Answer':
          'Each question should have 4 answer options with one correct short answer.',
    };

    return '''Generate $count ${type.toLowerCase()} quiz questions for a mobile quiz application.

Requirements:
- Generate exactly $count questions
- ${typeInstructions[type] ?? 'Each question should have 4 answer options with one correct answer.'}
- Each question must include an explanation field

Format (array of question objects):
[
  {
    "id": 1,
    "text": "The question text here",
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
    "answerIndex": 0,
    "explanation": "Explanation of why the correct answer is correct"
  },
  ...
]

Field Requirements:
- "id": Sequential number starting from 1
- "text": Clear, concise question text
- "options": Array of exactly 4 strings (or 2 for True/False)
- "answerIndex": Zero-based index (0-3, or 0-1 for True/False) pointing to the correct option
- "explanation": Brief explanation of the correct answer

Return ONLY valid JSON array, no additional text or markdown formatting.''';
  }

  /// Generates a flashcard prompt for AI agents based on type and count.
  String _generateFlashcardPrompt(String type, int count) {
    final typeInstructions = <String, String>{
      'Q&A':
          'Create question and answer pairs where the front is a question and the back is the answer.',
      'Definition':
          'Create definition cards where the front is a term and the back is its definition.',
      'Concept Explanation':
          'Create concept cards where the front is a concept name and the back explains the concept.',
      'Term & Definition':
          'Create term-definition pairs where the front is a term and the back is its definition.',
    };

    return '''Generate $count ${type.toLowerCase()} flashcards for a mobile flashcard application.

Requirements:
- Generate exactly $count flashcards
- ${typeInstructions[type] ?? 'Create question and answer pairs.'}
- Each flashcard should include an explanation field for additional context

Format (array of flashcard objects):
[
  {
    "id": 1,
    "front": "The question, term, or concept on the front of the card",
    "back": "The answer, definition, or explanation on the back of the card",
    "explanation": "Additional context or explanation that helps understand the concept better"
  },
  ...
]

Field Requirements:
- "id": Sequential number starting from 1
- "front": Clear, concise question, term, or concept
- "back": Clear, concise answer, definition, or explanation
- "explanation": Optional additional context that helps understand the concept

Return ONLY valid array format, no additional text or markdown formatting.''';
  }

  /// Builds a PDF item in the module contents view.
  Widget _buildModulePdfItem(
    ThemeData theme,
    TextTheme textTheme,
    Course course, {
    required int pdfIndex,
    required String fileName,
    required String pdfPath,
    required String pdfName,
    required BoxConstraints constraints,
  }) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
        ),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          Icons.picture_as_pdf,
          color: theme.colorScheme.primary,
          size: ResponsiveSizer.iconSizeFromConstraints(constraints),
        ),
        title: Text(
          pdfName,
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          fileName,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.open_in_new,
            size: ResponsiveSizer.iconSizeFromConstraints(constraints),
          ),
          onPressed: () => _viewPdf(pdfPath, pdfName),
          tooltip: 'View PDF',
        ),
      ),
    );
  }

  /// Builds a quiz item in the module contents view.
  Widget _buildModuleQuizItem(
    ThemeData theme,
    TextTheme textTheme,
    Course course, {
    required int quizIndex,
    required String quizName,
    required int questionCount,
    required BoxConstraints constraints,
  }) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
        ),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          Icons.quiz,
          color: theme.colorScheme.primary,
          size: ResponsiveSizer.iconSizeFromConstraints(constraints),
        ),
        title: Text(
          quizName,
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          '$questionCount question${questionCount == 1 ? '' : 's'}',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: FilledButton(
          onPressed: () => _startQuizFromCourse(course, quizIndex),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 0.75,
              ),
            ),
          ),
          child: const Text('Start'),
        ),
      ),
    );
  }

  /// Builds a flashcard item in the module contents view.
  Widget _buildModuleFlashcardItem(
    ThemeData theme,
    TextTheme textTheme,
    Course course, {
    required int flashcardSetIndex,
    required String flashcardSetName,
    required int flashcardCount,
    required BoxConstraints constraints,
  }) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
        ),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          Icons.style,
          color: theme.colorScheme.primary,
          size: ResponsiveSizer.iconSizeFromConstraints(constraints),
        ),
        title: Text(
          flashcardSetName,
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          '$flashcardCount card${flashcardCount == 1 ? '' : 's'}',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: FilledButton(
          onPressed: () =>
              _startFlashcardsFromCourse(course, flashcardSetIndex),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 0.75,
              ),
            ),
          ),
          child: const Text('Study'),
        ),
      ),
    );
  }

  /// Builds the content for a selected course.
  ///
  /// Uses [_selectedCourse] directly to ensure the widget tree always reflects
  /// the current state, preventing Dismissible widget errors.
  Widget _buildCourseContent(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    // Guard against null _selectedCourse (shouldn't happen, but safety first)
    if (_controller.selectedCourse == null) {
      return const SizedBox.shrink();
    }

    final course = _controller.selectedCourse!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.folder,
              color: theme.colorScheme.primary,
              size: ResponsiveSizer.iconSizeFromConstraints(
                constraints,
                multiplier: 1.4,
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
                    course.name,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (course.quizCount > 0 ||
                      course.flashcardSetCount > 0 ||
                      course.pdfCount > 0)
                    Text(
                      [
                        if (course.quizCount > 0)
                          '${course.quizCount} quiz${course.quizCount == 1 ? '' : 'zes'} • ${course.totalQuestionCount} questions',
                        if (course.flashcardSetCount > 0)
                          '${course.flashcardSetCount} flashcard set${course.flashcardSetCount == 1 ? '' : 's'} • ${course.totalFlashcardCount} cards',
                        if (course.pdfCount > 0)
                          '${course.pdfCount} PDF${course.pdfCount == 1 ? '' : 's'}',
                      ].join(' • '),
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
        ),
        if (course.quizzes.isEmpty &&
            course.flashcards.isEmpty &&
            course.pdfs.isEmpty) ...<Widget>[
          _buildEmptyCourseState(theme, textTheme, course, constraints),
        ] else ...<Widget>[
          // PDFs section with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: course.pdfs.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Study Materials',
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
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: course.pdfs.length,
                        onReorder: (int oldIndex, int newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          await _controller.reorderPdfsInCourse(
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final pdfPath = course.pdfs[index];
                          final fileName = pdfPath.split('/').last;

                          return _buildReorderablePdfItem(
                            key: Key('pdf_${course.id}_$index'),
                            theme: theme,
                            textTheme: textTheme,
                            course: course,
                            pdfIndex: index,
                            fileName: fileName,
                            pdfPath: pdfPath,
                            constraints: constraints,
                          );
                        },
                      ),
                      SizedBox(
                        height: ResponsiveSizer.sectionSpacingFromConstraints(
                          constraints,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          // Quizzes section with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: course.quizzes.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Quizzes',
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
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: course.quizzes.length,
                        onReorder: (int oldIndex, int newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          await _controller.reorderQuizzesInCourse(
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final questions = course.quizzes[index];
                          // Create a stable identifier for the quiz based on its content
                          final quizHash = Object.hashAll([
                            course.id,
                            index,
                            ...questions.map((Question q) => q.id),
                            ...questions.map((Question q) => q.text),
                          ]);

                          return _buildReorderableQuizItem(
                            key: Key('quiz_${course.id}_$index'),
                            theme: theme,
                            textTheme: textTheme,
                            course: course,
                            quizIndex: index,
                            questionCount: questions.length,
                            quizHash: quizHash,
                            onTap: () => _startQuizFromCourse(course, index),
                            constraints: constraints,
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          // Flashcards section with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: course.flashcards.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: ResponsiveSizer.sectionSpacingFromConstraints(
                          constraints,
                        ),
                      ),
                      Text(
                        'Flashcards',
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
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: course.flashcards.length,
                        onReorder: (int oldIndex, int newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          await _controller.reorderFlashcardSetsInCourse(
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final flashcards = course.flashcards[index];
                          // Create a stable identifier for the flashcard set
                          final flashcardHash = Object.hashAll([
                            course.id,
                            index,
                            ...flashcards.map((Flashcard f) => f.id),
                            ...flashcards.map((Flashcard f) => f.front),
                          ]);

                          return _buildReorderableFlashcardItem(
                            key: Key('flashcard_${course.id}_$index'),
                            theme: theme,
                            textTheme: textTheme,
                            course: course,
                            flashcardSetIndex: index,
                            flashcardCount: flashcards.length,
                            flashcardHash: flashcardHash,
                            onTap: () =>
                                _startFlashcardsFromCourse(course, index),
                            constraints: constraints,
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
        if (_controller.error != null)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
            ),
            child: Text(
              _controller.error!,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  /// Shows delete confirmation dialog for a PDF.
  Future<void> _confirmDeletePdf(
    Course course,
    int pdfIndex,
    String fileName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 1.67,
                  ),
                ),
              ),
              title: Text(
                'Delete PDF?',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'Are you sure you want to delete "$fileName"? '
                'This action cannot be undone.',
                style: textTheme.bodyMedium,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _deletePdfFromCourse(course, pdfIndex);
    }
  }

  /// Builds a card for a PDF in a course.
  Widget _buildPdfCard(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    int pdfIndex,
    String fileName,
    String pdfPath,
    BoxConstraints constraints,
  ) {
    final pdfName = course.getPdfName(pdfIndex, pdfPath);
    final pdfKey = '${course.id}_$pdfIndex';
    final isExpanded = _expandedPdfs.contains(pdfKey);

    return Container(
      margin: ResponsiveSizer.cardMarginFromConstraints(constraints),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(constraints),
        ),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () => _viewPdf(pdfPath, pdfName),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(constraints),
                ),
                topRight: Radius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(constraints),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveSizer.cardPaddingFromConstraints(constraints),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: ResponsiveSizer.iconContainerSizeFromConstraints(
                        constraints,
                        multiplier: 1.2,
                      ),
                      height: ResponsiveSizer.iconContainerSizeFromConstraints(
                        constraints,
                        multiplier: 1.2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizer.borderRadiusFromConstraints(
                            constraints,
                          ),
                        ),
                        color: theme.colorScheme.errorContainer,
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: theme.colorScheme.onErrorContainer,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          constraints,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 2,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            pdfName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 0.5,
                            ),
                          ),
                          Text(
                            'PDF Document',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit button
                    IconButton(
                      onPressed: () => _showRenameDialog(
                        title: 'Rename PDF',
                        currentName: pdfName,
                        onSave: (String newName) async {
                          await _controller.renamePdf(pdfIndex, newName);
                        },
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          constraints,
                          multiplier: 0.9,
                        ),
                      ),
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      tooltip: 'Rename',
                    ),
                    // Delete button
                    IconButton(
                      onPressed: () => _confirmDeletePdf(
                        course,
                        pdfIndex,
                        pdfName,
                      ),
                      icon: Icon(
                        Icons.delete_outlined,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          constraints,
                          multiplier: 0.9,
                        ),
                      ),
                      color: theme.colorScheme.error,
                      tooltip: 'Delete',
                    ),
                    // Expand/collapse button with animation
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedPdfs.remove(pdfKey);
                          } else {
                            _expandedPdfs.add(pdfKey);
                          }
                        });
                      },
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        turns: isExpanded ? 0.5 : 0.0,
                        child: Icon(
                          Icons.expand_more,
                          size: ResponsiveSizer.iconSizeFromConstraints(
                            constraints,
                            multiplier: 0.9,
                          ),
                        ),
                      ),
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      tooltip: isExpanded ? 'Collapse' : 'Expand',
                    ),
                  ],
                ),
              ),
            ),
            // Animated expandable section for generate buttons
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: isExpanded
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            theme.colorScheme.surfaceContainerHighest,
                            theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                          bottomRight: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                          bottomRight: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveSizer.cardPaddingFromConstraints(
                              constraints,
                            ),
                            vertical: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Divider
                              Container(
                                height: 1,
                                margin: EdgeInsets.only(
                                  bottom:
                                      ResponsiveSizer.spacingFromConstraints(
                                    constraints,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Colors.transparent,
                                      theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Generate Questions button
                              _buildAnimatedActionButton(
                                theme: theme,
                                textTheme: textTheme,
                                constraints: constraints,
                                icon: Icons.auto_awesome,
                                label: 'Generate Questions',
                                isLoading: _controller.isGeneratingQuestions,
                                onPressed: _controller.isGeneratingQuestions
                                    ? null
                                    : () => _generateQuestionsFromPdf(
                                          course,
                                          pdfPath,
                                        ),
                              ),
                              SizedBox(
                                height: ResponsiveSizer.spacingFromConstraints(
                                  constraints,
                                  multiplier: 0.75,
                                ),
                              ),
                              // Generate Flashcards button
                              _buildAnimatedActionButton(
                                theme: theme,
                                textTheme: textTheme,
                                constraints: constraints,
                                icon: Icons.style_outlined,
                                label: 'Generate Flashcards',
                                isLoading: _controller.isGeneratingFlashcards,
                                onPressed: _controller.isGeneratingFlashcards
                                    ? null
                                    : () => _generateFlashcardsFromPdf(
                                          course,
                                          pdfPath,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an animated action button for the expandable PDF section.
  Widget _buildAnimatedActionButton({
    required ThemeData theme,
    required TextTheme textTheme,
    required BoxConstraints constraints,
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              height: ResponsiveSizer.buttonHeightFromConstraints(
                    constraints,
                  ) *
                  0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 0.75,
                  ),
                ),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    theme.colorScheme.surfaceContainerLow,
                    theme.colorScheme.surfaceContainerLow
                        .withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onPressed,
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(
                      constraints,
                      multiplier: 0.75,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 2,
                      ),
                      vertical: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 0.75,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        else
                          Icon(
                            icon,
                            size: ResponsiveSizer.iconSizeFromConstraints(
                              constraints,
                              multiplier: 0.85,
                            ),
                            color: theme.colorScheme.primary,
                          ),
                        SizedBox(
                          width: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            label,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows delete confirmation dialog for a quiz.
  Future<void> _confirmDeleteQuiz(
    Course course,
    int quizIndex,
    String quizName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Quiz?',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$quizName"? '
            'This action cannot be undone.',
            style: textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteQuizFromCourse(course, quizIndex);
    }
  }

  /// Builds a card for a quiz in a course.
  Widget _buildQuizCard(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    int quizIndex,
    int questionCount,
    VoidCallback onTap,
    BoxConstraints constraints,
  ) {
    final quizName = course.getQuizName(quizIndex);
    return Container(
      margin: ResponsiveSizer.cardMarginFromConstraints(constraints),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(constraints),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ResponsiveSizer.borderRadiusFromConstraints(constraints),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveSizer.cardPaddingFromConstraints(constraints),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                    multiplier: 1.2,
                  ),
                  height: ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                    multiplier: 1.2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                      ),
                    ),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 2,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        quizName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 0.5,
                        ),
                      ),
                      Text(
                        '$questionCount question${questionCount == 1 ? '' : 's'}',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  onPressed: () => _showRenameDialog(
                    title: 'Rename Quiz',
                    currentName: quizName,
                    onSave: (String newName) async {
                      await _controller.renameQuiz(quizIndex, newName);
                    },
                  ),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 0.9,
                    ),
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  tooltip: 'Rename',
                ),
                // Delete button
                IconButton(
                  onPressed: () => _confirmDeleteQuiz(
                    course,
                    quizIndex,
                    quizName,
                  ),
                  icon: Icon(
                    Icons.delete_outlined,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 0.9,
                    ),
                  ),
                  color: theme.colorScheme.error,
                  tooltip: 'Delete',
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: ResponsiveSizer.iconSizeFromConstraints(
                    constraints,
                    multiplier: 0.8,
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows delete confirmation dialog for a flashcard set.
  Future<void> _confirmDeleteFlashcardSet(
    Course course,
    int flashcardSetIndex,
    String flashcardSetName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Flashcard Set?',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$flashcardSetName"? '
            'This action cannot be undone.',
            style: textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteFlashcardSetFromCourse(course, flashcardSetIndex);
    }
  }

  /// Builds a card for a flashcard set in a course.
  Widget _buildFlashcardCard(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    int flashcardSetIndex,
    int flashcardCount,
    VoidCallback onTap,
    BoxConstraints constraints,
  ) {
    final flashcardSetName = course.getFlashcardSetName(flashcardSetIndex);
    return Container(
      margin: ResponsiveSizer.cardMarginFromConstraints(constraints),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(constraints),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ResponsiveSizer.borderRadiusFromConstraints(constraints),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveSizer.cardPaddingFromConstraints(constraints),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                    multiplier: 1.2,
                  ),
                  height: ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                    multiplier: 1.2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                      ),
                    ),
                    color: theme.colorScheme.secondaryContainer,
                  ),
                  child: Icon(
                    Icons.style_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 2,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        flashcardSetName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 0.5,
                        ),
                      ),
                      Text(
                        '$flashcardCount flashcard${flashcardCount == 1 ? '' : 's'}',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  onPressed: () => _showRenameDialog(
                    title: 'Rename Flashcard Set',
                    currentName: flashcardSetName,
                    onSave: (String newName) async {
                      await _controller.renameFlashcardSet(
                        flashcardSetIndex,
                        newName,
                      );
                    },
                  ),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 0.9,
                    ),
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  tooltip: 'Rename',
                ),
                // Delete button
                IconButton(
                  onPressed: () => _confirmDeleteFlashcardSet(
                    course,
                    flashcardSetIndex,
                    flashcardSetName,
                  ),
                  icon: Icon(
                    Icons.delete_outlined,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 0.9,
                    ),
                  ),
                  color: theme.colorScheme.error,
                  tooltip: 'Delete',
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: ResponsiveSizer.iconSizeFromConstraints(
                    constraints,
                    multiplier: 0.8,
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Deletes a flashcard set from a course.
  ///
  /// Note: State update should already be done in onDismissed before calling this.
  /// This method performs the async deletion and reloads from storage.
  Future<void> _deleteFlashcardSetFromCourse(
    Course course,
    int flashcardSetIndex,
  ) async {
    _controller.selectCourse(course);
    await _controller.deleteFlashcardSetFromCourse(flashcardSetIndex);
  }

  /// Builds a reorderable PDF item with drag handle for ReorderableListView.
  Widget _buildReorderablePdfItem({
    required Key key,
    required ThemeData theme,
    required TextTheme textTheme,
    required Course course,
    required int pdfIndex,
    required String fileName,
    required String pdfPath,
    required BoxConstraints constraints,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (BuildContext context, BoxConstraints itemConstraints) {
        // Make the entire card draggable
        return ReorderableDragStartListener(
          index: pdfIndex,
          child: _buildPdfCard(
            theme,
            textTheme,
            course,
            pdfIndex,
            fileName,
            pdfPath,
            itemConstraints,
          ),
        );
      },
    );
  }

  /// Builds a reorderable quiz item with drag handle for ReorderableListView.
  Widget _buildReorderableQuizItem({
    required Key key,
    required ThemeData theme,
    required TextTheme textTheme,
    required Course course,
    required int quizIndex,
    required int questionCount,
    required int quizHash,
    required VoidCallback onTap,
    required BoxConstraints constraints,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (BuildContext context, BoxConstraints itemConstraints) {
        // Make the entire card draggable
        return ReorderableDragStartListener(
          index: quizIndex,
          child: _buildQuizCard(
            theme,
            textTheme,
            course,
            quizIndex,
            questionCount,
            onTap,
            itemConstraints,
          ),
        );
      },
    );
  }

  /// Builds a reorderable flashcard item with drag handle for ReorderableListView.
  Widget _buildReorderableFlashcardItem({
    required Key key,
    required ThemeData theme,
    required TextTheme textTheme,
    required Course course,
    required int flashcardSetIndex,
    required int flashcardCount,
    required int flashcardHash,
    required VoidCallback onTap,
    required BoxConstraints constraints,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (BuildContext context, BoxConstraints itemConstraints) {
        // Make the entire card draggable
        return ReorderableDragStartListener(
          index: flashcardSetIndex,
          child: _buildFlashcardCard(
            theme,
            textTheme,
            course,
            flashcardSetIndex,
            flashcardCount,
            onTap,
            itemConstraints,
          ),
        );
      },
    );
  }

  /// Builds the floating action button with dropdown menu for upload options.
  ///
  /// This FAB appears when a course is selected and provides quick access to
  /// upload PDFs, quizzes, and flashcards. The menu expands with smooth animations
  /// following Apple's Human Interface Guidelines with a modern, visually appealing design.
  Widget _buildFloatingActionButton(ThemeData theme, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // Expanded menu items with smooth slide-up and fade animations
        if (_controller.isFabExpanded) ...<Widget>[
          _buildAnimatedFabMenuItem(
            theme: theme,
            textTheme: textTheme,
            icon: Icons.style_outlined,
            label: 'Upload Flashcards',
            isLoading: _controller.isFlashcardLoading,
            delay: 0,
            onTap: _controller.selectedCourse != null
                ? () {
                    _controller.closeFab();
                    _addFlashcardsToCourse(_controller.selectedCourse);
                  }
                : null,
          ),
          SizedBox(
            height: ResponsiveSizer.spacing(context, multiplier: 1.5),
          ),
          _buildAnimatedFabMenuItem(
            theme: theme,
            textTheme: textTheme,
            icon: Icons.upload_file_outlined,
            label: 'Upload Quiz',
            isLoading: _controller.isCustomLoading,
            delay: 50,
            onTap: _controller.selectedCourse != null
                ? () {
                    _controller.closeFab();
                    _addQuizToCourse(_controller.selectedCourse);
                  }
                : null,
          ),
          SizedBox(
            height: ResponsiveSizer.spacing(context, multiplier: 1.5),
          ),
          _buildAnimatedFabMenuItem(
            theme: theme,
            textTheme: textTheme,
            icon: Icons.picture_as_pdf_outlined,
            label: 'Upload PDF',
            isLoading: _controller.isPdfLoading,
            delay: 100,
            onTap: _controller.selectedCourse != null
                ? () {
                    _controller.closeFab();
                    _uploadPdfToCourse(_controller.selectedCourse);
                  }
                : null,
          ),
          SizedBox(
            height: ResponsiveSizer.spacing(context, multiplier: 2),
          ),
        ],
        // Main FAB button with smooth icon transformation
        FloatingActionButton(
          onPressed: () {
            _controller.toggleFab();
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: _controller.isFabExpanded ? 8 : 4,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              _controller.isFabExpanded ? Icons.close : Icons.add,
              key: ValueKey<bool>(_controller.isFabExpanded),
              size: ResponsiveSizer.iconSize(context, multiplier: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds an animated menu item for the FAB dropdown with staggered animation.
  Widget _buildAnimatedFabMenuItem({
    required ThemeData theme,
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required bool isLoading,
    required int delay,
    required VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: _controller.isFabExpanded ? 1.0 : 0.0,
      ),
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildFabMenuItem(
              theme: theme,
              textTheme: textTheme,
              icon: icon,
              label: label,
              isLoading: isLoading,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }

  /// Builds a menu item for the FAB dropdown.
  Widget _buildFabMenuItem({
    required ThemeData theme,
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(
            ResponsiveSizer.borderRadiusFromConstraints(
              constraints,
              multiplier: 2.33,
            ),
          ),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(
                constraints,
                multiplier: 2.33,
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 2.5,
                ),
                vertical: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isLoading)
                    SizedBox(
                      width: ResponsiveSizer.iconSizeFromConstraints(
                        constraints,
                      ),
                      height: ResponsiveSizer.iconSizeFromConstraints(
                        constraints,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      icon,
                      size: ResponsiveSizer.iconSizeFromConstraints(
                        constraints,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                  SizedBox(
                    width: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 1.5,
                    ),
                  ),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the empty state for a course with no quizzes.
  Widget _buildEmptyCourseState(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    BoxConstraints constraints,
  ) {
    return Container(
      padding: ResponsiveSizer.emptyStatePaddingFromConstraints(constraints),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(
            constraints,
            multiplier: 1.67,
          ),
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.quiz_outlined,
            size:
                ResponsiveSizer.emptyStateIconSizeFromConstraints(constraints),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 2,
            ),
          ),
          Text(
            'No quizzes yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(constraints),
          ),
          Text(
            'Paste quiz or flashcard content to add your first content to ${course.name}',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the compact layout for smaller screens (uses drawer).
  Widget _buildCompactLayout(ThemeData theme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          drawer: Drawer(
            width: ResponsiveSizer.sidebarWidthFromConstraints(constraints),
            child: _buildSidebar(theme, constraints),
          ),
          body: Stack(
            children: <Widget>[
              _buildMainContent(theme),
              // Swipe indicator overlay for mobile
              if (_showSwipeIndicator)
                _buildSwipeIndicator(theme, constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.all(
        ResponsiveSizer.cardPaddingFromConstraints(constraints) * 1.5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(
            constraints,
            multiplier: 2.33,
          ),
        ),
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
                  'Text-based',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
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
            'Modern quiz\nexperience',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.25,
            ),
          ),
          Text(
            'Simply paste your quiz or flashcard content and the app '
            'will automatically convert it to the correct format.',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
      ),
      padding: EdgeInsets.all(
        ResponsiveSizer.cardPaddingFromConstraints(constraints),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(
            constraints,
            multiplier: 1.67,
          ),
        ),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.content_paste_outlined,
            color: theme.colorScheme.primary,
            size: ResponsiveSizer.iconSizeFromConstraints(constraints),
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Paste your content',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 0.25,
                  ),
                ),
                Text(
                  'Paste quiz or flashcard content from AI agents or create your own.',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ********************************************************************
/// _AnimatedTemplateButton
/// ********************************************************************
///
/// A widget that provides smooth entrance animations for template buttons.
/// Includes fade-in and slide-up animations with configurable delay for
/// staggered effects.
class _AnimatedTemplateButton extends StatefulWidget {
  const _AnimatedTemplateButton({
    required this.delay,
    required this.child,
  });

  final Duration delay;
  final Widget child;

  @override
  State<_AnimatedTemplateButton> createState() =>
      _AnimatedTemplateButtonState();
}

class _AnimatedTemplateButtonState extends State<_AnimatedTemplateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// ********************************************************************
/// _CreateCourseDialog
/// ********************************************************************
///
/// A beautifully designed dialog for creating a new course.
///
/// This custom dialog follows Apple's Human Interface Guidelines:
///  - Clean, minimal design with generous spacing
///  - Soft rounded corners and subtle shadows
///  - Smooth animations and transitions
///  - Clear visual hierarchy and focus states
///
class _CreateCourseDialog extends StatefulWidget {
  const _CreateCourseDialog({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<_CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends State<_CreateCourseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveSizer.dialogMaxWidthFromConstraints(
                    constraints,
                  ),
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(
                      constraints,
                      multiplier: 1.4,
                    ),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Header section with icon
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveSizer.horizontalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.4,
                        ResponsiveSizer.verticalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.3,
                        ResponsiveSizer.horizontalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.4,
                        ResponsiveSizer.verticalPaddingFromConstraints(
                          constraints,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          // Icon container
                          Container(
                            width: ResponsiveSizer.scaleWidthFromConstraints(
                              constraints,
                              64,
                            ),
                            height: ResponsiveSizer.scaleWidthFromConstraints(
                              constraints,
                              64,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                ResponsiveSizer.borderRadiusFromConstraints(
                                  constraints,
                                  multiplier: 1.5,
                                ),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.8),
                                ],
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: theme.colorScheme.onPrimary,
                              size: ResponsiveSizer.iconSizeFromConstraints(
                                constraints,
                                multiplier: 1.6,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 2.5,
                            ),
                          ),
                          // Title
                          Text(
                            'New Course',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                            ),
                          ),
                          // Subtitle
                          Text(
                            'Give your course a name to get started',
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Input section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Focus(
                        onFocusChange: (bool hasFocus) {
                          setState(() {
                            _isFocused = hasFocus;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isFocused
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                              width: _isFocused ? 2 : 1,
                            ),
                            color: _isFocused
                                ? theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: TextField(
                            controller: widget.controller,
                            autofocus: true,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., Math 101, History, Science',
                              hintStyle: textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            onSubmitted: (String value) {
                              if (value.trim().isNotEmpty) {
                                Navigator.of(context).pop(value.trim());
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 3.5,
                      ),
                    ),
                    // Action buttons
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                        0,
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          // Cancel button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Create button
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () {
                                if (widget.controller.text.trim().isNotEmpty) {
                                  Navigator.of(context)
                                      .pop(widget.controller.text.trim());
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                              ),
                              child: Text(
                                'Create',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ********************************************************************
/// _SettingsDialog
/// ********************************************************************
///
/// A beautifully designed settings dialog following Apple's Human Interface
/// Guidelines:
///  - Clean, minimal design with generous spacing
///  - Soft rounded corners and subtle shadows
///  - Smooth animations and transitions
///  - Clear visual hierarchy and focus states
///
class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late TextEditingController _apiKeyController;
  bool _isFocused = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _loadApiKey();
    _animationController.forward();
  }

  /// Loads the current API key from storage.
  Future<void> _loadApiKey() async {
    final currentKey = await QuestionGeneratorService.getApiKey() ?? '';
    if (mounted) {
      setState(() {
        _apiKeyController.text = currentKey;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveSizer.dialogMaxWidthFromConstraints(
                    constraints,
                  ),
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(
                      constraints,
                      multiplier: 1.4,
                    ),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Header section with icon
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveSizer.horizontalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.4,
                        ResponsiveSizer.verticalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.3,
                        ResponsiveSizer.horizontalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.4,
                        ResponsiveSizer.verticalPaddingFromConstraints(
                          constraints,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          // Title
                          Text(
                            'Settings',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                            ),
                          ),
                          // Subtitle
                          Text(
                            'Manage your app preferences',
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // API Key section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Google AI API Key',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                            ),
                          ),
                          Text(
                            'Required for generating questions from PDFs',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 1.5,
                            ),
                          ),
                          Focus(
                            onFocusChange: (bool hasFocus) {
                              setState(() {
                                _isFocused = hasFocus;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isFocused
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                  width: _isFocused ? 2 : 1,
                                ),
                                color: _isFocused
                                    ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.1)
                                    : theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: _isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : TextField(
                                      controller: _apiKeyController,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Enter your Google AI API key',
                                        hintStyle:
                                            textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                      ),
                                      obscureText: true,
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 1.5,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final url = Uri.parse(
                                'https://makersuite.google.com/app/apikey',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: Icon(
                              Icons.open_in_new,
                              size: ResponsiveSizer.iconSizeFromConstraints(
                                constraints,
                                multiplier: 0.67,
                              ),
                            ),
                            label: const Text('Get API Key'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 3.5,
                      ),
                    ),
                    // Action buttons
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                        0,
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          // Cancel button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save button
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () async {
                                await QuestionGeneratorService.setApiKey(
                                  _apiKeyController.text.trim().isEmpty
                                      ? null
                                      : _apiKeyController.text.trim(),
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Settings saved successfully!',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                              ),
                              child: Text(
                                'Save',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ********************************************************************
/// _SwipeIndicatorArrow
/// ********************************************************************
///
/// An animated arrow indicator that moves from left to right to indicate
/// users can swipe from the left edge to open the menu.
class _SwipeIndicatorArrow extends StatefulWidget {
  const _SwipeIndicatorArrow({required this.theme});

  final ThemeData theme;

  @override
  State<_SwipeIndicatorArrow> createState() => _SwipeIndicatorArrowState();
}

class _SwipeIndicatorArrowState extends State<_SwipeIndicatorArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Slide animation: moves from left (-20) to right (20)
    _slideAnimation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Fade animation: fades in and out for visibility
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.2,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 0.6,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.2,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: widget.theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        );
      },
    );
  }
}
