import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/items/items.dart';

/// Builds a reorderable PDF item with drag handle for ReorderableListView.
class ReorderablePdfItem extends StatelessWidget {
  const ReorderablePdfItem({
    required this.itemKey,
    required this.theme,
    required this.textTheme,
    required this.controller,
    required this.course,
    required this.pdfIndex,
    required this.fileName,
    required this.pdfPath,
    required this.constraints,
    required this.onViewPdf,
    required this.showRenameDialog,
    required this.onDelete,
    required this.onGenerateQuestions,
    required this.onGenerateFlashcards,
    super.key,
  });

  final Key itemKey;
  final ThemeData theme;
  final TextTheme textTheme;
  final HomeController controller;
  final Course course;
  final int pdfIndex;
  final String fileName;
  final String pdfPath;
  final BoxConstraints constraints;
  final void Function(String pdfPath, String pdfName) onViewPdf;
  final Future<void> Function({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) showRenameDialog;
  final void Function(Course course, int pdfIndex, String pdfName) onDelete;
  final void Function(Course course, String pdfPath) onGenerateQuestions;
  final void Function(Course course, String pdfPath) onGenerateFlashcards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: itemKey,
      builder: (BuildContext context, BoxConstraints itemConstraints) {
        // Make the entire card draggable with long-press
        return ReorderableDelayedDragStartListener(
          index: pdfIndex,
          child: PdfCard(
            theme: theme,
            textTheme: textTheme,
            controller: controller,
            course: course,
            pdfIndex: pdfIndex,
            fileName: fileName,
            pdfPath: pdfPath,
            constraints: itemConstraints,
            onViewPdf: onViewPdf,
            showRenameDialog: showRenameDialog,
            onDelete: onDelete,
            onGenerateQuestions: onGenerateQuestions,
            onGenerateFlashcards: onGenerateFlashcards,
          ),
        );
      },
    );
  }
}

/// Builds a reorderable quiz item with drag handle for ReorderableListView.
class ReorderableQuizItem extends StatelessWidget {
  const ReorderableQuizItem({
    required this.itemKey,
    required this.theme,
    required this.textTheme,
    required this.controller,
    required this.course,
    required this.quizIndex,
    required this.questionCount,
    required this.quizHash,
    required this.onTap,
    required this.showRenameDialog,
    required this.onDelete,
    required this.onShare,
    required this.constraints,
    super.key,
  });

  final Key itemKey;
  final ThemeData theme;
  final TextTheme textTheme;
  final HomeController controller;
  final Course course;
  final int quizIndex;
  final int questionCount;
  final int quizHash;
  final VoidCallback onTap;
  final Future<void> Function({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) showRenameDialog;
  final void Function(Course course, int quizIndex, String quizName) onDelete;
  final VoidCallback onShare;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: itemKey,
      builder: (BuildContext context, BoxConstraints itemConstraints) {
        // Make the entire card draggable with long-press
        return ReorderableDelayedDragStartListener(
          index: quizIndex,
          child: QuizCard(
            theme: theme,
            textTheme: textTheme,
            controller: controller,
            course: course,
            quizIndex: quizIndex,
            questionCount: questionCount,
            onTap: onTap,
            showRenameDialog: showRenameDialog,
            onDelete: onDelete,
            onShare: onShare,
            constraints: itemConstraints,
          ),
        );
      },
    );
  }
}

/// Builds a reorderable flashcard item with drag handle for ReorderableListView.
class ReorderableFlashcardItem extends StatelessWidget {
  const ReorderableFlashcardItem({
    required this.itemKey,
    required this.theme,
    required this.textTheme,
    required this.controller,
    required this.course,
    required this.flashcardSetIndex,
    required this.flashcardCount,
    required this.flashcardHash,
    required this.onTap,
    required this.showRenameDialog,
    required this.onDelete,
    required this.onShare,
    required this.constraints,
    super.key,
  });

  final Key itemKey;
  final ThemeData theme;
  final TextTheme textTheme;
  final HomeController controller;
  final Course course;
  final int flashcardSetIndex;
  final int flashcardCount;
  final int flashcardHash;
  final VoidCallback onTap;
  final Future<void> Function({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) showRenameDialog;
  final void Function(
    Course course,
    int flashcardSetIndex,
    String flashcardSetName,
  ) onDelete;
  final VoidCallback onShare;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: itemKey,
      builder: (BuildContext context, BoxConstraints itemConstraints) {
        // Make the entire card draggable with long-press
        return ReorderableDelayedDragStartListener(
          index: flashcardSetIndex,
          child: FlashcardCard(
            theme: theme,
            textTheme: textTheme,
            controller: controller,
            course: course,
            flashcardSetIndex: flashcardSetIndex,
            flashcardCount: flashcardCount,
            onTap: onTap,
            showRenameDialog: showRenameDialog,
            onDelete: onDelete,
            onShare: onShare,
            constraints: itemConstraints,
          ),
        );
      },
    );
  }
}
