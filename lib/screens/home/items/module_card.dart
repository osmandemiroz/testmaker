import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds a single module card showing the course and its contents.
class ModuleCard extends StatelessWidget {
  const ModuleCard({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.constraints,
    required this.isExpanded,
    required this.onToggle,
    required this.buildContents,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final BoxConstraints constraints;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget Function() buildContents;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
          multiplier: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Module header - clickable to expand/collapse
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints),
              ),
              topRight: Radius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(
                ResponsiveSizer.cardPaddingFromConstraints(constraints),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.folder,
                    color: theme.colorScheme.primary,
                    size: ResponsiveSizer.iconSizeFromConstraints(
                      constraints,
                      multiplier: 1.4,
                    ),
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
                      children: <Widget>[
                        Text(
                          course.name,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (course.quizCount > 0 ||
                            course.flashcardSetCount > 0 ||
                            course.pdfCount > 0)
                          Text(
                            [
                              if (course.quizCount > 0)
                                '${course.quizCount} quiz${course.quizCount == 1 ? '' : 'zes'}',
                              if (course.flashcardSetCount > 0)
                                '${course.flashcardSetCount} flashcard set${course.flashcardSetCount == 1 ? '' : 's'}',
                              if (course.pdfCount > 0)
                                '${course.pdfCount} PDF${course.pdfCount == 1 ? '' : 's'}',
                            ].join(' • '),
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Module contents - visible when expanded with smooth animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveSizer.cardPaddingFromConstraints(constraints),
                      0,
                      ResponsiveSizer.cardPaddingFromConstraints(constraints),
                      ResponsiveSizer.cardPaddingFromConstraints(constraints),
                    ),
                    child: buildContents(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
