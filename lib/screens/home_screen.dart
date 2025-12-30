// ignore_for_file: use_if_null_to_convert_nulls_to_bools, document_ignores, leading_newlines_in_multiline_strings

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:testmaker/controllers/auth_controller.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/auth/auth_screen.dart';
import 'package:testmaker/screens/home/dialogs/dialogs.dart';
import 'package:testmaker/screens/home/handlers/handlers.dart';
import 'package:testmaker/screens/home/views/views.dart';
import 'package:testmaker/screens/home/widgets/widgets.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

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
  late final AuthController _authController;
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
    _authController = AuthController();
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
    _authController.dispose();
    super.dispose();
  }

  /// Handles user logout
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authController.signOut();
      if (mounted) {
        // Navigate to auth screen
        await Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Use ResponsiveSizer to determine if we should use compact layout
          final isCompact =
              ResponsiveSizer.isCompactFromConstraints(constraints);

          // On compact screens, use a drawer instead of a sidebar.
          if (isCompact) {
            return _buildCompactLayout(theme);
          }

          // On larger screens, use a persistent sidebar.
          // Sidebar extends to the very top and bottom of the screen
          return Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Sidebar(
                    controller: _controller,
                    currentUser: _authController.user,
                    onLogout: _handleLogout,
                    onCreateCourse: () async {
                      if (!mounted) return;
                      final result =
                          await DialogHandlers.showCreateCourseDialog(
                        context,
                      );
                      if (result != null && result.isNotEmpty) {
                        await CourseManagementHandlers.createCourse(
                          _controller,
                          result,
                        );
                      }
                    },
                    onDeleteCourse: (Course course) =>
                        CourseManagementHandlers.deleteCourse(
                      _controller,
                      course,
                    ),
                    onSelectCourse: (Course? course) {
                      _controller
                        ..selectCourse(course)
                        ..clearError();
                    },
                  ),
                  Expanded(
                    // Main content extends to the very top and bottom
                    // Container with background color extends edge-to-edge
                    child: ColoredBox(
                      color: theme.colorScheme.surface,
                      child: _buildMainContent(theme),
                    ),
                  ),
                ],
              ),
              // Swipe indicator overlay
              if (_showSwipeIndicator) _buildSwipeIndicator(theme, constraints),
            ],
          );
        },
      ),
      floatingActionButton: _controller.selectedCourse != null
          ? FabMenu(
              controller: _controller,
              theme: theme,
              textTheme: textTheme,
              onUploadFlashcards: () =>
                  ContentAddHandlers.addFlashcardsToCourse(
                context,
                _controller,
                _controller.selectedCourse,
                () => mounted,
              ),
              onUploadQuiz: () => ContentAddHandlers.addQuizToCourse(
                context,
                _controller,
                _controller.selectedCourse,
                () => mounted,
              ),
              onUploadPdf: () => CourseManagementHandlers.uploadPdfToCourse(
                _controller,
                _controller.selectedCourse,
              ),
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

  /// Builds the main content area.
  Widget _buildMainContent(ThemeData theme) {
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Get top padding to position content below the status bar
        // while keeping the background extending to the very top
        final topPadding = MediaQuery.of(context).padding.top;
        final contentPadding =
            ResponsiveSizer.paddingFromConstraints(constraints);

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: topPadding + contentPadding.vertical,
            bottom: contentPadding.vertical,
            left: contentPadding.horizontal,
            right: contentPadding.horizontal,
          ),
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
                      onSettingsTap: () =>
                          DialogHandlers.showSettingsDialog(context),
                      onCreateModule: () async {
                        // Mirror the same create-course (module) flow used
                        // in the sidebar and compact layout so behavior
                        // stays consistent across the app.
                        if (!mounted) return;
                        final result =
                            await DialogHandlers.showCreateCourseDialog(
                          context,
                        );
                        if (result != null && result.isNotEmpty) {
                          await CourseManagementHandlers.createCourse(
                            _controller,
                            result,
                          );
                        }
                      },
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
                      onViewPdf: (String pdfPath, String title) =>
                          NavigationHandlers.viewPdf(context, pdfPath, title),
                      onStartQuiz: (Course course, int quizIndex) =>
                          NavigationHandlers.startQuizFromCourse(
                        context,
                        course,
                        quizIndex,
                      ),
                      onStartFlashcards:
                          (Course course, int flashcardSetIndex) =>
                              NavigationHandlers.startFlashcardsFromCourse(
                        context,
                        course,
                        flashcardSetIndex,
                      ),
                    ),
                  ] else ...<Widget>[
                    CourseContentView(
                      controller: _controller,
                      theme: theme,
                      textTheme: textTheme,
                      constraints: constraints,
                      onViewPdf: (String pdfPath, String title) =>
                          NavigationHandlers.viewPdf(context, pdfPath, title),
                      showRenameDialog: ({
                        required String title,
                        required String currentName,
                        required Future<void> Function(String) onSave,
                      }) =>
                          DialogHandlers.showRenameDialog(
                        context: context,
                        title: title,
                        currentName: currentName,
                        onSave: onSave,
                      ),
                      onDeletePdf:
                          (Course course, int pdfIndex, String fileName) =>
                              DeleteHandlers.confirmDeletePdf(
                        context,
                        _controller,
                        course,
                        pdfIndex,
                        fileName,
                      ),
                      onDeleteQuiz:
                          (Course course, int quizIndex, String quizName) =>
                              DeleteHandlers.confirmDeleteQuiz(
                        context,
                        _controller,
                        course,
                        quizIndex,
                        quizName,
                      ),
                      onDeleteFlashcardSet: (
                        Course course,
                        int flashcardSetIndex,
                        String flashcardSetName,
                      ) =>
                          DeleteHandlers.confirmDeleteFlashcardSet(
                        context,
                        _controller,
                        course,
                        flashcardSetIndex,
                        flashcardSetName,
                      ),
                      onGenerateQuestions: (Course course, String pdfPath) =>
                          PdfGenerationHandlers.generateQuestionsFromPdf(
                        context,
                        _controller,
                        course,
                        pdfPath,
                        () => mounted,
                      ),
                      onGenerateFlashcards: (Course course, String pdfPath) =>
                          PdfGenerationHandlers.generateFlashcardsFromPdf(
                        context,
                        _controller,
                        course,
                        pdfPath,
                        () => mounted,
                      ),
                      buildEmptyCourseState: _buildEmptyCourseState,
                      onStartQuiz: (Course course, int quizIndex) =>
                          NavigationHandlers.startQuizFromCourse(
                        context,
                        course,
                        quizIndex,
                      ),
                      onStartFlashcards:
                          (Course course, int flashcardSetIndex) =>
                              NavigationHandlers.startFlashcardsFromCourse(
                        context,
                        course,
                        flashcardSetIndex,
                      ),
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
      currentUser: _authController.user,
      onLogout: _handleLogout,
      onCreateCourse: () async {
        if (!mounted) return;
        final result = await DialogHandlers.showCreateCourseDialog(context);
        if (result != null && result.isNotEmpty) {
          await CourseManagementHandlers.createCourse(
            _controller,
            result,
          );
        }
      },
      onDeleteCourse: (Course course) => CourseManagementHandlers.deleteCourse(
        _controller,
        course,
      ),
    );
  }
}
