import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds a single course item in the sidebar with swipe-to-delete.
class CourseItemWithSwipe extends StatelessWidget {
  const CourseItemWithSwipe({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.isSelected,
    required this.onSelectCourse,
    required this.onDeleteCourse,
    required this.controller,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final bool isSelected;
  final void Function(Course? course) onSelectCourse;
  final Future<void> Function(Course course) onDeleteCourse;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('course_${course.id}'),
      direction: DismissDirection.endToStart,
      background: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacingFromConstraints(constraints),
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 0.5,
              ),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints),
              ),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
              right: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2.5,
              ),
            ),
            child: Icon(
              Icons.delete_outlined,
              color: theme.colorScheme.onError,
              size: ResponsiveSizer.iconSizeFromConstraints(constraints),
            ),
          );
        },
      ),
      confirmDismiss: (DismissDirection direction) async {
        // Show confirmation dialog before deleting
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final theme = Theme.of(context);
            final textTheme = theme.textTheme;

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                        multiplier: 1.67,
                      ),
                    ),
                  ),
                  title: Text(
                    'Delete Course?',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete "${course.name}"? '
                    'This action cannot be undone.',
                    style: textTheme.bodyMedium,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
        );

        return confirmed ?? false;
      },
      onDismissed: (DismissDirection direction) {
        onDeleteCourse(course);
      },
      child: CourseItem(
        theme: theme,
        textTheme: textTheme,
        course: course,
        isSelected: isSelected,
        onSelectCourse: onSelectCourse,
        controller: controller,
      ),
    );
  }
}

/// Builds a single course item in the sidebar.
class CourseItem extends StatelessWidget {
  const CourseItem({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.isSelected,
    required this.onSelectCourse,
    required this.controller,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final bool isSelected;
  final void Function(Course? course) onSelectCourse;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () {
            onSelectCourse(course);
            controller.clearError();
            // Close the drawer if it's open (for compact layout)
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.of(context).pop();
            }
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal:
                      ResponsiveSizer.spacingFromConstraints(constraints),
                  vertical: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 0.5,
                  ),
                ),
                padding:
                    ResponsiveSizer.listItemPaddingFromConstraints(constraints),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.folder_outlined,
                      size:
                          ResponsiveSizer.iconSizeFromConstraints(constraints),
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    SizedBox(
                      width: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 1.5,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            course.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (course.quizCount > 0)
                            Text(
                              '${course.quizCount} quiz${course.quizCount == 1 ? '' : 'zes'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
