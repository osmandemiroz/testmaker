import 'package:testmaker/models/question.dart';

/// ********************************************************************
/// Course
/// ********************************************************************
///
/// Represents a course/section that contains multiple quizzes and PDFs.
///
/// Each course has:
///  - A unique identifier (id)
///  - A user-defined name (e.g., "Math 101", "History")
///  - A list of quizzes, where each quiz is a list of questions
///  - A list of PDF file paths for study materials
///
/// This model is designed to be easily serializable to/from JSON
/// for local storage via SharedPreferences.
///
class Course {
  /// Creates a new [Course] instance.
  ///
  /// [id] must be unique. If not provided, a new UUID-style ID is generated.
  /// [createdAt] and [updatedAt] default to the current timestamp if not provided.
  const Course({
    required this.id,
    required this.name,
    required this.quizzes,
    required this.pdfs,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [Course] from a JSON map.
  ///
  /// Expected JSON structure:
  /// {
  ///   "id": "course-123",
  ///   "name": "Math 101",
  ///   "quizzes": [
  ///     [
  ///       { "id": 1, "text": "...", "options": [...], "answerIndex": 0 },
  ///       ...
  ///     ],
  ///     ...
  ///   ],
  ///   "pdfs": ["path/to/file1.pdf", "path/to/file2.pdf"],
  ///   "createdAt": 1234567890,
  ///   "updatedAt": 1234567890
  /// }
  factory Course.fromJson(Map<String, dynamic> json) {
    final quizzesJson = json['quizzes'] as List<dynamic>? ?? <dynamic>[];
    final quizzes = quizzesJson
        .map<List<Question>>(
          (dynamic quizJson) => (quizJson as List<dynamic>)
              .map<Question>(
                (dynamic q) => Question.fromJson(
                  q as Map<String, dynamic>,
                ),
              )
              .toList(growable: false),
        )
        .toList(growable: false);

    final pdfsJson = json['pdfs'] as List<dynamic>? ?? <dynamic>[];
    final pdfs = pdfsJson
        .map<String>((dynamic pdf) => pdf as String)
        .toList(growable: false);

    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      quizzes: quizzes,
      pdfs: pdfs,
      createdAt:
          json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt:
          json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Unique identifier for this course.
  final String id;

  /// User-friendly name of the course (e.g., "Math 101", "History 202").
  final String name;

  /// List of quizzes in this course.
  /// Each quiz is represented as a list of [Question] objects.
  final List<List<Question>> quizzes;

  /// List of PDF file paths in this course.
  /// Each path points to a PDF file stored locally in the app's documents directory.
  final List<String> pdfs;

  /// Timestamp when this course was created (milliseconds since epoch).
  final int createdAt;

  /// Timestamp when this course was last modified (milliseconds since epoch).
  final int updatedAt;

  /// Converts this [Course] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quizzes': quizzes
          .map<List<Map<String, dynamic>>>(
            (List<Question> quiz) => quiz
                .map<Map<String, dynamic>>((Question q) => q.toJson())
                .toList(),
          )
          .toList(),
      'pdfs': pdfs,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a copy of this [Course] with updated fields.
  ///
  /// Useful for immutability when updating a course's name, quizzes, or PDFs.
  Course copyWith({
    String? id,
    String? name,
    List<List<Question>>? quizzes,
    List<String>? pdfs,
    int? createdAt,
    int? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      quizzes: quizzes ?? this.quizzes,
      pdfs: pdfs ?? this.pdfs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns the total number of quizzes in this course.
  int get quizCount => quizzes.length;

  /// Returns the total number of questions across all quizzes in this course.
  int get totalQuestionCount {
    return quizzes.fold<int>(
      0,
      (int sum, List<Question> quiz) => sum + quiz.length,
    );
  }

  /// Returns the total number of PDFs in this course.
  int get pdfCount => pdfs.length;
}
