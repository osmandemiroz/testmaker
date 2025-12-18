import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the empty state for a course with no quizzes.
class EmptyCourseState extends StatelessWidget {
  const EmptyCourseState({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.constraints,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveSizer.emptyStatePaddingFromConstraints(constraints),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(
            constraints,
            multiplier: 1.67,
          ),
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.quiz_outlined,
            size:
                ResponsiveSizer.emptyStateIconSizeFromConstraints(constraints),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 2,
            ),
          ),
          Text(
            'No quizzes yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(constraints),
          ),
          Text(
            'Paste quiz or flashcard content to add your first content to ${course.name}',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
