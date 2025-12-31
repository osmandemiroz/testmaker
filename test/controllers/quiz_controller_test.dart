import 'package:flutter_test/flutter_test.dart';
import 'package:testmaker/controllers/quiz_controller.dart';
import 'package:testmaker/models/question.dart';

void main() {
  group('QuizController', () {
    late QuizController controller;
    late List<Question> questions;

    setUp(() {
      questions = [
        Question(
          id: 1,
          text: 'Single Answer Question',
          options: ['A', 'B', 'C', 'D'],
          answerIndices: [1], // B
        ),
        Question(
          id: 2,
          text: 'Multiple Answer Question',
          options: ['A', 'B', 'C', 'D'],
          answerIndices: [0, 2], // A and C
        ),
      ];

      controller = QuizController(questions);
    });

    test('Initial state is correct', () {
      expect(controller.currentIndex, 0);
      expect(controller.score, 0);
      expect(controller.selectedIndices, isEmpty);
      expect(controller.revealAnswer, false);
    });

    test('Single select question behaves correctly', () {
      // Create controller with single question
      controller = QuizController([questions[0]])

        // Select wrong answer
        ..selectOption(0);
      expect(controller.selectedIndices, [0]);
      expect(controller.revealAnswer, true); // Should auto-reveal
      expect(controller.score, 0);

      // Reset
      controller.reset();
      expect(controller.score, 0);

      // Select correct answer
      controller.selectOption(1);
      expect(controller.selectedIndices, [1]);
      expect(controller.revealAnswer, true);
      expect(controller.score, 1);
    });

    test('Multi select question selection toggles correctly', () {
      // Move to multi select question
      controller = QuizController([questions[1]])

        // Select first option
        ..selectOption(0);
      expect(controller.selectedIndices, [0]);
      expect(controller.revealAnswer, false); // Should NOT auto-reveal

      // Select third option
      controller.selectOption(2);
      expect(controller.selectedIndices, [0, 2]);
      expect(controller.revealAnswer, false);

      // Deselect first option
      controller.selectOption(0);
      expect(controller.selectedIndices, [2]);
      expect(controller.revealAnswer, false);
    });

    test('Multi select question checkAnswer scoring', () {
      controller = QuizController([questions[1]])

        // minimal selection (incomplete)
        ..selectOption(0) // Correct
        ..checkAnswer();
      expect(controller.revealAnswer, true);
      expect(controller.score, 0); // Partial credit not implemented/requested?
      // Based on implementation: exact match required.

      controller
        ..reset()

        // correct selection

        ..selectOption(0) // A
        ..selectOption(2) // C
        ..checkAnswer();
      expect(controller.revealAnswer, true);
      expect(controller.score, 1);

      controller
        ..reset()

        // incorrect selection (extra wrong option)
        ..selectOption(0) // A
        ..selectOption(2) // C
        ..selectOption(1) // B (Wrong)
        ..checkAnswer();
      expect(controller.revealAnswer, true);
      expect(controller.score, 0);
    });

    test('Navigation saves state', () {
      // Answer first question correctly
      controller.selectOption(1);
      expect(controller.score, 1);

      // Move next
      controller.moveToNextQuestion();
      expect(controller.currentIndex, 1);
      expect(controller.selectedIndices, isEmpty);
      expect(controller.revealAnswer, false);

      // Move back
      controller.moveToPreviousQuestion();
      expect(controller.currentIndex, 0);
      expect(controller.selectedIndices, [1]);
      expect(controller.revealAnswer, true);
    });
  });
}
