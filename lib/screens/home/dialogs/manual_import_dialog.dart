import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';

/// A dialog that allows users to manually enter a share code to import content.
class ManualImportDialog extends StatefulWidget {
  const ManualImportDialog({super.key});

  @override
  State<ManualImportDialog> createState() => _ManualImportDialogState();
}

class _ManualImportDialogState extends State<ManualImportDialog> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
      title: 'Import Content',
      subtitle: 'Enter the share code to import a quiz or flashcard set.',
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.download_rounded,
          color: theme.colorScheme.primary,
          size: 32,
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final code = _controller.text.trim();
            if (code.isNotEmpty) {
              Navigator.of(context).pop(code);
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Import'),
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
              child: TextField(
                controller: _controller,
                autofocus: true,
                style:
                    textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. YEmonb4W...',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  labelText: 'Share Code',
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                onSubmitted: (value) {
                  final code = value.trim();
                  if (code.isNotEmpty) {
                    Navigator.of(context).pop(code);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
