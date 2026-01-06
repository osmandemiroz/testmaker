// ignore_for_file: use_build_context_synchronously, document_ignores

import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';
import 'package:testmaker/services/question_generator_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a dialog to set the Google AI API key.
///
/// Returns true if the API key was successfully set, false if cancelled.
Future<bool> showApiKeyDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => const _ApiKeyDialogContent(),
  );

  return result ?? false;
}

class _ApiKeyDialogContent extends StatefulWidget {
  const _ApiKeyDialogContent();

  @override
  State<_ApiKeyDialogContent> createState() => _ApiKeyDialogContentState();
}

class _ApiKeyDialogContentState extends State<_ApiKeyDialogContent> {
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _isLoading = true;
  String _currentKey = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadKey();
  }

  Future<void> _loadKey() async {
    _currentKey = await QuestionGeneratorService.getApiKey() ?? '';
    if (mounted) {
      setState(() {
        _controller.text = _currentKey;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TMDialog(
      title: 'API Key Required',
      subtitle:
          'To generate questions from PDFs, you need a Google AI API key.',
      icon: Icon(
        Icons.vpn_key_rounded,
        color: theme.colorScheme.primary,
        size: 32,
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (_controller.text.trim().isNotEmpty) {
              await QuestionGeneratorService.setApiKey(
                _controller.text.trim(),
              );
              if (context.mounted) {
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('API key saved successfully!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Save'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Focus(
            onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFocused
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: _isFocused ? 2 : 1.5,
                ),
                color: _isFocused
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.05)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : TextField(
                      controller: _controller,
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Enter your API key',
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      obscureText: true,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () async {
              final url = Uri.parse('https://makersuite.google.com/app/apikey');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Get API Key from Google AI Studio'),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
