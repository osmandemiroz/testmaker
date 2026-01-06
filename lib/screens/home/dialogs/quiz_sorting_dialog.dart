import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// A dialog that asks the user how they want to take the quiz.
class QuizSortingDialog extends StatelessWidget {
  const QuizSortingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return AlertDialog(
          title: const Text('Quiz Order'),
          content: const Text(
            'How would you like to take this quiz?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(constraints),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(QuizSortingPreference.sequential),
              child: const Text('Sequential'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(QuizSortingPreference.random),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints),
                  ),
                ),
              ),
              child: const Text('Random'),
            ),
          ],
        );
      },
    );
  }
}

/// Shows the [QuizSortingDialog] and returns the selected preference.
Future<QuizSortingPreference?> showQuizSortingDialog(BuildContext context) {
  return showDialog<QuizSortingPreference>(
    context: context,
    builder: (context) => const QuizSortingDialog(),
  );
}
