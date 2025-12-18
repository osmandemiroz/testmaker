import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/flashcard_screen.dart';
import 'package:testmaker/screens/pdf_viewer_screen.dart';
import 'package:testmaker/screens/quiz_screen.dart';

/// Navigation helper functions for home screen.
class NavigationHandlers {
  /// Opens a PDF viewer for the given PDF path.
  static Future<void> viewPdf(
    BuildContext context,
    String pdfPath,
    String title,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PdfViewerScreen(
          pdfPath: pdfPath,
          title: title,
        ),
      ),
    );
  }

  /// Starts a quiz from a course and quiz index.
  ///
  /// Questions and options are shuffled before starting the quiz to prevent
  /// users from memorizing positions. A new random order is generated each time.
  static Future<void> startQuizFromCourse(
    BuildContext context,
    Course course,
    int quizIndex,
  ) async {
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

  /// Starts a quiz from the given questions.
  ///
  /// Questions and options are shuffled before starting the quiz to prevent
  /// users from memorizing positions. A new random order is generated each time.
  static Future<void> startQuiz(
    BuildContext context,
    List<Question> questions,
  ) async {
    if (questions.isEmpty) {
      return;
    }

    // Shuffle questions and options to prevent memorization
    final shuffledQuestions = QuestionUtils.shuffleQuestions(questions);

    await Navigator.of(context).push(
      _createQuizRoute(shuffledQuestions),
    );
  }

  /// Starts a flashcard session from a course and flashcard set index.
  ///
  /// Flashcards are shuffled before starting to prevent users from memorizing positions.
  static Future<void> startFlashcardsFromCourse(
    BuildContext context,
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

  /// Starts a flashcard session from the given flashcards.
  ///
  /// Flashcards are shuffled before starting to prevent users from memorizing positions.
  static Future<void> startFlashcards(
    BuildContext context,
    List<Flashcard> flashcards,
  ) async {
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
  static Route<void> _createQuizRoute(List<Question> questions) {
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
}
