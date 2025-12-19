import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/home/items/items.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the content for a selected course.
///
/// Uses [selectedCourse] directly to ensure the widget tree always reflects
/// the current state, preventing Dismissible widget errors.
class CourseContentView extends StatelessWidget {
  const CourseContentView({
    required this.controller,
    required this.theme,
    required this.textTheme,
    required this.constraints,
    required this.onViewPdf,
    required this.showRenameDialog,
    required this.onDeletePdf,
    required this.onDeleteQuiz,
    required this.onDeleteFlashcardSet,
    required this.onGenerateQuestions,
    required this.onGenerateFlashcards,
    required this.buildEmptyCourseState,
    required this.onStartQuiz,
    required this.onStartFlashcards,
    super.key,
  });

  final HomeController controller;
  final ThemeData theme;
  final TextTheme textTheme;
  final BoxConstraints constraints;
  final void Function(String pdfPath, String pdfName) onViewPdf;
  final Future<void> Function({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) showRenameDialog;
  final void Function(Course course, int pdfIndex, String pdfName) onDeletePdf;
  final void Function(Course course, int quizIndex, String quizName)
      onDeleteQuiz;
  final void Function(
    Course course,
    int flashcardSetIndex,
    String flashcardSetName,
  ) onDeleteFlashcardSet;
  final void Function(Course course, String pdfPath) onGenerateQuestions;
  final void Function(Course course, String pdfPath) onGenerateFlashcards;
  final void Function(Course course, int quizIndex) onStartQuiz;
  final void Function(Course course, int flashcardSetIndex) onStartFlashcards;
  final Widget Function(
    ThemeData theme,
    TextTheme textTheme,
    Course course,
    BoxConstraints constraints,
  ) buildEmptyCourseState;

  @override
  Widget build(BuildContext context) {
    // Guard against null selectedCourse (shouldn't happen, but safety first)
    if (controller.selectedCourse == null) {
      return const SizedBox.shrink();
    }

    final course = controller.selectedCourse!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /// ─────────────────────────────────────────────────────────────
        /// Course header
        /// Slimmed down to feel lighter and more aligned with
        /// Apple's Human Interface Guidelines while keeping
        /// the exact same information hierarchy.
        /// ─────────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.25,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: ResponsiveSizer.iconContainerSizeFromConstraints(
                  constraints,
                  multiplier: 1.1,
                ),
                height: ResponsiveSizer.iconContainerSizeFromConstraints(
                  constraints,
                  multiplier: 1.1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints),
                  ),
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.25),
                ),
                child: Icon(
                  Icons.folder,
                  color: theme.colorScheme.primary,
                  size: ResponsiveSizer.iconSizeFromConstraints(
                    constraints,
                    multiplier: 1.1,
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 1.4,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course.quizCount > 0 ||
                        course.flashcardSetCount > 0 ||
                        course.pdfCount > 0)
                      Padding(
                        padding: EdgeInsets.only(
                          top: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 0.3,
                          ),
                        ),
                        child: Text(
                          [
                            if (course.quizCount > 0)
                              '${course.quizCount} quiz${course.quizCount == 1 ? '' : 'zes'} • ${course.totalQuestionCount} questions',
                            if (course.flashcardSetCount > 0)
                              '${course.flashcardSetCount} flashcard set${course.flashcardSetCount == 1 ? '' : 's'} • ${course.totalFlashcardCount} cards',
                            if (course.pdfCount > 0)
                              '${course.pdfCount} PDF${course.pdfCount == 1 ? '' : 's'}',
                          ].join(' • '),
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.65),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: ResponsiveSizer.sectionSpacingFromConstraints(constraints)
              .clamp(8.0, 24.0),
        ),
        if (course.quizzes.isEmpty &&
            course.flashcards.isEmpty &&
            course.pdfs.isEmpty) ...<Widget>[
          buildEmptyCourseState(theme, textTheme, course, constraints),
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
                          await controller.reorderPdfsInCourse(
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final pdfPath = course.pdfs[index];
                          final fileName = pdfPath.split('/').last;

                          return ReorderablePdfItem(
                            key: Key('pdf_${course.id}_$index'),
                            itemKey: Key('pdf_${course.id}_$index'),
                            theme: theme,
                            textTheme: textTheme,
                            controller: controller,
                            course: course,
                            pdfIndex: index,
                            fileName: fileName,
                            pdfPath: pdfPath,
                            constraints: constraints,
                            onViewPdf: onViewPdf,
                            showRenameDialog: showRenameDialog,
                            onDelete: onDeletePdf,
                            onGenerateQuestions: onGenerateQuestions,
                            onGenerateFlashcards: onGenerateFlashcards,
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
                          await controller.reorderQuizzesInCourse(
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

                          return ReorderableQuizItem(
                            key: Key('quiz_${course.id}_$index'),
                            itemKey: Key('quiz_${course.id}_$index'),
                            theme: theme,
                            textTheme: textTheme,
                            controller: controller,
                            course: course,
                            quizIndex: index,
                            questionCount: questions.length,
                            quizHash: quizHash,
                            onTap: () => onStartQuiz(course, index),
                            showRenameDialog: showRenameDialog,
                            onDelete: onDeleteQuiz,
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
                          await controller.reorderFlashcardSetsInCourse(
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

                          return ReorderableFlashcardItem(
                            key: Key('flashcard_${course.id}_$index'),
                            itemKey: Key('flashcard_${course.id}_$index'),
                            theme: theme,
                            textTheme: textTheme,
                            controller: controller,
                            course: course,
                            flashcardSetIndex: index,
                            flashcardCount: flashcards.length,
                            flashcardHash: flashcardHash,
                            onTap: () => onStartFlashcards(course, index),
                            showRenameDialog: showRenameDialog,
                            onDelete: onDeleteFlashcardSet,
                            constraints: constraints,
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
        if (controller.error != null)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
            ),
            child: Text(
              controller.error!,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
