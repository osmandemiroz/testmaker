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
  int get totalQuestions => questions.length;
  double get progress => (_currentIndex + 1) / questions.length;

  /// Handles option selection and answer validation.
  Future<bool> selectOption(int index) async {
    if (_isTransitioning || _revealAnswer) {
      return false;
    }

    _selectedIndex = index;
    _revealAnswer = true;
    _isTransitioning = true;
    notifyListeners();

    final isCorrect = index == currentQuestion.answerIndex;
    if (isCorrect) {
      _score += 1;
    } else {
      _incorrectAnswers.add(<String, dynamic>{
        'question': currentQuestion,
        'selectedIndex': index,
      });
    }

    notifyListeners();

    // Short pause so the user can see the feedback colors before moving on.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (isLastQuestion) {
      return true; // Quiz complete
    }

    _moveToNextQuestion();
    return false; // Quiz continues
  }

  /// Moves to the next question.
  void _moveToNextQuestion() {
    _currentIndex += 1;
    _selectedIndex = null;
    _revealAnswer = false;
    _isTransitioning = false;
    notifyListeners();
  }

  /// Resets the quiz state.
  void reset() {
    _currentIndex = 0;
    _score = 0;
    _selectedIndex = null;
    _revealAnswer = false;
    _isTransitioning = false;
    _incorrectAnswers.clear();
    notifyListeners();
  }
}
