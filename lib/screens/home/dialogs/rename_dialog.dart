import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Shows a dialog for renaming items (PDFs, quizzes, flashcards).
Future<void> showRenameDialog({
  required BuildContext context,
  required String title,
  required String currentName,
  required Future<void> Function(String) onSave,
}) async {
  final controller = TextEditingController(text: currentName);
  final result = await showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(
                  constraints,
                  multiplier: 1.67,
                ),
              ),
            ),
            title: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter a name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(constraints),
                  ),
                ),
              ),
              onSubmitted: (String value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(context).pop(value.trim());
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.of(context).pop(name);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != null && result.isNotEmpty) {
    await onSave(result);
  }
}
