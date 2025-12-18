import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds a PDF item in the module contents view.
class ModulePdfItem extends StatelessWidget {
  const ModulePdfItem({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.pdfIndex,
    required this.fileName,
    required this.pdfPath,
    required this.pdfName,
    required this.constraints,
    required this.onViewPdf,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final int pdfIndex;
  final String fileName;
  final String pdfPath;
  final String pdfName;
  final BoxConstraints constraints;
  final void Function(String pdfPath, String pdfName) onViewPdf;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
        ),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          Icons.picture_as_pdf,
          color: theme.colorScheme.primary,
          size: ResponsiveSizer.iconSizeFromConstraints(constraints),
        ),
        title: Text(
          pdfName,
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          fileName,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.open_in_new,
            size: ResponsiveSizer.iconSizeFromConstraints(constraints),
          ),
          onPressed: () => onViewPdf(pdfPath, pdfName),
          tooltip: 'View PDF',
        ),
      ),
    );
  }
}

/// Builds a quiz item in the module contents view.
class ModuleQuizItem extends StatelessWidget {
  const ModuleQuizItem({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.quizIndex,
    required this.quizName,
    required this.questionCount,
    required this.constraints,
    required this.onStartQuiz,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final int quizIndex;
  final String quizName;
  final int questionCount;
  final BoxConstraints constraints;
  final void Function(Course course, int quizIndex) onStartQuiz;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
        ),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          Icons.quiz,
          color: theme.colorScheme.primary,
          size: ResponsiveSizer.iconSizeFromConstraints(constraints),
        ),
        title: Text(
          quizName,
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          '$questionCount question${questionCount == 1 ? '' : 's'}',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: FilledButton(
          onPressed: () => onStartQuiz(course, quizIndex),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 0.75,
              ),
            ),
          ),
          child: const Text('Start'),
        ),
      ),
    );
  }
}

/// Builds a flashcard item in the module contents view.
class ModuleFlashcardItem extends StatelessWidget {
  const ModuleFlashcardItem({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.flashcardSetIndex,
    required this.flashcardSetName,
    required this.flashcardCount,
    required this.constraints,
    required this.onStartFlashcards,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final int flashcardSetIndex;
  final String flashcardSetName;
  final int flashcardCount;
  final BoxConstraints constraints;
  final void Function(Course course, int flashcardSetIndex) onStartFlashcards;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSizer.spacingFromConstraints(
          constraints,
        ),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          Icons.style,
          color: theme.colorScheme.primary,
          size: ResponsiveSizer.iconSizeFromConstraints(constraints),
        ),
        title: Text(
          flashcardSetName,
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          '$flashcardCount flashcard${flashcardCount == 1 ? '' : 's'}',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: FilledButton(
          onPressed: () => onStartFlashcards(course, flashcardSetIndex),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 1.5,
              ),
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 0.75,
              ),
            ),
          ),
          child: const Text('Start'),
        ),
      ),
    );
  }
}
