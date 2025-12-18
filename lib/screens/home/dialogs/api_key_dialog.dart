// ignore_for_file: use_build_context_synchronously, document_ignores

import 'package:flutter/material.dart';
import 'package:testmaker/services/question_generator_service.dart';
import 'package:testmaker/utils/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a dialog to set the Google AI API key.
///
/// Returns true if the API key was successfully set, false if cancelled.
Future<bool> showApiKeyDialog(BuildContext context) async {
  final controller = TextEditingController();
  final currentKey = await QuestionGeneratorService.getApiKey() ?? '';

  final result = await showDialog<bool>(
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
              'API Key Required',
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
                    'To generate questions from PDFs, you need a Google AI API key.',
                    style: textTheme.bodyMedium,
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 2,
                    ),
                  ),
                  TextField(
                    controller: controller..text = currentKey,
                    decoration: InputDecoration(
                      labelText: 'Google AI API Key',
                      hintText: 'Enter your API key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizer.borderRadiusFromConstraints(
                            constraints,
                          ),
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 1.5,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(
                        'https://makersuite.google.com/app/apikey',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.open_in_new,
                      size: ResponsiveSizer.iconSizeFromConstraints(
                        constraints,
                        multiplier: 0.67,
                      ),
                    ),
                    label: const Text('Get API Key'),
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(constraints),
                  ),
                  Text(
                    'Get your free API key from:\nhttps://makersuite.google.com/app/apikey',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    await QuestionGeneratorService.setApiKey(
                      controller.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('API key saved successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
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

  return result ?? false;
}
