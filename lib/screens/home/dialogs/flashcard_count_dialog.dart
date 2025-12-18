import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Shows a dialog to ask the user how many flashcards to generate.
///
/// Returns the flashcard count if confirmed, null if cancelled.
Future<int?> showFlashcardCountDialog(BuildContext context) async {
  final controller = TextEditingController(text: '10');

  final result = await showDialog<int>(
    context: context,
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
              'Number of Flashcards',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'How many flashcards would you like to generate from this PDF?',
                    style: textTheme.bodyMedium,
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 2,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Flashcard Count',
                      hintText: 'Enter a number (e.g., 10)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizer.borderRadiusFromConstraints(
                            constraints,
                          ),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(constraints),
                  ),
                  Text(
                    'Recommended: 10-30 flashcards',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
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
                  final count = int.tryParse(text);
                  if (count != null && count > 0 && count <= 100) {
                    Navigator.of(context).pop(count);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a number between 1 and 100',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Generate'),
              ),
            ],
          );
        },
      );
    },
  );

  return result;
}
