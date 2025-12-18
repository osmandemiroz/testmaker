import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds a card for a flashcard set in a course.
class FlashcardCard extends StatelessWidget {
  const FlashcardCard({
    required this.theme,
    required this.textTheme,
    required this.controller,
    required this.course,
    required this.flashcardSetIndex,
    required this.flashcardCount,
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
  final int flashcardSetIndex;
  final int flashcardCount;
  final VoidCallback onTap;
  final Future<void> Function({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) showRenameDialog;
  final void Function(
    Course course,
    int flashcardSetIndex,
    String flashcardSetName,
  ) onDelete;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final flashcardSetName = course.getFlashcardSetName(flashcardSetIndex);
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
                    color: theme.colorScheme.secondaryContainer,
                  ),
                  child: Icon(
                    Icons.style_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
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
                        flashcardSetName,
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
                        '$flashcardCount flashcard${flashcardCount == 1 ? '' : 's'}',
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
                    title: 'Rename Flashcard Set',
                    currentName: flashcardSetName,
                    onSave: (String newName) async {
                      await controller.renameFlashcardSet(
                        flashcardSetIndex,
                        newName,
                      );
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
                  onPressed: () => onDelete(
                    course,
                    flashcardSetIndex,
                    flashcardSetName,
                  ),
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
