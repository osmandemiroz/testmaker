import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/dialogs/dialogs.dart';
import 'package:testmaker/services/question_generator_service.dart';

/// Handlers for PDF content generation (questions and flashcards).
class PdfGenerationHandlers {
  /// Generates questions from a PDF file using the LLM.
  static Future<void> generateQuestionsFromPdf(
    BuildContext context,
    HomeController controller,
    Course course,
    String pdfPath,
    bool Function() mounted,
  ) async {
    // Check if API key is set
    final hasApiKey = await QuestionGeneratorService.hasApiKey();
    if (!hasApiKey) {
      if (!mounted()) return;
      final apiKeySet = await showApiKeyDialog(context);
      if (!apiKeySet) {
        return; // User cancelled
      }
    }

    // Ask for question count
    if (!mounted()) return;
    final questionCount = await showQuestionCountDialog(context);
    if (questionCount == null) {
      return; // User cancelled
    }

    controller.selectCourse(course);
    final success = await controller.generateQuestionsFromPdf(
      pdfPath,
      questionCount,
    );

    if (success && mounted() && controller.error == null) {
      // Show sorting preference dialog
      final preference = await showQuizSortingDialog(context);
      if (preference != null && mounted()) {
        // If the user selected sequential, update the course preference
        if (preference == QuizSortingPreference.sequential) {
          await controller.toggleQuizSortingPreference();
        }
      }

      if (mounted()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Questions generated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Generates flashcards from a PDF file using the LLM.
  static Future<void> generateFlashcardsFromPdf(
    BuildContext context,
    HomeController controller,
    Course course,
    String pdfPath,
    bool Function() mounted,
  ) async {
    // Check if API key is set
    final hasApiKey = await QuestionGeneratorService.hasApiKey();
    if (!hasApiKey) {
      if (!mounted()) return;
      final apiKeySet = await showApiKeyDialog(context);
      if (!apiKeySet) {
        return; // User cancelled
      }
    }

    // Ask for flashcard count
    if (!mounted()) return;
    final flashcardCount = await showFlashcardCountDialog(context);
    if (flashcardCount == null) {
      return; // User cancelled
    }

    controller.selectCourse(course);
    final success = await controller.generateFlashcardsFromPdf(
      pdfPath,
      flashcardCount,
    );

    if (success && mounted()) {
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
}
