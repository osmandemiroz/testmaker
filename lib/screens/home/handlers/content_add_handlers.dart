import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/dialogs/dialogs.dart';

/// Handlers for adding content (quizzes and flashcards) to courses.
class ContentAddHandlers {
  /// Shows a dialog to paste quiz content and add it to the selected course.
  static Future<void> addQuizToCourse(
    BuildContext context,
    HomeController controller,
    Course? course,
    bool Function() mounted,
  ) async {
    if (course == null) return;
    controller.selectCourse(course);

    final result = await showTextInputDialog(
      context: context,
      title: 'Add Quiz',
      hint:
          'Paste your quiz content here...\n\nThe app will automatically convert it to the correct format.\n\nYou can paste:\n• Content from AI agents\n• Simple text format',
      label: 'Quiz Content',
    );

    if (result != null && result.isNotEmpty) {
      await controller.addQuizFromText(result);
      if (mounted() && controller.error == null) {
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
              content: Text('Quiz added successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Shows a dialog to paste flashcard content and add it to the selected course.
  static Future<void> addFlashcardsToCourse(
    BuildContext context,
    HomeController controller,
    Course? course,
    bool Function() mounted,
  ) async {
    if (course == null) return;
    controller.selectCourse(course);

    final result = await showTextInputDialog(
      context: context,
      title: 'Add Flashcards',
      hint:
          'Paste your flashcard content here...\n\nThe app will automatically convert it to the correct format.\n\nYou can paste:\n• Content from AI agents\n• Simple text format',
      label: 'Flashcard Content',
    );

    if (result != null && result.isNotEmpty) {
      await controller.addFlashcardsFromText(result);
      if (mounted() && controller.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flashcards added successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
