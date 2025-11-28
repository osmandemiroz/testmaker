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

  /// Debug helper for logging.
  @override
  String toString() {
    return 'Question(id: $id, text: $text, options: $options, answerIndex: $answerIndex)';
  }
}
