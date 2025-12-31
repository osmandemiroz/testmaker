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

  // Changed from single index to a Set to support multiple selections
  final Set<int> _selectedIndices = <int>{};

  bool _revealAnswer = false;
  bool _isTransitioning = false;
  final List<Map<String, dynamic>> _incorrectAnswers = <Map<String, dynamic>>[];

  // Track answers per question index
  // Maps question index to a map containing: selectedIndices (List), revealAnswer
  final Map<int, Map<String, dynamic>> _questionAnswers =
      <int, Map<String, dynamic>>{};

  // Getters
  int get currentIndex => _currentIndex;
  int get score => _score;

  // Public getter returns a list for easier usage in UI
  List<int> get selectedIndices => _selectedIndices.toList()..sort();

  // Deprecated getter for backward compatibility (returns first selected or null)
  int? get selectedIndex =>
      _selectedIndices.isNotEmpty ? _selectedIndices.first : null;

  bool get revealAnswer => _revealAnswer;
  bool get isTransitioning => _isTransitioning;
  List<Map<String, dynamic>> get incorrectAnswers =>
      List.unmodifiable(_incorrectAnswers);
  Question get currentQuestion => questions[_currentIndex];
  bool get isLastQuestion => _currentIndex >= questions.length - 1;
  bool get isFirstQuestion => _currentIndex == 0;
  int get totalQuestions => questions.length;
  double get progress => (_currentIndex + 1) / questions.length;

  /// Handles option selection.
  ///
  /// For single-select questions: selects and reveals immediately (legacy behavior).
  /// For multi-select questions: toggles selection but DOES NOT reveal.
  void selectOption(int index) {
    if (_isTransitioning || _revealAnswer) {
      return;
    }

    if (currentQuestion.isMultiSelect) {
      // Toggle selection for multi-select
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      notifyListeners();
    } else {
      // Single select behavior: select and reveal immediately
      _selectedIndices
        ..clear()
        ..add(index);
      checkAnswer(); // Auto-reveal for single select
    }
  }

  /// Explicitly checks the answer (reveals correctness).
  ///
  /// This is called automatically for single-select questions,
  /// but must be called manually (e.g. via "Check Answer" button) for multi-select.
  bool checkAnswer() {
    if (_isTransitioning || _revealAnswer) {
      return false;
    }

    // Ensure at least one option is selected
    if (_selectedIndices.isEmpty) {
      return false;
    }

    _revealAnswer = true;

    // Check if this question has been answered before to avoid double-counting score
    final wasAlreadyAnswered = _questionAnswers.containsKey(_currentIndex);

    // Store the answer for this question
    _questionAnswers[_currentIndex] = <String, dynamic>{
      'selectedIndices': _selectedIndices.toList(),
      'revealAnswer': true,
    };

    notifyListeners();

    // Only update score and incorrectAnswers if this is the first time answering
    if (!wasAlreadyAnswered) {
      final correctIndices = currentQuestion.answerIndices;
      final selected = selectedIndices; // Sorted list

      // Check for exact match
      // 1. Same number of selected items
      // 2. All selected items are in correct items
      final isCorrect = selected.length == correctIndices.length &&
          selected.every(correctIndices.contains);

      if (isCorrect) {
        _score += 1;
      } else {
        _incorrectAnswers.add(<String, dynamic>{
          'question': currentQuestion,
          'selectedIndices': selected,
        });
      }
    }

    notifyListeners();
    return true;
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

    _selectedIndices.clear();

    if (savedState != null) {
      // Restore previous answer state
      final savedIndices = savedState['selectedIndices'];
      if (savedIndices is List) {
        _selectedIndices.addAll(savedIndices.cast<int>());
      } else if (savedState['selectedIndex'] != null) {
        // Should not happen for new answers but handle legacy in-memory state if mixed
        _selectedIndices.add(savedState['selectedIndex'] as int);
      }

      _revealAnswer = savedState['revealAnswer'] as bool? ?? false;
    } else {
      // No previous answer, reset to unanswered state
      _revealAnswer = false;
    }
    _isTransitioning = false;
  }

  /// Resets the quiz state.
  void reset() {
    _currentIndex = 0;
    _score = 0;
    _selectedIndices.clear();
    _revealAnswer = false;
    _isTransitioning = false;
    _incorrectAnswers.clear();
    _questionAnswers.clear();
    notifyListeners();
  }
}
