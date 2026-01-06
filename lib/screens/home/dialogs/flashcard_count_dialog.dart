import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';

/// Shows a dialog to ask the user how many flashcards to generate.
///
/// Returns the flashcard count if confirmed, null if cancelled.
Future<int?> showFlashcardCountDialog(BuildContext context) async {
  final result = await showDialog<int>(
    context: context,
    builder: (BuildContext context) => const _FlashcardCountDialogContent(),
  );

  return result;
}

class _FlashcardCountDialogContent extends StatefulWidget {
  const _FlashcardCountDialogContent();

  @override
  State<_FlashcardCountDialogContent> createState() =>
      _FlashcardCountDialogContentState();
}

class _FlashcardCountDialogContentState
    extends State<_FlashcardCountDialogContent> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '10');
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
      title: 'Flashcard Count',
      subtitle: 'How many flashcards would you like to generate from this PDF?',
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.style_rounded,
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
            final text = _controller.text.trim();
            final count = int.tryParse(text);
            if (count != null && count > 0 && count <= 100) {
              Navigator.of(context).pop(count);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      const Text('Please enter a number between 1 and 100'),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Generate'),
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
                style:
                    textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 10',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  labelText: 'Number of Flashcards',
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommended: 10-30 flashcards',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
