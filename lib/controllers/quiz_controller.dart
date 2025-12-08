import 'package:flutter/foundation.dart';
import 'package:testmaker/models/question.dart';

/// Controller for QuizScreen following MVC architecture.
///
/// Handles all business logic for quiz state management, scoring,
/// and navigation. The view (QuizScreen) should only display data
/// and forward user actions to this controller.
class QuizController extends ChangeNotifier {
  QuizController(this.questions);
  final List<Question> questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _revealAnswer = false;
  bool _isTransitioning = false;
  final List<Map<String, dynamic>> _incorrectAnswers = <Map<String, dynamic>>[];

  // Track answers per question index
  // Maps question index to a map containing: selectedIndex, revealAnswer
  final Map<int, Map<String, dynamic>> _questionAnswers = <int, Map<String, dynamic>>{};

  // Getters
  int get currentIndex => _currentIndex;
  int get score => _score;
  int? get selectedIndex => _selectedIndex;
  bool get revealAnswer => _revealAnswer;
  bool get isTransitioning => _isTransitioning;
  List<Map<String, dynamic>> get incorrectAnswers =>
      List.unmodifiable(_incorrectAnswers);
  Question get currentQuestion => questions[_currentIndex];
  bool get isLastQuestion => _currentIndex >= questions.length - 1;
  bool get isFirstQuestion => _currentIndex == 0;
  int get totalQuestions => questions.length;
  double get progress => (_currentIndex + 1) / questions.length;

  /// Handles option selection and answer validation.
  ///
  /// Records the selected answer and reveals correctness, but does NOT
  /// automatically move to the next question. The user must swipe to proceed.
  bool selectOption(int index) {
    if (_isTransitioning || _revealAnswer) {
      return false;
    }

    _selectedIndex = index;
    _revealAnswer = true;

    // Check if this question has been answered before to avoid double-counting score
    final wasAlreadyAnswered = _questionAnswers.containsKey(_currentIndex);

    // Store the answer for this question
    _questionAnswers[_currentIndex] = <String, dynamic>{
      'selectedIndex': index,
      'revealAnswer': true,
    };

    notifyListeners();

    // Only update score and incorrectAnswers if this is the first time answering
    if (!wasAlreadyAnswered) {
      final isCorrect = index == currentQuestion.answerIndex;
      if (isCorrect) {
        _score += 1;
      } else {
        _incorrectAnswers.add(<String, dynamic>{
          'question': currentQuestion,
          'selectedIndex': index,
        });
      }
    }

    notifyListeners();
    return false; // Quiz continues (user must swipe to move on)
  }

  /// Moves to the next question.
  ///
  /// Should be called when the user swipes to proceed after selecting an answer.
  /// Returns true if the quiz is complete after moving to the next question.
  bool moveToNextQuestion() {
    if (isLastQuestion) {
      return true; // Quiz complete
    }

    _currentIndex += 1;
    _loadQuestionState();
    notifyListeners();
    return false; // Quiz continues
  }

  /// Moves to the previous question.
  ///
  /// Should be called when the user swipes back. Can be called even if
  /// the current question hasn't been answered yet.
  void moveToPreviousQuestion() {
    if (isFirstQuestion) {
      return; // Already at first question
    }

    _currentIndex -= 1;
    _loadQuestionState();
    notifyListeners();
  }

  /// Loads the state for the current question from stored answers.
  ///
  /// If the question has been answered before, restores the selected index
  /// and reveal state. Otherwise, resets to unanswered state.
  void _loadQuestionState() {
    final savedState = _questionAnswers[_currentIndex];
    if (savedState != null) {
      // Restore previous answer state
      _selectedIndex = savedState['selectedIndex'] as int?;
      _revealAnswer = savedState['revealAnswer'] as bool? ?? false;
    } else {
      // No previous answer, reset to unanswered state
      _selectedIndex = null;
      _revealAnswer = false;
    }
    _isTransitioning = false;
  }

  /// Resets the quiz state.
  void reset() {
    _currentIndex = 0;
    _score = 0;
    _selectedIndex = null;
    _revealAnswer = false;
    _isTransitioning = false;
    _incorrectAnswers.clear();
    _questionAnswers.clear();
    notifyListeners();
  }
}
