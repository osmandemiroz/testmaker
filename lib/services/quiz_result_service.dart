import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:testmaker/models/quiz_result.dart';

/// ********************************************************************
/// QuizResultService
/// ********************************************************************
///
/// Service responsible for persisting and retrieving quiz results
/// using SharedPreferences for local storage.
///
/// This service provides CRUD operations for quiz results:
///  - Save quiz attempt results
///  - Retrieve results for a course
///  - Retrieve results for a specific quiz
///  - Clean up results when a course is deleted
///
/// All data is persisted locally, so quiz history persists across app restarts.
///
class QuizResultService {
  /// Key pattern used in SharedPreferences to store quiz results.
  ///
  /// Format: `quiz_results_${courseId}`
  static String _getResultsKey(String courseId) {
    return 'quiz_results_$courseId';
  }

  /// SharedPreferences instance (lazy-loaded).
  SharedPreferences? _prefs;

  /// Initializes SharedPreferences if not already initialized.
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Saves a quiz result to local storage.
  ///
  /// The result is appended to the list of results for the course.
  /// Results are stored chronologically (oldest first).
  Future<void> saveQuizResult(QuizResult result) async {
    await _ensureInitialized();
    final prefs = _prefs!;

    final key = _getResultsKey(result.courseId);
    final existingJson = prefs.getString(key);

    // Load existing results or start with empty list
    final List<QuizResult> results;
    if (existingJson != null && existingJson.isNotEmpty) {
      final decoded = jsonDecode(existingJson) as List<dynamic>;
      results = decoded
          .map<QuizResult>(
            (dynamic item) => QuizResult.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } else {
      results = <QuizResult>[];
    }

    // Add the new result
    results.add(result);

    // Save back to SharedPreferences
    final resultsJson = jsonEncode(
      results.map<Map<String, dynamic>>((QuizResult r) => r.toJson()).toList(),
    );

    await prefs.setString(key, resultsJson);
  }

  /// Retrieves all quiz results for a specific course.
  ///
  /// Returns an empty list if no results exist for the course.
  /// Results are returned in chronological order (oldest first).
  Future<List<QuizResult>> getQuizResultsForCourse(String courseId) async {
    await _ensureInitialized();
    final prefs = _prefs!;

    final key = _getResultsKey(courseId);
    final resultsJson = prefs.getString(key);

    if (resultsJson == null || resultsJson.isEmpty) {
      return <QuizResult>[];
    }

    try {
      final decoded = jsonDecode(resultsJson) as List<dynamic>;
      return decoded
          .map<QuizResult>(
            (dynamic item) => QuizResult.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on Exception catch (_) {
      // If there's any error parsing, return an empty list
      return <QuizResult>[];
    }
  }

  /// Retrieves all quiz results for a specific quiz within a course.
  ///
  /// Filters results by both [courseId] and [quizIndex].
  /// Returns an empty list if no results exist for the quiz.
  /// Results are returned in chronological order (oldest first).
  Future<List<QuizResult>> getQuizResultsForQuiz(
    String courseId,
    int quizIndex,
  ) async {
    final allResults = await getQuizResultsForCourse(courseId);
    return allResults
        .where((QuizResult result) => result.quizIndex == quizIndex)
        .toList();
  }

  /// Deletes all quiz results for a specific course.
  ///
  /// This should be called when a course is deleted to clean up
  /// associated quiz result data.
  Future<void> deleteQuizResultsForCourse(String courseId) async {
    await _ensureInitialized();
    final prefs = _prefs!;

    final key = _getResultsKey(courseId);
    await prefs.remove(key);
  }

  /// Gets the most recent quiz result for a specific quiz.
  ///
  /// Returns null if no results exist for the quiz.
  Future<QuizResult?> getMostRecentQuizResult(
    String courseId,
    int quizIndex,
  ) async {
    final results = await getQuizResultsForQuiz(courseId, quizIndex);
    if (results.isEmpty) {
      return null;
    }

    // Sort by timestamp descending and return the most recent
    results.sort(
      (QuizResult a, QuizResult b) => b.timestamp.compareTo(a.timestamp),
    );
    return results.first;
  }

  /// Gets the average score percentage for a specific quiz.
  ///
  /// Returns null if no results exist for the quiz.
  /// Otherwise returns the average percentage across all attempts.
  Future<double?> getAverageScoreForQuiz(
    String courseId,
    int quizIndex,
  ) async {
    final results = await getQuizResultsForQuiz(courseId, quizIndex);
    if (results.isEmpty) {
      return null;
    }

    final totalPercentage = results.fold<double>(
      0,
      (double sum, QuizResult result) => sum + result.percentage,
    );

    return totalPercentage / results.length;
  }
}
