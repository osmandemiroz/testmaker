import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/widgets/widgets.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the content templates section with ready-made prompts for quizzes and flashcards.
///
/// This section provides users with prompts they can use with AI agents
/// to generate quiz and flashcard content, which they can then paste
/// directly into the application.
class ContentTemplatesSection extends StatelessWidget {
  const ContentTemplatesSection({
    required this.onQuizTap,
    required this.onFlashcardTap,
    super.key,
  });

  final VoidCallback onQuizTap;
  final VoidCallback onFlashcardTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section header
            Text(
              'Content Templates',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
            ),
            Text(
              'Generate prompts for AI agents to create quiz and flashcard content. '
              'Select the type and count, then copy the prompt to use with your AI agent. '
              'Paste the generated content directly into the app - no files needed!',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(
              height:
                  ResponsiveSizer.sectionSpacingFromConstraints(constraints),
            ),
            // Quiz template button with staggered animation
            _TemplateButton(
              theme: theme,
              textTheme: textTheme,
              constraints: constraints,
              title: 'Quiz Template',
              icon: Icons.quiz,
              onTap: onQuizTap,
              animationDelay: 0,
            ),
            SizedBox(
              height: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
            ),
            // Flashcard template button with staggered animation
            _TemplateButton(
              theme: theme,
              textTheme: textTheme,
              constraints: constraints,
              title: 'Flashcard Template',
              icon: Icons.style,
              onTap: onFlashcardTap,
              animationDelay: 100,
            ),
          ],
        );
      },
    );
  }
}

/// Builds a template button that opens a prompt generation dialog.
class _TemplateButton extends StatelessWidget {
  const _TemplateButton({
    required this.theme,
    required this.textTheme,
    required this.constraints,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.animationDelay,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final BoxConstraints constraints;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int animationDelay;

  @override
  Widget build(BuildContext context) {
    return AnimatedTemplateButton(
      delay: Duration(milliseconds: animationDelay),
      child: Card(
        elevation: 0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(constraints),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(
                ResponsiveSizer.cardPaddingFromConstraints(constraints),
              ),
              child: Row(
                children: <Widget>[
                  // Icon
                  Icon(
                    icon,
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
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: ResponsiveSizer.iconSizeFromConstraints(constraints),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
