import 'package:flutter/foundation.dart';

import 'package:testmaker/models/quiz_result.dart';
import 'package:testmaker/services/quiz_result_service.dart';

/// ********************************************************************
/// AnalyticsController
/// ********************************************************************
///
/// Controller for managing analytics state and aggregating quiz results.
/// Follows MVC architecture - handles all business logic for analytics.
///
/// This controller:
///  - Loads quiz results for a course
///  - Aggregates data for chart visualization
///  - Calculates statistics (average score, total attempts, etc.)
///  - Formats data for deriv_chart display
///
class AnalyticsController extends ChangeNotifier {
  AnalyticsController() : _resultService = QuizResultService();

  final QuizResultService _resultService;
  List<QuizResult> _results = <QuizResult>[];
  bool _isLoading = false;
  String? _error;
  String? _currentCourseId;

  // Getters
  List<QuizResult> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCourseId => _currentCourseId;

  /// Loads analytics data for a specific course.
  ///
  /// This method fetches all quiz results for the course and
  /// prepares them for display in charts and statistics.
  Future<void> loadAnalytics(String courseId) async {
    _currentCourseId = courseId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _resultService.getQuizResultsForCourse(courseId);
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[AnalyticsController.loadAnalytics] Failed: $e');
      }
      _isLoading = false;
      _error = 'Failed to load analytics data';
      notifyListeners();
    }
  }

  /// Gets performance data formatted for bar chart display.
  ///
  /// Returns a map where:
  ///  - Key: quiz name (or "Quiz N" if no custom name)
  ///  - Value: average percentage score for that quiz
  ///
  /// This data can be used to create a bar chart showing
  /// performance by quiz using deriv_chart.
  Map<String, double> getPerformanceByQuiz() {
    if (_results.isEmpty) {
      return <String, double>{};
    }

    // Group results by quizIndex
    final groupedByQuiz = <int, List<QuizResult>>{};
    for (final result in _results) {
      groupedByQuiz.putIfAbsent(result.quizIndex, () => <QuizResult>[]);
      groupedByQuiz[result.quizIndex]!.add(result);
    }

    // Calculate average percentage for each quiz
    final performanceMap = <String, double>{};
    for (final entry in groupedByQuiz.entries) {
      final quizResults = entry.value;

      // Get quiz name from first result (all results for same quiz have same name)
      final quizName = quizResults.first.quizName;

      // Calculate average percentage
      final totalPercentage = quizResults.fold<double>(
        0,
        (double sum, QuizResult result) => sum + result.percentage,
      );
      final averagePercentage = totalPercentage / quizResults.length;

      performanceMap[quizName] = averagePercentage;
    }

    return performanceMap;
  }

  /// Gets the overall average score percentage across all quiz attempts.
  ///
  /// Returns null if no results exist.
  double? getAverageScore() {
    if (_results.isEmpty) {
      return null;
    }

    final totalPercentage = _results.fold<double>(
      0,
      (double sum, QuizResult result) => sum + result.percentage,
    );

    return totalPercentage / _results.length;
  }

  /// Gets the total number of quiz attempts.
  int getTotalAttempts() {
    return _results.length;
  }

  /// Gets the best performing quiz (highest average score).
  ///
  /// Returns null if no results exist.
  /// Returns a map with 'name' and 'average' keys.
  Map<String, dynamic>? getBestPerformingQuiz() {
    final performanceByQuiz = getPerformanceByQuiz();
    if (performanceByQuiz.isEmpty) {
      return null;
    }

    // Find the quiz with the highest average
    String? bestQuizName;
    double? bestAverage;

    for (final entry in performanceByQuiz.entries) {
      if (bestAverage == null || entry.value > bestAverage) {
        bestAverage = entry.value;
        bestQuizName = entry.key;
      }
    }

    if (bestQuizName == null || bestAverage == null) {
      return null;
    }

    return <String, dynamic>{
      'name': bestQuizName,
      'average': bestAverage,
    };
  }

  /// Gets the most recent quiz attempts (for recent activity display).
  ///
  /// Returns the [count] most recent results, sorted by timestamp descending.
  List<QuizResult> getRecentAttempts({int count = 5}) {
    if (_results.isEmpty) {
      return <QuizResult>[];
    }

    // Sort by timestamp descending (most recent first)
    final sortedResults = List<QuizResult>.from(_results)
      ..sort(
        (QuizResult a, QuizResult b) => b.timestamp.compareTo(a.timestamp),
      );

    // Return the requested number of results
    return sortedResults.take(count).toList();
  }

  /// Gets quiz results formatted for deriv_chart CandleSeries.
  ///
  /// Converts quiz performance data into a format suitable for
  /// deriv_chart visualization. Each quiz becomes a "candle" where:
  ///  - open: minimum score for that quiz
  ///  - high: maximum score for that quiz
  ///  - low: minimum score for that quiz
  ///  - close: average score for that quiz
  ///  - epoch: quiz index (used as timestamp for x-axis positioning)
  ///
  /// Note: deriv_chart is designed for time-series data, so we use
  /// quiz indices as "timestamps" to create a bar-chart-like visualization.
  List<Map<String, dynamic>> getChartData() {
    if (_results.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    // Group results by quizIndex
    final groupedByQuiz = <int, List<QuizResult>>{};
    for (final result in _results) {
      groupedByQuiz.putIfAbsent(result.quizIndex, () => <QuizResult>[]);
      groupedByQuiz[result.quizIndex]!.add(result);
    }

    // Convert to chart data format
    final chartData = <Map<String, dynamic>>[];
    for (final entry in groupedByQuiz.entries) {
      final quizIndex = entry.key;
      final quizResults = entry.value;

      // Calculate statistics for this quiz
      final percentages = quizResults
          .map<double>((QuizResult result) => result.percentage)
          .toList();

      final minScore =
          percentages.reduce((double a, double b) => a < b ? a : b);
      final maxScore =
          percentages.reduce((double a, double b) => a > b ? a : b);
      final avgScore =
          percentages.fold<double>(0, (double sum, double p) => sum + p) /
              percentages.length;

      // Use quiz index as epoch (for x-axis positioning)
      // Multiply by 86400 (seconds in a day) to space quizzes apart
      final epoch = quizIndex * 86400;

      chartData.add(<String, dynamic>{
        'epoch': epoch,
        'open': minScore,
        'high': maxScore,
        'low': minScore,
        'close': avgScore,
        'quizName': quizResults.first.quizName,
        'quizIndex': quizIndex,
      });
    }

    // Sort by quiz index to ensure proper ordering
    chartData.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      return (a['quizIndex'] as int).compareTo(b['quizIndex'] as int);
    });

    return chartData;
  }

  /// Resets the controller state.
  void reset() {
    _results.clear();
    _isLoading = false;
    _error = null;
    _currentCourseId = null;
    notifyListeners();
  }
}
