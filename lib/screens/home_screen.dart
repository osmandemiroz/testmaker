// ignore_for_file: use_if_null_to_convert_nulls_to_bools, document_ignores, leading_newlines_in_multiline_strings

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/flashcard_screen.dart';
import 'package:testmaker/screens/home/dialogs/dialogs.dart';
import 'package:testmaker/screens/home/views/views.dart';
import 'package:testmaker/screens/home/widgets/widgets.dart';
import 'package:testmaker/screens/pdf_viewer_screen.dart';
import 'package:testmaker/screens/quiz_screen.dart';
import 'package:testmaker/services/question_generator_service.dart';
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
    await showRenameDialog(
      context: context,
      title: title,
      currentName: currentName,
      onSave: onSave,
    );
  }

  /// Shows a dialog for pasting text content (quiz or flashcard).
  Future<String?> _showTextInputDialog({
    required String title,
    required String hint,
    required String label,
  }) async {
    return showTextInputDialog(
      context: context,
      title: title,
      hint: hint,
      label: label,
    );
  }

  /// Shows a beautifully designed dialog to create a new course.
  Future<void> _showCreateCourseDialog() async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return CreateCourseDialog(controller: textController);
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
        return const SettingsDialog();
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
          ? FabMenu(
              controller: _controller,
              theme: theme,
              textTheme: textTheme,
              onUploadFlashcards: () =>
                  _addFlashcardsToCourse(_controller.selectedCourse),
              onUploadQuiz: () => _addQuizToCourse(_controller.selectedCourse),
              onUploadPdf: () => _uploadPdfToCourse(_controller.selectedCourse),
            )
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
          child: SwipeIndicatorArrow(theme: theme),
        ),
      ),
    );
  }

  /// Builds the sidebar menu for course navigation.
  Widget _buildSidebar(ThemeData theme, BoxConstraints constraints) {
    return Sidebar(
      controller: _controller,
      onCreateCourse: _showCreateCourseDialog,
      onDeleteCourse: _deleteCourse,
      onSelectCourse: (Course? course) {
        _controller
          ..selectCourse(course)
          ..clearError();
      },
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
                    ModulesView(
                      controller: _controller,
                      expandedModules: _expandedModules,
                      onToggleModule: (String courseId) {
                        setState(() {
                          if (_expandedModules.contains(courseId)) {
                            _expandedModules.remove(courseId);
                          } else {
                            _expandedModules.add(courseId);
                          }
                        });
                      },
                      onSettingsTap: _showSettingsDialog,
                      onQuizPromptTap: () => showQuizPromptDialog(
                        context,
                        theme,
                        textTheme,
                        constraints,
                      ),
                      onFlashcardPromptTap: () => showFlashcardPromptDialog(
                        context,
                        theme,
                        textTheme,
                        constraints,
                      ),
                      onViewPdf: _viewPdf,
                      onStartQuiz: _startQuizFromCourse,
                      onStartFlashcards: _startFlashcardsFromCourse,
                    ),
                  ] else ...<Widget>[
                    CourseContentView(
                      controller: _controller,
                      theme: theme,
                      textTheme: textTheme,
                      constraints: constraints,
                      onViewPdf: _viewPdf,
                      showRenameDialog: _showRenameDialog,
                      onDeletePdf: _confirmDeletePdf,
                      onDeleteQuiz: _confirmDeleteQuiz,
                      onDeleteFlashcardSet: _confirmDeleteFlashcardSet,
                      onGenerateQuestions: _generateQuestionsFromPdf,
                      onGenerateFlashcards: _generateFlashcardsFromPdf,
                      buildEmptyCourseState: _buildEmptyCourseState,
                      onStartQuiz: _startQuizFromCourse,
                      onStartFlashcards: _startFlashcardsFromCourse,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows delete confirmation dialog for a PDF.
  Future<void> _confirmDeletePdf(
    Course course,
    int pdfIndex,
    String fileName,
  ) async {
    final confirmed = await showDeletePdfConfirmation(context, fileName);
    if (confirmed == true) {
      await _deletePdfFromCourse(course, pdfIndex);
    }
  }

  /// Shows delete confirmation dialog for a quiz.
  Future<void> _confirmDeleteQuiz(
    Course course,
    int quizIndex,
    String quizName,
  ) async {
    final confirmed = await showDeleteQuizConfirmation(context, quizName);
    if (confirmed == true) {
      await _deleteQuizFromCourse(course, quizIndex);
    }
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

  /// Builds the empty state for a course with no quizzes.
  Widget _buildEmptyCourseState(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    BoxConstraints constraints,
  ) {
    return EmptyCourseState(
      theme: theme,
      textTheme: textTheme,
      course: course,
      constraints: constraints,
    );
  }

  /// Builds the compact layout for smaller screens (uses drawer).
  Widget _buildCompactLayout(ThemeData theme) {
    return CompactLayout(
      controller: _controller,
      theme: theme,
      constraints: BoxConstraints.tightForFinite(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      ),
      showSwipeIndicator: _showSwipeIndicator,
      buildMainContent: _buildMainContent,
      onCreateCourse: _showCreateCourseDialog,
      onDeleteCourse: _deleteCourse,
    );
  }
}
