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
      _createStandardRoute<void>(
        PdfViewerScreen(
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
  ///
  /// Passes course and quiz information to QuizScreen so results can be saved.
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

    // Respect sorting preference:
    // - random: shuffle questions AND options
    // - sequential: shuffle only options, keep question order
    final shuffledQuestions =
        course.quizSortingPreference == QuizSortingPreference.random
            ? QuestionUtils.shuffleQuestions(questions)
            : QuestionUtils.shuffleOptionsOnly(questions);

    // Get quiz name (custom or default)
    final quizName = course.getQuizName(quizIndex);

    await Navigator.of(context).push(
      _createQuizRouteFromCourse(
        shuffledQuestions,
        courseId: course.id,
        quizIndex: quizIndex,
        quizName: quizName,
      ),
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
      _createStandardRoute<void>(
        FlashcardScreen(
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
      _createStandardRoute<void>(
        FlashcardScreen(
          flashcards: shuffledFlashcards,
        ),
      ),
    );
  }

  /// Standard Cupertino-inspired page route used for most screen transitions.
  ///
  ///  - Uses a gentle fade + upward slide, matching Apple's Human Interface
  ///    Guidelines emphasis on smooth, subtle motion.
  ///  - Keeps timings and curves aligned with quiz transitions so navigation
  ///    feels cohesive across the whole app.
  static Route<T> _createStandardRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return page;
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        // Slide the new page up very slightly while fading it in, similar to
        // iOS card‑style presentations.
        final slideCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(slideCurve);

        final fadeCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: fadeCurve,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
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

  /// Custom route for quiz from course (includes course/quiz metadata for saving results).
  static Route<void> _createQuizRouteFromCourse(
    List<Question> questions, {
    required String courseId,
    required int quizIndex,
    required String quizName,
  }) {
    return PageRouteBuilder<void>(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return QuizScreen(
          questions: questions,
          courseId: courseId,
          quizIndex: quizIndex,
          quizName: quizName,
        );
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
