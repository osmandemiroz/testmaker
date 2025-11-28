import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import 'package:testmaker/models/question.dart';

/// ********************************************************************
/// QuizService
/// ********************************************************************
///
/// Small service layer responsible for loading quiz questions from JSON.
/// This keeps asset + parsing logic out of the widgets and makes it easy
/// to swap in a different JSON file or change the storage mechanism later.
///
class QuizService {
  const QuizService();

  /// Default asset path used by the app.
  ///
  /// To use a different quiz, you can either:
  ///  - Replace the file at this path, or
  ///  - Call [loadQuestions] with a different asset path.
  static const String defaultQuizAssetPath = 'assets/quizzes/sample_quiz.json';

  /// Loads a list of [Question] objects from the given JSON asset.
  ///
  /// The expected JSON top level structure is a list:
  /// [
  ///   { "id": 1, "text": "...", "options": [...], "answerIndex": 0 },
  ///   ...
  /// ]
  Future<List<Question>> loadQuestions({
    String assetPath = defaultQuizAssetPath,
  }) async {
    // NOTE: Keeping this method small and focused: load -> decode -> map.
    final raw = await rootBundle.loadString(assetPath);

    return _decodeQuestions(raw);
  }

  /// Loads questions from an arbitrary JSON file on disk.
  ///
  /// This is used when the user selects their own quiz JSON via the
  /// "upload" area on the home screen.
  Future<List<Question>> loadQuestionsFromFile(String filePath) async {
    final file = File(filePath);
    final raw = await file.readAsString();

    return _decodeQuestions(raw);
  }

  /// Shared JSON decoding logic so both asset and file loading paths
  /// behave identically.
  List<Question> _decodeQuestions(String rawJson) {
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final questions = decoded
        .map<Question>(
          (dynamic item) => Question.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);

    return questions;
  }
}
