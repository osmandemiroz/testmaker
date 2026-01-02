import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/app_user.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/items/course_item.dart';
import 'package:testmaker/screens/home/views/empty_courses_state.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// Sidebar
/// ********************************************************************
///
/// Builds the sidebar menu for course navigation.
/// Shows user welcome message and logout option when authenticated.
///
/// Follows Apple Human Interface Guidelines:
/// - Clean, minimal design
/// - User-friendly welcome message
/// - Easy access to logout
///
class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.controller,
    required this.onCreateCourse,
    required this.onDeleteCourse,
    required this.onSelectCourse,
    this.currentUser,
    this.onLogout,
    super.key,
  });

  final HomeController controller;
  final VoidCallback onCreateCourse;
  final Future<void> Function(Course course) onDeleteCourse;
  final void Function(Course? course) onSelectCourse;

  /// The currently authenticated user (null if not logged in)
  final AppUser? currentUser;

  /// Callback when user taps logout
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final sidebarWidth =
            ResponsiveSizer.sidebarWidthFromConstraints(constraints);
        // Get top padding to position content below the status bar
        // while keeping the background extending to the very top
        final topPadding = MediaQuery.of(context).padding.top;

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
              // Top padding to position content below status bar
              // This keeps the background extending edge-to-edge while
              // adding space for the content
              SizedBox(height: topPadding),
              // Header with clickable logo to go to main screen
              Padding(
                padding: EdgeInsets.all(
                  ResponsiveSizer.cardPaddingFromConstraints(constraints),
                ),
                child: Builder(
                  builder: (BuildContext context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
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
                              horizontal:
                                  ResponsiveSizer.spacingFromConstraints(
                                constraints,
                                multiplier: 0.5,
                              ),
                              vertical: ResponsiveSizer.spacingFromConstraints(
                                constraints,
                                multiplier: 0.5,
                              ),
                            ),
                            child: Text(
                              'TestMaker',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 0.5,
                          ),
                        ),
                        // Welcome text with logout button on the same row
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 0.5,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _buildWelcomeText(theme, textTheme),
                              ),
                              // Logout button next to welcome text
                              if (currentUser != null && onLogout != null)
                                IconButton(
                                  onPressed: onLogout,
                                  icon: Icon(
                                    Icons.logout_rounded,
                                    size:
                                        ResponsiveSizer.iconSizeFromConstraints(
                                      constraints,
                                    ),
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: 'Log Out',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(
                height:
                    ResponsiveSizer.dividerHeightFromConstraints(constraints),
              ),
              // Course list and action buttons
              Expanded(
                child: controller.isLoadingCourses
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.courses.isEmpty
                        // When no courses, show empty state with buttons centered
                        ? SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    ResponsiveSizer.spacingFromConstraints(
                                  constraints,
                                  multiplier: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  EmptyCoursesState(
                                    theme: theme,
                                    textTheme: textTheme,
                                    constraints: constraints,
                                  ),
                                  SizedBox(
                                    height:
                                        ResponsiveSizer.spacingFromConstraints(
                                      constraints,
                                      multiplier: 3,
                                    ),
                                  ),
                                  // Add course button
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveSizer
                                          .cardPaddingFromConstraints(
                                        constraints,
                                      ),
                                    ),
                                    child: FilledButton.icon(
                                      onPressed: onCreateCourse,
                                      icon: Icon(
                                        Icons.add,
                                        size: ResponsiveSizer
                                            .iconSizeFromConstraints(
                                          constraints,
                                        ),
                                      ),
                                      label: const Text('New Course'),
                                      style: FilledButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveSizer
                                              .spacingFromConstraints(
                                            constraints,
                                            multiplier: 2,
                                          ),
                                          vertical: ResponsiveSizer
                                              .spacingFromConstraints(
                                            constraints,
                                            multiplier: 1.5,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveSizer
                                                .borderRadiusFromConstraints(
                                              constraints,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        // When courses exist, show list with buttons at bottom
                        : Column(
                            children: <Widget>[
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveSizer.spacingFromConstraints(
                                      constraints,
                                    ),
                                  ),
                                  itemCount: controller.courses.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final course = controller.courses[index];
                                    final isSelected =
                                        controller.selectedCourse?.id ==
                                            course.id;

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
                                height: ResponsiveSizer
                                    .dividerHeightFromConstraints(constraints),
                              ),
                              // Add course button
                              Padding(
                                padding: EdgeInsets.all(
                                  ResponsiveSizer.cardPaddingFromConstraints(
                                    constraints,
                                  ),
                                ),
                                child: FilledButton.icon(
                                  onPressed: onCreateCourse,
                                  icon: Icon(
                                    Icons.add,
                                    size:
                                        ResponsiveSizer.iconSizeFromConstraints(
                                      constraints,
                                    ),
                                  ),
                                  label: const Text('New Course'),
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveSizer
                                          .spacingFromConstraints(
                                        constraints,
                                        multiplier: 2,
                                      ),
                                      vertical: ResponsiveSizer
                                          .spacingFromConstraints(
                                        constraints,
                                        multiplier: 1.5,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveSizer
                                            .borderRadiusFromConstraints(
                                          constraints,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the welcome text showing user name or default text
  Widget _buildWelcomeText(ThemeData theme, TextTheme textTheme) {
    if (currentUser != null) {
      // Show "Welcome, [Name]" for logged-in users
      final userName = currentUser!.displayNameOrFallback;
      return Row(
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Welcome, $userName',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      // Default text for non-logged-in state
      return Text(
        'Your courses',
        style: textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    }
  }
}
