import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import 'package:testmaker/controllers/analytics_controller.dart';
import 'package:testmaker/models/quiz_result.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// AnalyticsScreen
/// ********************************************************************
///
/// Displays quiz analytics and progress tracking for a course.
/// Uses deriv_chart to visualize performance by quiz.
///
/// Features:
///  - Performance chart showing average scores by quiz
///  - Summary statistics (total attempts, average score, best quiz)
///  - Recent activity list
///  - Empty state when no results exist
///
/// Follows Apple's Human Interface Guidelines with clean, minimal design.
///
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    required this.courseId,
    super.key,
  });

  final String courseId;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final AnalyticsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnalyticsController()
      ..addListener(_onControllerChanged)
      ..loadAnalytics(widget.courseId);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (_controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        }

        if (_controller.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  size:
                      ResponsiveSizer.iconSizeFromConstraints(constraints) * 2,
                  color: theme.colorScheme.error,
                ),
                SizedBox(
                  height: ResponsiveSizer.spacingFromConstraints(constraints),
                ),
                Text(
                  _controller.error!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (_controller.results.isEmpty) {
          return _buildEmptyState(theme, textTheme, constraints);
        }

        return SingleChildScrollView(
          padding: ResponsiveSizer.paddingFromConstraints(constraints),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Summary statistics cards
              _buildSummaryCards(theme, textTheme, constraints),
              SizedBox(
                height: ResponsiveSizer.sectionSpacingFromConstraints(
                  constraints,
                ),
              ),
              // Performance chart
              _buildChartSection(theme, textTheme, constraints),
              SizedBox(
                height: ResponsiveSizer.sectionSpacingFromConstraints(
                  constraints,
                ),
              ),
              // Recent activity
              _buildRecentActivity(theme, textTheme, constraints),
            ],
          ),
        );
      },
    );
  }

  /// Builds the empty state when no quiz results exist.
  Widget _buildEmptyState(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    return Center(
      child: Padding(
        padding: ResponsiveSizer.paddingFromConstraints(constraints),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: ResponsiveSizer.iconContainerSizeFromConstraints(
                constraints,
                multiplier: 2,
              ),
              height: ResponsiveSizer.iconContainerSizeFromConstraints(
                constraints,
                multiplier: 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(constraints),
                ),
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: ResponsiveSizer.iconSizeFromConstraints(constraints) * 2,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            Text(
              'No Quiz Results Yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(constraints),
            ),
            Text(
              'Complete some quizzes to see your progress and analytics here.',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds summary statistics cards.
  Widget _buildSummaryCards(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    final averageScore = _controller.getAverageScore();
    final totalAttempts = _controller.getTotalAttempts();
    final bestQuiz = _controller.getBestPerformingQuiz();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Total attempts and average score in a row
        Row(
          children: <Widget>[
            Expanded(
              child: _buildStatCard(
                theme: theme,
                textTheme: textTheme,
                constraints: constraints,
                icon: Icons.quiz_outlined,
                label: 'Total Attempts',
                value: totalAttempts.toString(),
              ),
            ),
            SizedBox(
              width: ResponsiveSizer.spacingFromConstraints(constraints),
            ),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                textTheme: textTheme,
                constraints: constraints,
                icon: Icons.trending_up,
                label: 'Average Score',
                value: averageScore != null
                    ? '${averageScore.toStringAsFixed(1)}%'
                    : 'N/A',
              ),
            ),
          ],
        ),
        // Best performing quiz
        if (bestQuiz != null) ...<Widget>[
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(constraints),
          ),
          _buildStatCard(
            theme: theme,
            textTheme: textTheme,
            constraints: constraints,
            icon: Icons.star_outline,
            label: 'Best Performing Quiz',
            value: bestQuiz['name'] as String,
            subtitle: '${(bestQuiz['average'] as double).toStringAsFixed(1)}%',
          ),
        ],
      ],
    );
  }

  /// Builds a single statistics card.
  Widget _buildStatCard({
    required ThemeData theme,
    required TextTheme textTheme,
    required BoxConstraints constraints,
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveSizer.cardPaddingFromConstraints(constraints),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(constraints),
        ),
        color: theme.colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: ResponsiveSizer.iconSizeFromConstraints(constraints),
              ),
              SizedBox(
                width:
                    ResponsiveSizer.spacingFromConstraints(constraints) * 0.75,
              ),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(constraints) * 0.75,
          ),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...<Widget>[
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(constraints) * 0.5,
            ),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the chart section with deriv_chart visualization.
  Widget _buildChartSection(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    final chartData = _controller.getChartData();
    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert chart data to Candle format for deriv_chart
    // Ensure we have at least one candle for the chart to render properly
    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final candles = chartData.map<Candle>((Map<String, dynamic> data) {
      return Candle(
        epoch: data['epoch'] as int,
        open: data['open'] as double,
        high: data['high'] as double,
        low: data['low'] as double,
        close: data['close'] as double,
      );
    }).toList();

    // Ensure candles list is not empty and has at least one item
    // Some chart libraries require minimum data points
    if (candles.isEmpty || candles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(
        ResponsiveSizer.cardPaddingFromConstraints(constraints),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(constraints),
        ),
        color: theme.colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.bar_chart,
                color: theme.colorScheme.primary,
                size: ResponsiveSizer.iconSizeFromConstraints(constraints),
              ),
              SizedBox(
                width:
                    ResponsiveSizer.spacingFromConstraints(constraints) * 0.75,
              ),
              Text(
                'Performance by Quiz',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          // Chart container with fixed height
          SizedBox(
            height: ResponsiveSizer.chartHeightFromConstraints(constraints),
            child: candles.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : _buildSimpleBarChart(
                    candles: candles,
                    chartData: chartData,
                    theme: theme,
                    textTheme: textTheme,
                    constraints: constraints,
                  ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(constraints),
          ),
          // Chart legend/explanation
          Text(
            'Shows average score percentage for each quiz. '
            'Higher bars indicate better performance.',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the recent activity section.
  Widget _buildRecentActivity(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
  ) {
    final recentAttempts = _controller.getRecentAttempts();
    if (recentAttempts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(
        ResponsiveSizer.cardPaddingFromConstraints(constraints),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(constraints),
        ),
        color: theme.colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.history,
                color: theme.colorScheme.primary,
                size: ResponsiveSizer.iconSizeFromConstraints(constraints),
              ),
              SizedBox(
                width:
                    ResponsiveSizer.spacingFromConstraints(constraints) * 0.75,
              ),
              Text(
                'Recent Activity',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          ...recentAttempts.map<Widget>(
            (QuizResult result) => _buildActivityItem(
              theme: theme,
              textTheme: textTheme,
              constraints: constraints,
              result: result,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single activity item.
  Widget _buildActivityItem({
    required ThemeData theme,
    required TextTheme textTheme,
    required BoxConstraints constraints,
    required QuizResult result,
  }) {
    final date = DateTime.fromMillisecondsSinceEpoch(result.timestamp);
    final dateString = _formatDate(date);

    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(constraints),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: ResponsiveSizer.iconContainerSizeFromConstraints(
              constraints,
              multiplier: 0.8,
            ),
            height: ResponsiveSizer.iconContainerSizeFromConstraints(
              constraints,
              multiplier: 0.8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints) * 0.5,
              ),
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
            child: Icon(
              result.percentage >= 70
                  ? Icons.check_circle_outline
                  : result.percentage >= 50
                      ? Icons.info_outline
                      : Icons.error_outline,
              color: theme.colorScheme.primary,
              size: ResponsiveSizer.iconSizeFromConstraints(constraints) * 0.8,
            ),
          ),
          SizedBox(
            width: ResponsiveSizer.spacingFromConstraints(constraints),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  result.quizName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: ResponsiveSizer.spacingFromConstraints(constraints) *
                      0.25,
                ),
                Text(
                  '$dateString • ${result.score}/${result.totalQuestions} '
                  '(${result.percentage.toStringAsFixed(1)}%)',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a date for display.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Builds a simple bar chart visualization as fallback.
  ///
  /// This is used when the deriv_chart Chart widget has issues.
  /// Creates a custom bar chart showing average scores by quiz.
  Widget _buildSimpleBarChart({
    required List<Candle> candles,
    required List<Map<String, dynamic>> chartData,
    required ThemeData theme,
    required TextTheme textTheme,
    required BoxConstraints constraints,
  }) {
    // Extract max score for scaling
    if (candles.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxScore = candles.map<double>((Candle c) => c.close).reduce(
          (double a, double b) => a > b ? a : b,
        );
    final chartHeight = ResponsiveSizer.chartHeightFromConstraints(constraints);

    return CustomPaint(
      size: Size(double.infinity, chartHeight),
      painter: _SimpleBarChartPainter(
        chartData: chartData,
        maxScore: maxScore > 0 ? maxScore : 100.0,
        chartHeight: chartHeight,
        theme: theme,
      ),
    );
  }
}

/// Custom painter for simple bar chart visualization.
class _SimpleBarChartPainter extends CustomPainter {
  _SimpleBarChartPainter({
    required this.chartData,
    required this.maxScore,
    required this.chartHeight,
    required this.theme,
  });

  final List<Map<String, dynamic>> chartData;
  final double maxScore;
  final double chartHeight;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.isEmpty) {
      return;
    }

    final barWidth = (size.width / chartData.length) * 0.6;
    final barSpacing = (size.width / chartData.length) * 0.4;
    const padding = 20.0;

    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    for (var i = 0; i < chartData.length; i++) {
      final data = chartData[i];
      final averageScore = data['close'] as double;
      final barHeight = ((averageScore / 100) * (size.height - padding * 2))
          .clamp(0.0, size.height - padding * 2);

      final x = padding + (i * (barWidth + barSpacing)) + (barSpacing / 2);
      final y = size.height - padding - barHeight;

      // Draw bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SimpleBarChartPainter oldDelegate) {
    return oldDelegate.chartData != chartData ||
        oldDelegate.maxScore != maxScore ||
        oldDelegate.theme != theme;
  }
}
