import 'dart:math';

/// ********************************************************************
/// Question model
/// ********************************************************************
///
/// Represents a single quiz question loaded from JSON.
/// The JSON is intentionally simple so that swapping in a new quiz file
/// is as easy as editing the values in `assets/quizzes/sample_quiz.json`.
///
/// Example JSON object:
/// {
///   "id": 1,
///   "text": "What is 2 + 2?",
///   "options": ["3", "4", "5", "6"],
///   "answerIndex": 1
/// }
///
class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.answerIndex,
  }) : assert(
          answerIndex >= 0 && answerIndex < options.length,
          'answerIndex must point to a valid option.',
        );

  /// Factory for creating a [Question] from decoded JSON.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      text: json['text'] as String,
      options: List<String>.from(
        (json['options'] as List<dynamic>).map<String>((dynamic value) {
          return value as String;
        }),
      ),
      answerIndex: json['answerIndex'] as int,
    );
  }

  /// Numeric identifier for the question.
  final int id;

  /// The text/body of the question.
  final String text;

  /// All answer options, in display order.
  final List<String> options;

  /// Index into [options] for the correct answer.
  final int answerIndex;

  /// Converts this question back to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'options': options,
      'answerIndex': answerIndex,
    };
  }

  /// Creates a copy of this question with shuffled options.
  ///
  /// This method shuffles the options list and updates the answerIndex
  /// to point to the correct answer in the new shuffled order.
  /// This prevents users from memorizing option positions.
  Question withShuffledOptions([Random? random]) {
    final rng = random ?? Random();
    final shuffledOptions = List<String>.from(options);
    final correctAnswer = shuffledOptions[answerIndex];

    // Shuffle the options
    shuffledOptions.shuffle(rng);

    // Find the new index of the correct answer
    final newAnswerIndex = shuffledOptions.indexOf(correctAnswer);

    return Question(
      id: id,
      text: text,
      options: shuffledOptions,
      answerIndex: newAnswerIndex,
    );
  }

  /// Debug helper for logging.
  @override
  String toString() {
    return 'Question(id: $id, text: $text, options: $options, answerIndex: $answerIndex)';
  }
}

/// ********************************************************************
/// Question Utilities
/// ********************************************************************
///
/// Utility functions for working with lists of questions.
///
class QuestionUtils {
  /// Shuffles a list of questions and their options.
  ///
  /// This function:
  /// 1. Shuffles the order of questions
  /// 2. Shuffles the options within each question
  /// 3. Updates answer indices to match the new option order
  ///
  /// This prevents users from memorizing question and option positions.
  /// A new random order is generated each time this is called.
  static List<Question> shuffleQuestions(List<Question> questions) {
    final random = Random();
    final shuffled = questions
        .map((Question q) => q.withShuffledOptions(random))
        .toList()
      ..shuffle(random);
    return shuffled;
  }
}
