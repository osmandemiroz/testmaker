import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testmaker/screens/home/dialogs/prompt_preview_dialog.dart';
import 'package:testmaker/screens/home/templates/prompt_generator.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Shows a dialog to generate a quiz prompt for AI agents.
Future<void> showQuizPromptDialog(
  BuildContext context,
  ThemeData theme,
  TextTheme textTheme,
  BoxConstraints constraints,
) async {
  // Quiz types
  final quizTypes = <String>[
    'Multiple Choice',
    'True/False',
    'Fill in the Blank',
    'Short Answer',
  ];
  String? selectedType;
  int? count;

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                  'Generate Quiz Prompt',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: SizedBox(
                  width: ResponsiveSizer.maxContentWidthFromConstraints(
                    constraints,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Quiz type selection
                      Text(
                        'Quiz Type:',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                        ),
                      ),
                      ...quizTypes.map<Widget>(
                        (String type) => RadioListTile<String>(
                          title: Text(type),
                          value: type,
                          groupValue: selectedType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedType = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 1.5,
                        ),
                      ),
                      // Count input
                      Text(
                        'Number of Questions:',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveSizer.spacingFromConstraints(
                          constraints,
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter number (1-50)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveSizer.borderRadiusFromConstraints(
                                constraints,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (String value) {
                          setState(() {
                            count = int.tryParse(value);
                          });
                        },
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
                    onPressed: selectedType != null &&
                            count != null &&
                            count! > 0 &&
                            count! <= 50
                        ? () {
                            Navigator.of(context).pop(<String, dynamic>{
                              'type': selectedType,
                              'count': count,
                            });
                          }
                        : null,
                    child: const Text('Generate'),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );

  if (result != null && context.mounted) {
    final prompt = PromptGenerator.generateQuizPrompt(
      result['type'] as String,
      result['count'] as int,
    );
    await Clipboard.setData(ClipboardData(text: prompt));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Show the prompt to the user
      await showPromptPreview(
        context,
        theme,
        textTheme,
        constraints,
        prompt,
        'Quiz',
      );
    }
  }
}
