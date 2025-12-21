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
  ///
  /// Creates a beautifully designed chart section following Apple's Human
  /// Interface Guidelines with smooth animations, gradients, and polished
  /// visual design.
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
          // Header section with icon and title
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(
                  ResponsiveSizer.spacingFromConstraints(constraints) * 0.5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints) *
                        0.5,
                  ),
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: theme.colorScheme.primary,
                  size: ResponsiveSizer.iconSizeFromConstraints(constraints),
                ),
              ),
              SizedBox(
                width:
                    ResponsiveSizer.spacingFromConstraints(constraints) * 0.75,
              ),
              Expanded(
                child: Text(
                  'Performance by Quiz',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
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
          // Chart container with fixed height and improved styling
          SizedBox(
            height: ResponsiveSizer.chartHeightFromConstraints(constraints) +
                ResponsiveSizer.spacingFromConstraints(constraints) * 3,
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
                : _buildEnhancedBarChart(
                    candles: candles,
                    chartData: chartData,
                    theme: theme,
                    textTheme: textTheme,
                    constraints: constraints,
                  ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(constraints) * 0.75,
          ),
          // Chart legend/explanation with improved styling
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacingFromConstraints(constraints) *
                  0.75,
              vertical: ResponsiveSizer.spacingFromConstraints(constraints) *
                  0.5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints) * 0.5,
              ),
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: ResponsiveSizer.iconSizeFromConstraints(constraints) *
                      0.75,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(
                  width: ResponsiveSizer.spacingFromConstraints(constraints) *
                      0.5,
                ),
                Expanded(
                  child: Text(
                    'Shows average score percentage for each quiz. '
                    'Higher bars indicate better performance.',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
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

  /// Builds an enhanced bar chart visualization with animations and modern styling.
  ///
  /// This creates a beautiful, animated bar chart following Apple's Human
  /// Interface Guidelines with:
  ///  - Smooth entrance animations for each bar
  ///  - Gradient fills for visual depth
  ///  - Value labels on top of bars
  ///  - Quiz labels below bars
  ///  - Subtle grid lines for better readability
  ///  - Polished, modern design
  Widget _buildEnhancedBarChart({
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
    final labelHeight = ResponsiveSizer.spacingFromConstraints(constraints) * 2;

    return Stack(
      children: <Widget>[
        // Background grid layer
        CustomPaint(
          size: Size(
            double.infinity,
            chartHeight + labelHeight,
          ),
          painter: _ChartGridPainter(
            chartData: chartData,
            chartHeight: chartHeight,
            theme: theme,
          ),
        ),
        // Bars and labels layer
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Chart area with bars
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(
                  chartData.length,
                  (int index) {
                    final data = chartData[index];
                    final averageScore = data['close'] as double;
                    final quizName = data['quizName'] as String;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ) *
                              0.25,
                        ),
                        child: _AnimatedBarWidget(
                          delay: Duration(milliseconds: 100 + (index * 150)),
                          score: averageScore,
                          maxScore: maxScore > 0 ? maxScore : 100.0,
                          quizName: quizName,
                          theme: theme,
                          textTheme: textTheme,
                          constraints: constraints,
                          chartHeight: chartHeight,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Quiz labels below chart
            SizedBox(
              height: labelHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(
                  chartData.length,
                  (int index) {
                    final data = chartData[index];
                    final quizName = data['quizName'] as String;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ) *
                              0.25,
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: 1,
                          ),
                          duration: Duration(
                            milliseconds: 300 + (index * 100),
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (
                            BuildContext context,
                            double value,
                            Widget? child,
                          ) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: Text(
                                  quizName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated bar widget with gradient fill and value label.
///
/// Creates a single animated bar for the chart with smooth entrance animation,
/// gradient fill, and a value label displayed on top.
/// Uses staggered delays for a cascading animation effect.
class _AnimatedBarWidget extends StatefulWidget {
  const _AnimatedBarWidget({
    required this.delay,
    required this.score,
    required this.maxScore,
    required this.quizName,
    required this.theme,
    required this.textTheme,
    required this.constraints,
    required this.chartHeight,
  });

  final Duration delay;
  final double score;
  final double maxScore;
  final String quizName;
  final ThemeData theme;
  final TextTheme textTheme;
  final BoxConstraints constraints;
  final double chartHeight;

  @override
  State<_AnimatedBarWidget> createState() => _AnimatedBarWidgetState();
}

class _AnimatedBarWidgetState extends State<_AnimatedBarWidget> {
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    // Start animation after delay for staggered effect
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _shouldAnimate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bar height as percentage of chart height
    // Leave padding at top and bottom for labels
    const topPadding = 32.0;
    const bottomPadding = 8.0;
    final availableHeight =
        widget.chartHeight - topPadding - bottomPadding;
    final barHeight = ((widget.score / widget.maxScore) * availableHeight)
        .clamp(0.0, availableHeight);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: _shouldAnimate ? barHeight : 0,
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double animatedHeight, Widget? child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            // Bar with gradient fill
            Container(
              width: double.infinity,
              height: animatedHeight.clamp(0.0, availableHeight),
              margin: const EdgeInsets.only(bottom: bottomPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    widget.theme.colorScheme.primary,
                    widget.theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: widget.theme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            // Value label on top of bar
            if (animatedHeight > 20)
              Positioned(
                top: widget.chartHeight - animatedHeight - bottomPadding - 24,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: _shouldAnimate ? 1 : 0,
                  ),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (
                    BuildContext context,
                    double opacity,
                    Widget? child,
                  ) {
                    return Opacity(
                      opacity: opacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: widget.theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.95),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${widget.score.toStringAsFixed(1)}%',
                          style: widget.textTheme.labelSmall?.copyWith(
                            color: widget.theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Custom painter for chart grid background.
///
/// Draws subtle grid lines to improve chart readability, following
/// Apple's Human Interface Guidelines for data visualization.
class _ChartGridPainter extends CustomPainter {
  _ChartGridPainter({
    required this.chartData,
    required this.chartHeight,
    required this.theme,
  });

  final List<Map<String, dynamic>> chartData;
  final double chartHeight;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.isEmpty) {
      return;
    }

    // Draw horizontal grid lines for better readability
    // Following Apple's design principles: subtle, non-intrusive
    const topPadding = 32.0;
    const bottomPadding = 8.0;
    final availableHeight = chartHeight - topPadding - bottomPadding;
    const gridLines = 4; // Number of horizontal grid lines

    final gridPaint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (var i = 0; i <= gridLines; i++) {
      final y = topPadding + (availableHeight / gridLines) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartGridPainter oldDelegate) {
    return oldDelegate.chartData != chartData ||
        oldDelegate.chartHeight != chartHeight ||
        oldDelegate.theme != theme;
  }
}
