/// ********************************************************************
/// QuizResult model
/// ********************************************************************
///
/// Represents a single quiz attempt/result that can be stored and analyzed.
///
/// This model tracks:
///  - Which course and quiz was taken
///  - Score and percentage achieved
///  - Timestamp of the attempt
///  - Optional duration of the quiz
///
/// All quiz results are persisted locally using SharedPreferences
/// and can be aggregated for analytics and progress tracking.
///
class QuizResult {
  /// Creates a new [QuizResult] instance.
  ///
  /// [percentage] is calculated automatically from [score] and [totalQuestions].
  /// [timestamp] defaults to current time if not provided.
  const QuizResult({
    required this.courseId,
    required this.quizIndex,
    required this.quizName,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
    this.duration,
  }) : percentage = (score / totalQuestions) * 100;

  /// Creates a [QuizResult] from a JSON map.
  ///
  /// Expected JSON structure:
  /// {
  ///   "courseId": "course_123",
  ///   "quizIndex": 0,
  ///   "quizName": "Quiz 1",
  ///   "score": 8,
  ///   "totalQuestions": 10,
  ///   "timestamp": 1234567890,
  ///   "duration": 300 (optional)
  /// }
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as int;
    final totalQuestions = json['totalQuestions'] as int;

    return QuizResult(
      courseId: json['courseId'] as String,
      quizIndex: json['quizIndex'] as int,
      quizName: json['quizName'] as String,
      score: score,
      totalQuestions: totalQuestions,
      timestamp: json['timestamp'] as int,
      duration: json['duration'] as int?,
    );
  }

  /// Unique identifier of the course this quiz belongs to.
  final String courseId;

  /// Index of the quiz within the course's quizzes list.
  final int quizIndex;

  /// Display name of the quiz (e.g., "Quiz 1" or custom name).
  final String quizName;

  /// Number of correct answers.
  final int score;

  /// Total number of questions in the quiz.
  final int totalQuestions;

  /// Percentage score (calculated automatically).
  ///
  /// This is computed as (score / totalQuestions) * 100.
  final double percentage;

  /// Timestamp when the quiz was completed (milliseconds since epoch).
  final int timestamp;

  /// Optional duration of the quiz in seconds.
  ///
  /// This can be used to track how long users take to complete quizzes.
  final int? duration;

  /// Converts this [QuizResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'quizIndex': quizIndex,
      'quizName': quizName,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp,
      if (duration != null) 'duration': duration,
    };
  }

  /// Creates a copy of this [QuizResult] with updated fields.
  QuizResult copyWith({
    String? courseId,
    int? quizIndex,
    String? quizName,
    int? score,
    int? totalQuestions,
    int? timestamp,
    int? duration,
  }) {
    return QuizResult(
      courseId: courseId ?? this.courseId,
      quizIndex: quizIndex ?? this.quizIndex,
      quizName: quizName ?? this.quizName,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
    );
  }

  /// Debug helper for logging.
  @override
  String toString() {
    return 'QuizResult(courseId: $courseId, quizIndex: $quizIndex, '
        'quizName: $quizName, score: $score/$totalQuestions, '
        'percentage: ${percentage.toStringAsFixed(1)}%, '
        'timestamp: $timestamp)';
  }
}
