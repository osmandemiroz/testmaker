import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';

/// Shows a generic delete confirmation dialog.
Future<bool?> _showDeleteConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  required String itemName,
}) async {
  final theme = Theme.of(context);

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return TMDialog(
        title: title,
        subtitle: message,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.error,
            size: 32,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Item: $itemName',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
  );
}

/// Shows delete confirmation dialog for a PDF.
Future<bool?> showDeletePdfConfirmation(
  BuildContext context,
  String fileName,
) async {
  return _showDeleteConfirmation(
    context: context,
    title: 'Delete PDF?',
    message: 'This action cannot be undone. Are you sure?',
    itemName: fileName,
  );
}

/// Shows delete confirmation dialog for a quiz.
Future<bool?> showDeleteQuizConfirmation(
  BuildContext context,
  String quizName,
) async {
  return _showDeleteConfirmation(
    context: context,
    title: 'Delete Quiz?',
    message: 'This action cannot be undone. Are you sure?',
    itemName: quizName,
  );
}

/// Shows delete confirmation dialog for a flashcard set.
Future<bool?> showDeleteFlashcardSetConfirmation(
  BuildContext context,
  String flashcardSetName,
) async {
  return _showDeleteConfirmation(
    context: context,
    title: 'Delete Flashcard Set?',
    message: 'This action cannot be undone. Are you sure?',
    itemName: flashcardSetName,
  );
}
