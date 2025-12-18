import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/screens/home/items/module_items.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the contents of a module (quizzes, flashcards, PDFs).
class ModuleContents extends StatelessWidget {
  const ModuleContents({
    required this.theme,
    required this.textTheme,
    required this.course,
    required this.constraints,
    required this.onViewPdf,
    required this.onStartQuiz,
    required this.onStartFlashcards,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final Course course;
  final BoxConstraints constraints;
  final void Function(String pdfPath, String pdfName) onViewPdf;
  final void Function(Course course, int quizIndex) onStartQuiz;
  final void Function(Course course, int flashcardSetIndex) onStartFlashcards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // PDFs section
        if (course.pdfs.isNotEmpty) ...<Widget>[
          Text(
            'Study Materials',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          ...course.pdfs.asMap().entries.map<Widget>(
            (MapEntry<int, String> entry) {
              final index = entry.key;
              final pdfPath = entry.value;
              final fileName = pdfPath.split('/').last;
              final pdfName = course.getPdfName(index, pdfPath);

              return ModulePdfItem(
                theme: theme,
                textTheme: textTheme,
                course: course,
                pdfIndex: index,
                fileName: fileName,
                pdfPath: pdfPath,
                pdfName: pdfName,
                constraints: constraints,
                onViewPdf: onViewPdf,
              );
            },
          ),
          SizedBox(
            height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
          ),
        ],
        // Quizzes section
        if (course.quizzes.isNotEmpty) ...<Widget>[
          Text(
            'Quizzes',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          ...course.quizzes.asMap().entries.map<Widget>(
            (MapEntry<int, List<Question>> entry) {
              final index = entry.key;
              final questions = entry.value;
              final quizName = course.getQuizName(index);

              return ModuleQuizItem(
                theme: theme,
                textTheme: textTheme,
                course: course,
                quizIndex: index,
                quizName: quizName,
                questionCount: questions.length,
                constraints: constraints,
                onStartQuiz: onStartQuiz,
              );
            },
          ),
          SizedBox(
            height: ResponsiveSizer.sectionSpacingFromConstraints(constraints),
          ),
        ],
        // Flashcards section
        if (course.flashcards.isNotEmpty) ...<Widget>[
          Text(
            'Flashcards',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 1.5,
            ),
          ),
          ...course.flashcards.asMap().entries.map<Widget>(
            (MapEntry<int, List<Flashcard>> entry) {
              final index = entry.key;
              final flashcards = entry.value;
              final flashcardSetName = course.getFlashcardSetName(index);

              return ModuleFlashcardItem(
                theme: theme,
                textTheme: textTheme,
                course: course,
                flashcardSetIndex: index,
                flashcardSetName: flashcardSetName,
                flashcardCount: flashcards.length,
                constraints: constraints,
                onStartFlashcards: onStartFlashcards,
              );
            },
          ),
        ],
        // Empty state if module has no content
        if (course.quizzes.isEmpty &&
            course.flashcards.isEmpty &&
            course.pdfs.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveSizer.spacingFromConstraints(
                constraints,
                multiplier: 2,
              ),
            ),
            child: Center(
              child: Text(
                'No content yet. Add quizzes, flashcards, or PDFs to this module.',
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
