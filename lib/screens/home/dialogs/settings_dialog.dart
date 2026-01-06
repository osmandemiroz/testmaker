import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';
import 'package:testmaker/services/question_generator_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// A beautifully designed settings dialog.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _apiKeyController;
  bool _isFocused = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _loadApiKey();
  }

  /// Loads the current API key from storage.
  Future<void> _loadApiKey() async {
    final currentKey = await QuestionGeneratorService.getApiKey() ?? '';
    if (mounted) {
      setState(() {
        _apiKeyController.text = currentKey;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TMDialog(
      title: 'Settings',
      subtitle: 'Manage your app preferences',
      icon: Icon(
        Icons.settings_rounded,
        color: theme.colorScheme.primary,
        size: 32,
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await QuestionGeneratorService.setApiKey(
              _apiKeyController.text.trim().isEmpty
                  ? null
                  : _apiKeyController.text.trim(),
            );
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Settings saved successfully!',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Google AI API Key',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
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
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Get Key'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Required for generating questions from PDFs',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Focus(
            onFocusChange: (bool hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
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
                      controller: _apiKeyController,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
        ],
      ),
    );
  }
}
