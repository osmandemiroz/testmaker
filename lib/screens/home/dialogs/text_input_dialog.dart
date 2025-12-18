import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Shows a dialog for pasting text content (quiz or flashcard).
Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  required String hint,
  required String label,
}) async {
  final controller = TextEditingController();
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
            content: SizedBox(
              width: ResponsiveSizer.maxContentWidthFromConstraints(
                constraints,
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                maxLines: 15,
                minLines: 10,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizer.borderRadiusFromConstraints(
                        constraints,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.of(context).pop(text);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );

  return result;
}
