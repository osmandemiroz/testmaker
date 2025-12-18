// ignore_for_file: use_if_null_to_convert_nulls_to_bools, document_ignores

import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/dialogs/dialogs.dart';

/// Handlers for delete confirmation dialogs and deletion operations.
class DeleteHandlers {
  /// Shows delete confirmation dialog for a PDF and deletes it if confirmed.
  static Future<void> confirmDeletePdf(
    BuildContext context,
    HomeController controller,
    Course course,
    int pdfIndex,
    String fileName,
  ) async {
    final confirmed = await showDeletePdfConfirmation(context, fileName);
    if (confirmed == true) {
      controller.selectCourse(course);
      await controller.deletePdfFromCourse(pdfIndex);
    }
  }

  /// Shows delete confirmation dialog for a quiz and deletes it if confirmed.
  static Future<void> confirmDeleteQuiz(
    BuildContext context,
    HomeController controller,
    Course course,
    int quizIndex,
    String quizName,
  ) async {
    final confirmed = await showDeleteQuizConfirmation(context, quizName);
    if (confirmed == true) {
      controller.selectCourse(course);
      await controller.deleteQuizFromCourse(quizIndex);
    }
  }

  /// Shows delete confirmation dialog for a flashcard set and deletes it if confirmed.
  static Future<void> confirmDeleteFlashcardSet(
    BuildContext context,
    HomeController controller,
    Course course,
    int flashcardSetIndex,
    String flashcardSetName,
  ) async {
    final confirmed = await showDeleteFlashcardSetConfirmation(
      context,
      flashcardSetName,
    );
    if (confirmed == true) {
      controller.selectCourse(course);
      await controller.deleteFlashcardSetFromCourse(flashcardSetIndex);
    }
  }
}
