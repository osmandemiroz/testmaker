import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the empty state when no courses exist.
class EmptyCoursesState extends StatelessWidget {
  const EmptyCoursesState({
    required this.theme,
    required this.textTheme,
    required this.constraints,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveSizer.emptyStatePaddingFromConstraints(constraints),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_outlined,
              size: ResponsiveSizer.emptyStateIconSizeFromConstraints(
                constraints,
              ),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            Text(
              'No courses yet',
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(constraints),
            ),
            Text(
              'Create your first course to get started',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
