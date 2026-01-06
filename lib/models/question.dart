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
    required this.answerIndices,
    this.explanation,
  }) : assert(
          answerIndices.length > 0,
          'Question must have at least one correct answer.',
        );

  /// Factory for creating a [Question] from decoded JSON.
  ///
  /// Supports both legacy format (single "answerIndex") and
  /// new format (list of "answerIndices").
  factory Question.fromJson(Map<String, dynamic> json) {
    // Handle options list
    final options = List<String>.from(
      (json['options'] as List<dynamic>).map<String>((dynamic value) {
        return value as String;
      }),
    );

    // Handle answer indices
    final List<int> indices;
    if (json.containsKey('answerIndices')) {
      indices = List<int>.from(json['answerIndices'] as List<dynamic>);
    } else if (json.containsKey('answerIndex')) {
      // Backward compatibility for single-answer legacy JSON
      indices = <int>[json['answerIndex'] as int];
    } else {
      throw const FormatException(
        'Question JSON must contain either answerIndex or answerIndices',
      );
    }

    // Validate indices
    for (final index in indices) {
      if (index < 0 || index >= options.length) {
        throw RangeError(
          'Answer index $index is out of bounds for options length ${options.length}',
        );
      }
    }

    return Question(
      id: json['id'] as int,
      text: json['text'] as String,
      options: options,
      answerIndices: indices,
      explanation: json['explanation'] as String?,
    );
  }

  /// Numeric identifier for the question.
  final int id;

  /// The text/body of the question.
  final String text;

  /// All answer options, in display order.
  final List<String> options;

  /// Indices into [options] for the correct answer(s).
  final List<int> answerIndices;

  /// Compatibility getter for single-answer questions.
  /// Returns the first correct answer index.
  @Deprecated('Use answerIndices instead')
  int get answerIndex => answerIndices.first;

  /// Optional explanation for why the correct answer is correct.
  final String? explanation;

  /// Helper to check if this is a multiple-choice (checkbox) question.
  bool get isMultiSelect => answerIndices.length > 1;

  /// Converts this question back to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'options': options,
      // Always store as answerIndices for consistency going forward
      'answerIndices': answerIndices,
      if (explanation != null) 'explanation': explanation,
    };
  }

  /// Creates a copy of this question with shuffled options.
  Question withShuffledOptions([Random? random]) {
    final rng = random ?? Random();

    // Create a list of indices [0, 1, 2, ...] to track original positions
    final originalIndices = List<int>.generate(options.length, (i) => i);

    // Create pairs of (option, originalIndex)
    final pairs = List.generate(options.length, (i) {
      return MapEntry(options[i], originalIndices[i]);
    })

      // Shuffle the pairs
      ..shuffle(rng);

    // Extract shuffled options and new indices
    final shuffledOptions = pairs.map((e) => e.key).toList();

    // Create a map to find new index from old index
    // current map: new_index -> (option, old_index)
    // we want: old_index -> new_index
    final oldToNewIndex = <int, int>{};
    for (var i = 0; i < pairs.length; i++) {
      oldToNewIndex[pairs[i].value] = i;
    }

    // Map the correct answer indices to their new positions
    final newAnswerIndices = answerIndices
        .map((oldIndex) => oldToNewIndex[oldIndex]!)
        .toList()
      ..sort(); // Sort for consistent comparison

    return Question(
      id: id,
      text: text,
      options: shuffledOptions,
      answerIndices: newAnswerIndices,
      explanation: explanation,
    );
  }

  /// Debug helper for logging.
  @override
  String toString() {
    return 'Question(id: $id, text: $text, options: $options, answerIndices: $answerIndices)';
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

  /// Shuffles only the options within each question, keeping question order intact.
  static List<Question> shuffleOptionsOnly(List<Question> questions) {
    final random = Random();
    return questions
        .map((Question q) => q.withShuffledOptions(random))
        .toList();
  }
}
