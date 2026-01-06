import 'package:flutter/material.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';

/// A dialog that asks the user how they want to take the quiz.
class QuizSortingDialog extends StatelessWidget {
  const QuizSortingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TMDialog(
      title: 'Quiz Order',
      subtitle: 'How would you like to take this quiz?',
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.sort_rounded,
          color: theme.colorScheme.primary,
          size: 32,
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () =>
              Navigator.of(context).pop(QuizSortingPreference.sequential),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Sequential'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(QuizSortingPreference.random),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Randomly'),
        ),
      ],
      child: const SizedBox(height: 8),
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
