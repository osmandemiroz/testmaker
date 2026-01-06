import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';

/// Types of content that can be shared.
enum SharedContentType {
  quiz,
  flashcardSet,
}

/// Represents content shared via Firestore.
class SharedContent {
  const SharedContent({
    required this.id,
    required this.type,
    required this.data,
    required this.title,
    required this.creatorId,
    required this.createdAt,
  });

  /// Factory for creating [SharedContent] from Firestore data.
  factory SharedContent.fromFirestore(String id, Map<String, dynamic> json) {
    return SharedContent(
      id: id,
      type: SharedContentType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: json['data'] as List<dynamic>,
      title: json['title'] as String,
      creatorId: json['creatorId'] as String,
      createdAt: json['createdAt'] as int,
    );
  }

  /// Unique identifier (Firestore document ID).
  final String id;

  /// Type of shared content.
  final SharedContentType type;

  /// The actual content (list of questions or flashcards).
  final List<dynamic> data;

  /// Title of the quiz or flashcard set.
  final String title;

  /// ID of the user who shared the content.
  final String creatorId;

  /// Timestamp when shared (milliseconds since epoch).
  final int createdAt;

  /// Converts this [SharedContent] to Firestore data.
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'type': type.name,
      'data': data,
      'title': title,
      'creatorId': creatorId,
      'createdAt': createdAt,
    };
  }

  /// Helper to convert [data] to a list of [Question]s if type is quiz.
  List<Question> get asQuestions {
    if (type != SharedContentType.quiz) {
      throw StateError('Shared content is not a quiz');
    }
    return data
        .map((dynamic q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  /// Helper to convert [data] to a list of [Flashcard]s if type is flashcardSet.
  List<Flashcard> get asFlashcards {
    if (type != SharedContentType.flashcardSet) {
      throw StateError('Shared content is not a flashcard set');
    }
    return data
        .map((dynamic f) => Flashcard.fromJson(f as Map<String, dynamic>))
        .toList();
  }
}
