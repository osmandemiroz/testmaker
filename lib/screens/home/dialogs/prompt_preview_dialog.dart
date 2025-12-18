import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Shows a preview of the generated prompt.
Future<void> showPromptPreview(
  BuildContext context,
  ThemeData theme,
  TextTheme textTheme,
  BoxConstraints constraints,
  String prompt,
  String title,
) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (BuildContext context) {
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
              '$title Prompt Generated',
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
                  Text(
                    'The prompt has been copied to your clipboard. '
                    'Paste it into your AI agent to generate the content, '
                    'then paste the result back into the app.',
                    style: textTheme.bodyMedium,
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 1.5,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 20,
                      ),
                    ),
                    padding: EdgeInsets.all(
                      ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 1.5,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        ResponsiveSizer.borderRadiusFromConstraints(
                          constraints,
                        ),
                      ),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        prompt,
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );
}
