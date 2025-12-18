import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds a card for a quiz in a course.
class QuizCard extends StatelessWidget {
  const QuizCard({
    required this.theme,
    required this.textTheme,
    required this.controller,
    required this.course,
    required this.quizIndex,
    required this.questionCount,
    required this.onTap,
    required this.showRenameDialog,
    required this.onDelete,
    required this.constraints,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final HomeController controller;
  final Course course;
  final int quizIndex;
  final int questionCount;
  final VoidCallback onTap;
  final Future<void> Function({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) showRenameDialog;
  final void Function(Course course, int quizIndex, String quizName) onDelete;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final quizName = course.getQuizName(quizIndex);
    return Container(
      margin: ResponsiveSizer.cardMarginFromConstraints(constraints),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(constraints),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ResponsiveSizer.borderRadiusFromConstraints(constraints),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveSizer.cardPaddingFromConstraints(constraints),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                    multiplier: 1.2,
                  ),
                  height: ResponsiveSizer.iconContainerSizeFromConstraints(
                    constraints,
                    multiplier: 1.2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                      ),
                    ),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveSizer.spacingFromConstraints(
                    constraints,
                    multiplier: 2,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        quizName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 0.5,
                        ),
                      ),
                      Text(
                        '$questionCount question${questionCount == 1 ? '' : 's'}',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  onPressed: () => showRenameDialog(
                    title: 'Rename Quiz',
                    currentName: quizName,
                    onSave: (String newName) async {
                      await controller.renameQuiz(quizIndex, newName);
                    },
                  ),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 0.9,
                    ),
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  tooltip: 'Rename',
                ),
                // Delete button
                IconButton(
                  onPressed: () => onDelete(course, quizIndex, quizName),
                  icon: Icon(
                    Icons.delete_outlined,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 0.9,
                    ),
                  ),
                  color: theme.colorScheme.error,
                  tooltip: 'Delete',
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: ResponsiveSizer.iconSizeFromConstraints(
                    constraints,
                    multiplier: 0.8,
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
