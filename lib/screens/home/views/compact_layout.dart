import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/views/sidebar.dart';
import 'package:testmaker/screens/home/widgets/swipe_indicator_arrow.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the compact layout for smaller screens (uses drawer).
class CompactLayout extends StatelessWidget {
  const CompactLayout({
    required this.controller,
    required this.theme,
    required this.constraints,
    required this.showSwipeIndicator,
    required this.buildMainContent,
    required this.onCreateCourse,
    required this.onDeleteCourse,
    super.key,
  });

  final HomeController controller;
  final ThemeData theme;
  final BoxConstraints constraints;
  final bool showSwipeIndicator;
  final Widget Function(ThemeData theme) buildMainContent;
  final VoidCallback onCreateCourse;
  final Future<void> Function(Course course) onDeleteCourse;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints itemConstraints) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          drawer: Drawer(
            width: ResponsiveSizer.sidebarWidthFromConstraints(itemConstraints),
            child: Sidebar(
              controller: controller,
              onCreateCourse: onCreateCourse,
              onDeleteCourse: onDeleteCourse,
              onSelectCourse: (course) {
                controller
                  ..selectCourse(course)
                  ..clearError();
              },
            ),
          ),
          body: Stack(
            children: <Widget>[
              // Container with background color extends edge-to-edge
              ColoredBox(
                color: theme.colorScheme.surface,
                child: buildMainContent(theme),
              ),
              // Swipe indicator overlay for mobile
              if (showSwipeIndicator)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 60,
                      alignment: Alignment.centerLeft,
                      child: SwipeIndicatorArrow(theme: theme),
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
