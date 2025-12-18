import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/items/course_item.dart';
import 'package:testmaker/screens/home/views/empty_courses_state.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the sidebar menu for course navigation.
class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.controller,
    required this.onCreateCourse,
    required this.onDeleteCourse,
    required this.onSelectCourse,
    super.key,
  });

  final HomeController controller;
  final VoidCallback onCreateCourse;
  final Future<void> Function(Course course) onDeleteCourse;
  final void Function(Course? course) onSelectCourse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final sidebarWidth =
            ResponsiveSizer.sidebarWidthFromConstraints(constraints);

        return Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(
              right: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header with clickable logo to go to main screen
              Padding(
                padding: EdgeInsets.all(
                  ResponsiveSizer.cardPaddingFromConstraints(constraints),
                ),
                child: Builder(
                  builder: (BuildContext context) {
                    return InkWell(
                      onTap: () {
                        onSelectCourse(null);
                        controller.clearError();
                        // Close the drawer if it's open (for compact layout)
                        if (Scaffold.of(context).isDrawerOpen) {
                          Navigator.of(context).pop();
                        }
                      },
                      borderRadius: BorderRadius.circular(
                        ResponsiveSizer.borderRadiusFromConstraints(
                          constraints,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 0.5,
                          ),
                          vertical: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'TestMaker',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveSizer.spacingFromConstraints(
                                constraints,
                                multiplier: 0.5,
                              ),
                            ),
                            Text(
                              'Your courses',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(
                height:
                    ResponsiveSizer.dividerHeightFromConstraints(constraints),
              ),
              // Course list
              Expanded(
                child: controller.isLoadingCourses
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.courses.isEmpty
                        ? EmptyCoursesState(
                            theme: theme,
                            textTheme: textTheme,
                            constraints: constraints,
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveSizer.spacingFromConstraints(
                                constraints,
                              ),
                            ),
                            itemCount: controller.courses.length,
                            itemBuilder: (BuildContext context, int index) {
                              final course = controller.courses[index];
                              final isSelected =
                                  controller.selectedCourse?.id == course.id;

                              return CourseItemWithSwipe(
                                theme: theme,
                                textTheme: textTheme,
                                course: course,
                                isSelected: isSelected,
                                onSelectCourse: onSelectCourse,
                                onDeleteCourse: onDeleteCourse,
                                controller: controller,
                              );
                            },
                          ),
              ),
              Divider(
                height:
                    ResponsiveSizer.dividerHeightFromConstraints(constraints),
              ),
              // Add course button
              Padding(
                padding: EdgeInsets.all(
                  ResponsiveSizer.cardPaddingFromConstraints(constraints),
                ),
                child: FilledButton.icon(
                  onPressed: onCreateCourse,
                  icon: Icon(
                    Icons.add,
                    size: ResponsiveSizer.iconSizeFromConstraints(constraints),
                  ),
                  label: const Text('New Course'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 2,
                      ),
                      vertical: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 1.5,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveSizer.borderRadiusFromConstraints(
                          constraints,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
