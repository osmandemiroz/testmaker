import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/items/items.dart';
import 'package:testmaker/screens/home/templates/templates.dart';
import 'package:testmaker/screens/home/views/empty_modules_state.dart';
import 'package:testmaker/screens/home/views/module_contents.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the modules view showing all courses with their contents visible.
///
/// This replaces the welcome screen and displays all modules (courses)
/// with their quizzes, flashcards, and PDFs visible by default.
class ModulesView extends StatelessWidget {
  const ModulesView({
    required this.controller,
    required this.expandedModules,
    required this.onToggleModule,
    required this.onSettingsTap,
    required this.onQuizPromptTap,
    required this.onFlashcardPromptTap,
    required this.onViewPdf,
    required this.onStartQuiz,
    required this.onStartFlashcards,
    super.key,
  });

  final HomeController controller;
  final Set<String> expandedModules;
  final void Function(String courseId) onToggleModule;
  final VoidCallback onSettingsTap;
  final VoidCallback onQuizPromptTap;
  final VoidCallback onFlashcardPromptTap;
  final void Function(String pdfPath, String pdfName) onViewPdf;
  final void Function(Course course, int quizIndex) onStartQuiz;
  final void Function(Course course, int flashcardSetIndex) onStartFlashcards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // If no courses exist, show empty state
        if (controller.courses.isEmpty) {
          return EmptyModulesState(
            theme: theme,
            textTheme: textTheme,
            constraints: constraints,
            onCreateModule: onSettingsTap,
            onQuizPromptTap: onQuizPromptTap,
            onFlashcardPromptTap: onFlashcardPromptTap,
          );
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Settings button in upper right corner
                IconButton(
                  onPressed: onSettingsTap,
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
            // List of all modules (courses) with their contents
            ...controller.courses.map<Widget>(
              (Course course) => ModuleCard(
                theme: theme,
                textTheme: textTheme,
                course: course,
                constraints: constraints,
                isExpanded: expandedModules.contains(course.id),
                onToggle: () => onToggleModule(course.id),
                buildContents: () => ModuleContents(
                  theme: theme,
                  textTheme: textTheme,
                  course: course,
                  constraints: constraints,
                  onViewPdf: onViewPdf,
                  onStartQuiz: onStartQuiz,
                  onStartFlashcards: onStartFlashcards,
                ),
              ),
            ),
            SizedBox(
              height:
                  ResponsiveSizer.sectionSpacingFromConstraints(constraints),
            ),
            // Content Templates section for creating quizzes and flashcards
            ContentTemplatesSection(
              onQuizTap: onQuizPromptTap,
              onFlashcardTap: onFlashcardPromptTap,
            ),
          ],
        );
      },
    );
  }
}
