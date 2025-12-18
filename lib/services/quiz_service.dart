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

  /// Parses questions from pasted text.
  ///
  /// First tries to parse as JSON (for AI-generated content).
  /// If that fails, attempts to parse as simple text format.
  /// Returns a list of [Question] objects.
  ///
  /// Throws [FormatException] if the text cannot be parsed.
  List<Question> parseQuestionsFromText(String text) {
    // Trim whitespace
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw const FormatException('No content provided');
    }

    // First, try to parse as JSON (most common case with AI-generated content)
    try {
      return _decodeQuestions(trimmedText);
    } on FormatException {
      // If JSON parsing fails, try simple text format
      return _parseQuestionsFromSimpleText(trimmedText);
    }
  }

  /// Parses questions from a simple text format.
  ///
  /// Expected format (one question per block, separated by blank lines):
  /// Q: Question text here
  /// A: Correct answer
  /// Options:
  /// 1. Option 1
  /// 2. Option 2
  /// 3. Option 3
  /// 4. Option 4
  ///
  /// Or simpler format:
  /// Question text?
  /// A) Option A (correct)
  /// B) Option B
  /// C) Option C
  /// D) Option D
  List<Question> _parseQuestionsFromSimpleText(String text) {
    final questions = <Question>[];
    final blocks = text.split(RegExp(r'\n\s*\n')); // Split by blank lines

    var questionId = 1;
    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      try {
        // Try to find question and options
        String? questionText;
        final options = <String>[];
        int? correctIndex;

        // Look for Q: or question mark
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.startsWith('Q:') || line.startsWith('Question:')) {
            questionText = line.substring(line.indexOf(':') + 1).trim();
          } else if (line.contains('?') && questionText == null) {
            questionText = line;
          } else if (line.startsWith(RegExp(r'[A-D]\)')) ||
              line.startsWith(RegExp(r'\d+\.'))) {
            // Option line
            final optionText =
                line.replaceFirst(RegExp(r'^[A-D]\)\s*|\d+\.\s*'), '').trim();
            if (optionText.isNotEmpty) {
              options.add(optionText);
              // Check if marked as correct
              if (line.contains('(correct)') ||
                  line.contains('(CORRECT)') ||
                  line.contains('✓')) {
                correctIndex = options.length - 1;
              }
            }
          }
        }

        // If we found a question and at least 2 options, create the question
        if (questionText != null &&
            questionText.isNotEmpty &&
            options.length >= 2) {
          // If no correct answer was marked, assume first option
          correctIndex ??= 0;

          questions.add(
            Question(
              id: questionId++,
              text: questionText,
              options: options,
              answerIndex: correctIndex,
            ),
          );
        }
      } on Exception {
        // Skip malformed questions
        continue;
      }
    }

    if (questions.isEmpty) {
      throw const FormatException(
        'Could not parse questions from text. '
        'Please ensure the text is in JSON format or a supported text format.',
      );
    }

    return questions;
  }
}
