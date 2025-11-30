import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/pdf_viewer_screen.dart';
import 'package:testmaker/screens/quiz_screen.dart';
import 'package:testmaker/services/course_service.dart';
import 'package:testmaker/services/pdf_text_extractor.dart';
import 'package:testmaker/services/question_generator_service.dart';
import 'package:testmaker/services/quiz_service.dart';
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
  final QuizService _quizService = const QuizService();
  final CourseService _courseService = CourseService();
  final PdfTextExtractor _pdfTextExtractor = const PdfTextExtractor();
  final QuestionGeneratorService _questionGenerator =
      const QuestionGeneratorService(
    questionCount: 10,
  );

  List<Course> _courses = <Course>[];
  Course? _selectedCourse;
  bool _isLoadingCourses = true;
  bool _isLoading = false;
  bool _isCustomLoading = false;
  bool _isPdfLoading = false;
  bool _isGeneratingQuestions = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadApiKey();
  }

  /// Loads the API key from local storage on app start.
  Future<void> _loadApiKey() async {
    await QuestionGeneratorService.getApiKey();
  }

  /// Loads all courses from local storage.
  ///
  /// Also updates the selected course reference to ensure it points to
  /// the latest data from storage.
  Future<void> _loadCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });

    try {
      final courses = await _courseService.getAllCourses();
      if (mounted) {
        // Update selected course to point to the latest data from storage
        Course? updatedSelectedCourse;
        if (_selectedCourse != null) {
          try {
            updatedSelectedCourse = courses.firstWhere(
              (Course c) => c.id == _selectedCourse!.id,
            );
          } on Exception catch (_) {
            // Selected course was deleted, clear selection
            updatedSelectedCourse = null;
          }
        }

        setState(() {
          _courses = courses;
          _selectedCourse = updatedSelectedCourse;
          _isLoadingCourses = false;
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._loadCourses] Failed to load courses: $e');
      }
      if (mounted) {
        setState(() {
          _isLoadingCourses = false;
        });
      }
    }
  }

  /// Creates a new course with the given name.
  ///
  /// After creation, reloads courses from storage and selects the newly
  /// created course to ensure UI consistency.
  Future<void> _createCourse(String name) async {
    if (name.trim().isEmpty) {
      return;
    }

    try {
      // Create the course and get the returned course object
      final newCourse = await _courseService.createCourse(name.trim());

      // Reload courses from storage to ensure consistency
      if (mounted) {
        await _loadCourses();

        // Find and select the newly created course by ID (more reliable than using last)
        if (mounted && _courses.isNotEmpty) {
          try {
            final createdCourse = _courses.firstWhere(
              (Course c) => c.id == newCourse.id,
            );
            setState(() {
              _selectedCourse = createdCourse;
            });
          } on Exception catch (e) {
            if (kDebugMode) {
              print('[HomeScreen._createCourse] Failed to select course: $e');
            }
            // If course not found (shouldn't happen), select the last one
            if (mounted) {
              setState(() {
                _selectedCourse = _courses.last;
              });
            }
          }
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._createCourse] Failed to create course: $e');
      }
      // Reload courses even on error to ensure UI matches storage
      if (mounted) {
        await _loadCourses();
      }
    }
  }

  /// Shows a beautifully designed dialog to create a new course.
  ///
  /// This dialog follows Apple's Human Interface Guidelines with:
  ///  - Generous padding and spacing
  ///  - Soft rounded corners and subtle shadows
  ///  - Smooth animations and transitions
  ///  - Clear visual hierarchy and focus states
  Future<void> _showCreateCourseDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return _CreateCourseDialog(controller: controller);
      },
    );

    if (result != null && result.isNotEmpty) {
      await _createCourse(result);
    }
  }

  /// Deletes a course from local storage.
  ///
  /// After deletion, reloads courses from storage to ensure UI consistency.
  Future<void> _deleteCourse(Course course) async {
    try {
      await _courseService.deleteCourse(course.id);

      // Reload courses from storage to ensure consistency
      if (mounted) {
        await _loadCourses();

        // Clear selection if the deleted course was selected
        if (mounted && _selectedCourse?.id == course.id) {
          setState(() {
            _selectedCourse = null;
          });
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._deleteCourse] Failed to delete course: $e');
      }
      // Even if deletion fails, reload to ensure UI matches storage
      if (mounted) {
        await _loadCourses();
      }
    }
  }

  /// Uploads a PDF file to the selected course.
  Future<void> _uploadPdfToCourse(Course course) async {
    setState(() {
      _isPdfLoading = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          setState(() {
            _isPdfLoading = false;
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
            _isPdfLoading = false;
          });
        }
        return;
      }

      await _courseService.addPdfToCourse(course.id, filePath);

      // Reload courses to get the updated data.
      await _loadCourses();

      if (mounted) {
        setState(() {
          _isPdfLoading = false;
          _error = null;
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._uploadPdfToCourse] Failed to upload PDF: $e');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Unable to read that PDF file. Please try again.';
        _isPdfLoading = false;
      });
    }
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
  ///
  /// This method extracts text from the PDF, then uses Google's Gemini AI
  /// to generate quiz questions based on the study material content.
  ///
  /// First checks for API key, then prompts for question count.
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

    setState(() {
      _isGeneratingQuestions = true;
      _error = null;
    });

    try {
      // Extract text from PDF (limited to first 10 pages for performance)
      final pdfText = await _pdfTextExtractor.extractTextLimited(pdfPath);

      if (pdfText.isEmpty) {
        throw Exception('No text content found in PDF');
      }

      if (kDebugMode) {
        print(
          '[HomeScreen._generateQuestionsFromPdf] Extracted ${pdfText.length} characters from PDF',
        );
      }

      // Generate questions using LLM with the specified count
      final questions = await _questionGenerator.generateQuestionsFromText(
        pdfText,
        questionCount: questionCount,
      );

      // Add generated questions to the course
      await _courseService.addQuizToCourse(course.id, questions);

      // Reload courses to get the updated data
      await _loadCourses();

      if (mounted) {
        setState(() {
          _isGeneratingQuestions = false;
          _error = null;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully generated ${questions.length} questions!',
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._generateQuestionsFromPdf] Failed: $e');
      }
      if (!mounted) {
        return;
      }

      // Extract a user-friendly error message
      var errorMessage = e.toString();
      if (errorMessage.contains('API key not set')) {
        await _showApiKeyDialog();
        setState(() {
          _isGeneratingQuestions = false;
          _error = null;
        });
        return;
      } else if (errorMessage.contains('No text content found')) {
        errorMessage =
            'Could not extract text from the PDF.\n\nPlease ensure the PDF contains readable text content.';
      } else if (errorMessage.contains('No questions were generated') ||
          errorMessage.contains('Could not parse')) {
        errorMessage =
            'The AI could not generate valid questions.\n\nThis might be because:\n'
            '• The PDF content is too short or unclear\n'
            '• The AI response format was unexpected\n\n'
            'Please try again.';
      }

      setState(() {
        _error = errorMessage;
        _isGeneratingQuestions = false;
      });
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

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                const SizedBox(height: 16),
                TextField(
                  controller: controller..text = currentKey,
                  decoration: InputDecoration(
                    labelText: 'Google AI API Key',
                    hintText: 'Enter your API key',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
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
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Get API Key'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get your free API key from:\nhttps://makersuite.google.com/app/apikey',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Question Count',
                    hintText: 'Enter a number (e.g., 10)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommended: 5-20 questions',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
  Future<void> _deletePdfFromCourse(Course course, String pdfPath) async {
    // Immediately update local state to remove the PDF from the widget tree
    // This prevents the Dismissible widget error
    if (mounted && _selectedCourse?.id == course.id) {
      final updatedPdfs =
          course.pdfs.where((String path) => path != pdfPath).toList();
      setState(() {
        _selectedCourse = course.copyWith(pdfs: updatedPdfs);
      });
    }

    try {
      await _courseService.deletePdfFromCourse(course.id, pdfPath);

      if (mounted) {
        await _loadCourses();
        if (_selectedCourse?.id == course.id) {
          setState(() {
            _selectedCourse = _courses.firstWhere(
              (Course c) => c.id == course.id,
            );
          });
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._deletePdfFromCourse] Failed to delete PDF: $e');
      }
      // Reload courses even on error to ensure UI matches storage
      if (mounted) {
        await _loadCourses();
      }
    }
  }

  /// Deletes a quiz from a course.
  ///
  /// Immediately updates the local state to remove the quiz from the UI,
  /// then performs the async deletion and reloads from storage.
  Future<void> _deleteQuizFromCourse(Course course, int quizIndex) async {
    // Immediately update local state to remove the quiz from the widget tree
    // This prevents the Dismissible widget error
    if (mounted && _selectedCourse?.id == course.id) {
      final updatedQuizzes = <List<Question>>[
        ...course.quizzes.sublist(0, quizIndex),
        ...course.quizzes.sublist(quizIndex + 1),
      ];
      setState(() {
        _selectedCourse = course.copyWith(quizzes: updatedQuizzes);
      });
    }

    try {
      await _courseService.deleteQuizFromCourse(course.id, quizIndex);

      if (mounted) {
        await _loadCourses();
        if (_selectedCourse?.id == course.id) {
          setState(() {
            _selectedCourse = _courses.firstWhere(
              (Course c) => c.id == course.id,
            );
          });
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._deleteQuizFromCourse] Failed to delete quiz: $e');
      }
      // Reload courses even on error to ensure UI matches storage
      if (mounted) {
        await _loadCourses();
      }
    }
  }

  /// Uploads a quiz JSON file to the selected course.
  Future<void> _uploadQuizToCourse(Course course) async {
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

      await _courseService.addQuizToCourse(course.id, questions);

      // Reload courses to get the updated data.
      await _loadCourses();

      if (mounted) {
        setState(() {
          _isCustomLoading = false;
          _error = null;
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(
          '[HomeScreen._uploadQuizToCourse] Failed to upload quiz: $e',
        );
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

  /// Starts the default sample quiz.
  ///
  /// Questions and options are shuffled before starting the quiz to prevent
  /// users from memorizing positions. A new random order is generated each time.
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

      // Shuffle questions and options to prevent memorization
      final shuffledQuestions = QuestionUtils.shuffleQuestions(questions);

      await Navigator.of(context).push(
        _createQuizRoute(shuffledQuestions),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeScreen._startQuiz] Failed to load quiz: $e');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Unable to load the quiz. Please check the JSON file.';
        _isLoading = false;
      });
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isCompact = constraints.maxWidth < 800;

            // On compact screens, use a drawer instead of a sidebar.
            if (isCompact) {
              return _buildCompactLayout(theme);
            }

            // On larger screens, use a persistent sidebar.
            return Row(
              children: <Widget>[
                _buildSidebar(theme, constraints.maxWidth),
                Expanded(
                  child: _buildMainContent(theme),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the sidebar menu for course navigation.
  Widget _buildSidebar(ThemeData theme, double maxWidth) {
    final textTheme = theme.textTheme;
    final sidebarWidth = (maxWidth * 0.25).clamp(240.0, 320.0);

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
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCourse = null;
                  _error = null;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
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
                    const SizedBox(height: 4),
                    Text(
                      'Your courses',
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // Course list
          Expanded(
            child: _isLoadingCourses
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _courses.isEmpty
                    ? _buildEmptyCoursesState(theme, textTheme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _courses.length,
                        itemBuilder: (BuildContext context, int index) {
                          final course = _courses[index];
                          final isSelected = _selectedCourse?.id == course.id;

                          return _buildCourseItemWithSwipe(
                            theme,
                            textTheme,
                            course,
                            isSelected,
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          // Add course button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _showCreateCourseDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New Course'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outlined,
          color: theme.colorScheme.onError,
          size: 24,
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        // Show confirmation dialog before deleting
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
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCourse = course;
          _error = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.folder_outlined,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    course.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state when no courses exist.
  Widget _buildEmptyCoursesState(ThemeData theme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No courses yet',
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_selectedCourse == null) ...<Widget>[
                _buildWelcomeContent(theme, textTheme),
              ] else ...<Widget>[
                _buildCourseContent(theme, textTheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the welcome content when no course is selected.
  Widget _buildWelcomeContent(ThemeData theme, TextTheme textTheme) {
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
                  const SizedBox(height: 8),
                  Text(
                    'Create and take beautiful, focused quizzes.',
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
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Hero(
          tag: 'quiz-card',
          child: _buildHeroCard(theme, textTheme),
        ),
        const SizedBox(height: 24),
        _buildUploadArea(theme, textTheme),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 24),
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
              disabledForegroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      'Start Sample Quiz',
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
    );
  }

  /// Builds the content for a selected course.
  ///
  /// Uses [_selectedCourse] directly to ensure the widget tree always reflects
  /// the current state, preventing Dismissible widget errors.
  Widget _buildCourseContent(
    ThemeData theme,
    TextTheme textTheme,
  ) {
    // Guard against null _selectedCourse (shouldn't happen, but safety first)
    if (_selectedCourse == null) {
      return const SizedBox.shrink();
    }

    final course = _selectedCourse!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.folder,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
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
                  if (course.quizCount > 0 || course.pdfCount > 0)
                    Text(
                      [
                        if (course.quizCount > 0)
                          '${course.quizCount} quiz${course.quizCount == 1 ? '' : 'zes'} • ${course.totalQuestionCount} questions',
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
        const SizedBox(height: 24),
        if (course.quizzes.isEmpty && course.pdfs.isEmpty) ...<Widget>[
          _buildEmptyCourseState(theme, textTheme, course),
        ] else ...<Widget>[
          // PDFs section
          if (course.pdfs.isNotEmpty) ...<Widget>[
            Text(
              'Study Materials',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...course.pdfs.asMap().entries.map<Widget>(
              (MapEntry<int, String> entry) {
                final pdfIndex = entry.key;
                final pdfPath = entry.value;
                final fileName = pdfPath.split('/').last;

                return Column(
                  children: <Widget>[
                    _buildPdfCardWithSwipe(
                      theme,
                      textTheme,
                      course,
                      pdfIndex,
                      fileName,
                      pdfPath,
                    ),
                    // Generate questions button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: _isGeneratingQuestions
                              ? null
                              : () =>
                                  _generateQuestionsFromPdf(course, pdfPath),
                          icon: _isGeneratingQuestions
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.auto_awesome, size: 16),
                          label: Text(
                            _isGeneratingQuestions
                                ? 'Generating...'
                                : 'Generate Questions',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          // Quizzes section
          if (course.quizzes.isNotEmpty) ...<Widget>[
            Text(
              'Quizzes',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...course.quizzes.asMap().entries.map<Widget>(
              (MapEntry<int, List<Question>> entry) {
                final quizIndex = entry.key;
                final questions = entry.value;

                return _buildQuizCardWithSwipe(
                  theme,
                  textTheme,
                  course,
                  quizIndex,
                  questions.length,
                  () => _startQuizFromCourse(course, quizIndex),
                );
              },
            ),
          ],
        ],
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed:
                      _isPdfLoading ? null : () => _uploadPdfToCourse(course),
                  icon: _isPdfLoading
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
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(_isPdfLoading ? 'Uploading...' : 'Upload PDF'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isCustomLoading
                      ? null
                      : () => _uploadQuizToCourse(course),
                  icon: _isCustomLoading
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
                      : const Icon(Icons.upload_file_outlined),
                  label:
                      Text(_isCustomLoading ? 'Uploading...' : 'Upload Quiz'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a card for a PDF in a course with swipe-to-delete.
  Widget _buildPdfCardWithSwipe(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    int pdfIndex,
    String fileName,
    String pdfPath,
  ) {
    return Dismissible(
      key: Key('pdf_${course.id}_$pdfIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outlined,
          color: theme.colorScheme.onError,
          size: 24,
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
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

        return confirmed ?? false;
      },
      onDismissed: (DismissDirection direction) {
        _deletePdfFromCourse(course, pdfPath);
      },
      child: _buildPdfCard(theme, textTheme, pdfIndex, fileName, pdfPath),
    );
  }

  /// Builds a card for a PDF in a course.
  Widget _buildPdfCard(
    ThemeData theme,
    TextTheme textTheme,
    int pdfIndex,
    String fileName,
    String pdfPath,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _viewPdf(pdfPath, fileName),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.errorContainer,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        fileName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a card for a quiz in a course with swipe-to-delete.
  Widget _buildQuizCardWithSwipe(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    int quizIndex,
    int questionCount,
    VoidCallback onTap,
  ) {
    return Dismissible(
      key: Key('quiz_${course.id}_$quizIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outlined,
          color: theme.colorScheme.onError,
          size: 24,
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
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
                'Are you sure you want to delete Quiz ${quizIndex + 1}? '
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

        return confirmed ?? false;
      },
      onDismissed: (DismissDirection direction) {
        _deleteQuizFromCourse(course, quizIndex);
      },
      child: _buildQuizCard(theme, textTheme, quizIndex, questionCount, onTap),
    );
  }

  /// Builds a card for a quiz in a course.
  Widget _buildQuizCard(
    ThemeData theme,
    TextTheme textTheme,
    int quizIndex,
    int questionCount,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Quiz ${quizIndex + 1}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the empty state for a course with no quizzes.
  Widget _buildEmptyCourseState(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.quiz_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No quizzes yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a JSON file to add your first quiz to ${course.name}',
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
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: Drawer(
        width: 280,
        child: _buildSidebar(theme, 280),
      ),
      body: _buildMainContent(theme),
    );
  }

  Widget _buildHeroCard(ThemeData theme, TextTheme textTheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.all(24),
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

  Widget _buildUploadArea(ThemeData theme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
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
        ],
      ),
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
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
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
                  child: Column(
                    children: <Widget>[
                      // Icon container
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
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
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'New Course',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
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
                const SizedBox(height: 28),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Row(
                    children: <Widget>[
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
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
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
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
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 8),
                      Text(
                        'Required for generating questions from PDFs',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                    hintText: 'Enter your Google AI API key',
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
                                  obscureText: true,
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                        icon: const Icon(Icons.open_in_new, size: 16),
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
                const SizedBox(height: 28),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Row(
                    children: <Widget>[
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
          ),
        ),
      ),
    );
  }
}
