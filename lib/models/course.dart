import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';

/// Defines the sorting preference for quizzes in a course.
enum QuizSortingPreference {
  /// Quizzes are presented in the order they were added (sequential).
  sequential,

  /// Quizzes are presented in a random order (shuffled).
  random;

  /// Parses a [QuizSortingPreference] from a string.
  static QuizSortingPreference fromString(String value) {
    return QuizSortingPreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () =>
          QuizSortingPreference.random, // Default to random for legacy
    );
  }
}

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
///  - A list of flashcard sets, where each set is a list of flashcards
///  - A list of PDF file paths for study materials
///  - Custom names for quizzes, flashcard sets, and PDFs (optional)
///
/// This model is designed to be easily serializable to/from JSON
/// for local storage via SharedPreferences.
///
class Course {
  /// Creates a new [Course] instance.
  ///
  /// [id] must be unique. If not provided, a new UUID-style ID is generated.
  /// [createdAt] and [updatedAt] default to the current timestamp if not provided.
  /// [quizNames], [flashcardSetNames], and [pdfNames] are optional maps
  /// that store custom names for items. If not provided, default names are used.
  const Course({
    required this.id,
    required this.name,
    required this.quizzes,
    required this.flashcards,
    required this.pdfs,
    required this.createdAt,
    required this.updatedAt,
    this.quizNames,
    this.flashcardSetNames,
    this.pdfNames,
    this.quizSortingPreference = QuizSortingPreference.random,
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
  ///   "flashcards": [
  ///     [
  ///       { "id": 1, "front": "...", "back": "...", "explanation": "..." },
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

    final flashcardsJson = json['flashcards'] as List<dynamic>? ?? <dynamic>[];
    final flashcards = flashcardsJson
        .map<List<Flashcard>>(
          (dynamic flashcardSetJson) => (flashcardSetJson as List<dynamic>)
              .map<Flashcard>(
                (dynamic f) => Flashcard.fromJson(
                  f as Map<String, dynamic>,
                ),
              )
              .toList(growable: false),
        )
        .toList(growable: false);

    final pdfsJson = json['pdfs'] as List<dynamic>? ?? <dynamic>[];
    final pdfs = pdfsJson
        .map<String>((dynamic pdf) => pdf as String)
        .toList(growable: false);

    final quizNamesJson = json['quizNames'] as Map<String, dynamic>?;
    final quizNames = quizNamesJson?.map<int, String>(
      (String key, dynamic value) => MapEntry(int.parse(key), value as String),
    );

    final flashcardSetNamesJson =
        json['flashcardSetNames'] as Map<String, dynamic>?;
    final flashcardSetNames = flashcardSetNamesJson?.map<int, String>(
      (String key, dynamic value) => MapEntry(int.parse(key), value as String),
    );

    final pdfNamesJson = json['pdfNames'] as Map<String, dynamic>?;
    final pdfNames = pdfNamesJson?.map<int, String>(
      (String key, dynamic value) => MapEntry(int.parse(key), value as String),
    );

    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      quizzes: quizzes,
      flashcards: flashcards,
      pdfs: pdfs,
      createdAt:
          json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt:
          json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      quizNames: quizNames,
      flashcardSetNames: flashcardSetNames,
      pdfNames: pdfNames,
      quizSortingPreference: QuizSortingPreference.fromString(
        json['quizSortingPreference'] as String? ?? 'random',
      ),
    );
  }

  /// Unique identifier for this course.
  final String id;

  /// User-friendly name of the course (e.g., "Math 101", "History 202").
  final String name;

  /// List of quizzes in this course.
  /// Each quiz is represented as a list of [Question] objects.
  final List<List<Question>> quizzes;

  /// List of flashcard sets in this course.
  /// Each flashcard set is represented as a list of [Flashcard] objects.
  final List<List<Flashcard>> flashcards;

  /// List of PDF file paths in this course.
  /// Each path points to a PDF file stored locally in the app's documents directory.
  final List<String> pdfs;

  /// Timestamp when this course was created (milliseconds since epoch).
  final int createdAt;

  /// Timestamp when this course was last modified (milliseconds since epoch).
  final int updatedAt;

  /// Map of quiz indices to custom names.
  /// If a quiz doesn't have a custom name, a default name is used.
  final Map<int, String>? quizNames;

  /// Map of flashcard set indices to custom names.
  /// If a flashcard set doesn't have a custom name, a default name is used.
  final Map<int, String>? flashcardSetNames;

  /// Map of PDF indices to custom names.
  /// If a PDF doesn't have a custom name, the filename is used.
  final Map<int, String>? pdfNames;

  /// User preference for quiz sorting (sequential or random).
  final QuizSortingPreference quizSortingPreference;

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
      'flashcards': flashcards
          .map<List<Map<String, dynamic>>>(
            (List<Flashcard> flashcardSet) => flashcardSet
                .map<Map<String, dynamic>>((Flashcard f) => f.toJson())
                .toList(),
          )
          .toList(),
      'pdfs': pdfs,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (quizNames != null && quizNames!.isNotEmpty)
        'quizNames': quizNames!.map<String, String>(
          (int key, String value) => MapEntry(key.toString(), value),
        ),
      if (flashcardSetNames != null && flashcardSetNames!.isNotEmpty)
        'flashcardSetNames': flashcardSetNames!.map<String, String>(
          (int key, String value) => MapEntry(key.toString(), value),
        ),
      if (pdfNames != null && pdfNames!.isNotEmpty)
        'pdfNames': pdfNames!.map<String, String>(
          (int key, String value) => MapEntry(key.toString(), value),
        ),
      'quizSortingPreference': quizSortingPreference.name,
    };
  }

  /// Creates a copy of this [Course] with updated fields.
  ///
  /// Useful for immutability when updating a course's name, quizzes, flashcards, or PDFs.
  Course copyWith({
    String? id,
    String? name,
    List<List<Question>>? quizzes,
    List<List<Flashcard>>? flashcards,
    List<String>? pdfs,
    int? createdAt,
    int? updatedAt,
    Map<int, String>? quizNames,
    Map<int, String>? flashcardSetNames,
    Map<int, String>? pdfNames,
    QuizSortingPreference? quizSortingPreference,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      quizzes: quizzes ?? this.quizzes,
      flashcards: flashcards ?? this.flashcards,
      pdfs: pdfs ?? this.pdfs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quizNames: quizNames ?? this.quizNames,
      flashcardSetNames: flashcardSetNames ?? this.flashcardSetNames,
      pdfNames: pdfNames ?? this.pdfNames,
      quizSortingPreference:
          quizSortingPreference ?? this.quizSortingPreference,
    );
  }

  /// Gets the name for a quiz at the given index.
  /// Returns a default name if no custom name is set.
  String getQuizName(int index) {
    return quizNames?[index] ?? 'Quiz ${index + 1}';
  }

  /// Gets the name for a flashcard set at the given index.
  /// Returns a default name if no custom name is set.
  String getFlashcardSetName(int index) {
    return flashcardSetNames?[index] ?? 'Flashcard Set ${index + 1}';
  }

  /// Gets the name for a PDF at the given index.
  /// Returns a clean filename if no custom name is set.
  /// Strips timestamp prefix and removes .pdf extension.
  String getPdfName(int index, String pdfPath) {
    if (pdfNames?[index] != null) {
      return pdfNames![index]!;
    }
    // Extract filename from path
    var fileName = pdfPath.split('/').last;

    // Remove .pdf extension (case-insensitive)
    if (fileName.toLowerCase().endsWith('.pdf')) {
      fileName = fileName.substring(0, fileName.length - 4);
    }

    // Remove timestamp prefix (digits followed by underscore)
    // Pattern: 1767369212347_comp-org -> comp-org
    // Manually check and remove prefix to avoid RegExp deprecation
    if (fileName.isNotEmpty) {
      var prefixEnd = 0;
      // Find where digits end by checking character codes
      while (prefixEnd < fileName.length) {
        final charCode = fileName.codeUnitAt(prefixEnd);
        // Check if character is a digit (0-9)
        if (charCode >= 48 && charCode <= 57) {
          prefixEnd++;
        } else {
          break;
        }
      }
      // If we found digits followed by underscore, remove the prefix
      if (prefixEnd > 0 &&
          prefixEnd < fileName.length &&
          fileName[prefixEnd] == '_') {
        fileName = fileName.substring(prefixEnd + 1);
      }
    }

    return fileName.length > 30 ? '${fileName.substring(0, 30)}...' : fileName;
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

  /// Returns the total number of flashcard sets in this course.
  int get flashcardSetCount => flashcards.length;

  /// Returns the total number of flashcards across all sets in this course.
  int get totalFlashcardCount {
    return flashcards.fold<int>(
      0,
      (int sum, List<Flashcard> flashcardSet) => sum + flashcardSet.length,
    );
  }

  /// Returns the total number of PDFs in this course.
  int get pdfCount => pdfs.length;
}
