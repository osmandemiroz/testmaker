import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';

/// A beautifully designed dialog for creating a new course.
class CreateCourseDialog extends StatefulWidget {
  const CreateCourseDialog({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  State<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends State<CreateCourseDialog> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TMDialog(
      title: 'New Course',
      subtitle: 'Give your course a name to get started',
      icon: Icon(
        Icons.add_rounded,
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
          onPressed: () {
            if (widget.controller.text.trim().isNotEmpty) {
              Navigator.of(context).pop(widget.controller.text.trim());
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Create'),
        ),
      ],
      child: Focus(
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
          child: TextField(
            controller: widget.controller,
            autofocus: true,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Math 101, History',
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            onSubmitted: (String value) {
              if (value.trim().isNotEmpty) {
                Navigator.of(context).pop(value.trim());
              }
            },
          ),
        ),
      ),
    );
  }
}
