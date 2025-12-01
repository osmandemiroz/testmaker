import 'package:flutter/foundation.dart';
import 'package:testmaker/models/flashcard.dart';

/// Controller for FlashcardScreen following MVC architecture.
///
/// Handles all business logic for flashcard state management,
/// navigation, and flip animations. The view (FlashcardScreen)
/// should only display data and forward user actions to this controller.
class FlashcardController extends ChangeNotifier {
  FlashcardController(this.flashcards);
  final List<Flashcard> flashcards;
  int _currentIndex = 0;
  final Map<int, bool> _flippedStates = <int, bool>{};

  // Getters
  int get currentIndex => _currentIndex;
  int get totalCards => flashcards.length;
  Flashcard get currentFlashcard => flashcards[_currentIndex];
  bool get isFirstCard => _currentIndex == 0;
  bool get isLastCard => _currentIndex >= flashcards.length - 1;
  double get progress => (_currentIndex + 1) / flashcards.length;

  /// Gets the flip state for a specific card.
  bool isCardFlipped(int index) => _flippedStates[index] ?? false;

  /// Gets the flip state for the current card.
  bool get isCurrentCardFlipped => isCardFlipped(_currentIndex);

  /// Flips the current card.
  void flipCurrentCard() {
    final currentFlipped = isCurrentCardFlipped;
    _flippedStates[_currentIndex] = !currentFlipped;
    notifyListeners();
  }

  /// Moves to the next card.
  void nextCard() {
    if (!isLastCard) {
      _currentIndex += 1;
      notifyListeners();
    }
  }

  /// Moves to the previous card.
  void previousCard() {
    if (!isFirstCard) {
      _currentIndex -= 1;
      notifyListeners();
    }
  }

  /// Moves to a specific card index.
  void goToCard(int index) {
    if (index >= 0 && index < flashcards.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Resets the controller state.
  void reset() {
    _currentIndex = 0;
    _flippedStates.clear();
    notifyListeners();
  }
}
