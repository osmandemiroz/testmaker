import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/templates/templates.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds an empty state when no modules exist.
class EmptyModulesState extends StatelessWidget {
  const EmptyModulesState({
    required this.theme,
    required this.textTheme,
    required this.constraints,
    required this.onCreateModule,
    required this.onQuizPromptTap,
    required this.onFlashcardPromptTap,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final BoxConstraints constraints;
  final VoidCallback onCreateModule;
  final VoidCallback onQuizPromptTap;
  final VoidCallback onFlashcardPromptTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Empty state message
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_outlined,
              size: ResponsiveSizer.iconSizeFromConstraints(
                constraints,
                multiplier: 4,
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
              'No modules yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(constraints),
            ),
            Text(
              'Swipe from the left or tap the menu to create your first module',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            // Button to create first module
            FilledButton.icon(
              onPressed: onCreateModule,
              icon: const Icon(Icons.add),
              label: const Text('Create Module'),
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
              ),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
        ),
        // Content Templates section - also show when no modules exist
        ContentTemplatesSection(
          onQuizTap: onQuizPromptTap,
          onFlashcardTap: onFlashcardPromptTap,
        ),
      ],
    );
  }
}
