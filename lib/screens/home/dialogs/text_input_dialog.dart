import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';

/// Shows a dialog for pasting text content (quiz or flashcard).
Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  required String hint,
  required String label,
}) async {
  final result = await showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (BuildContext context) => _TextInputDialogContent(
      title: title,
      hint: hint,
      label: label,
    ),
  );

  return result;
}

class _TextInputDialogContent extends StatefulWidget {
  const _TextInputDialogContent({
    required this.title,
    required this.hint,
    required this.label,
  });

  final String title;
  final String hint;
  final String label;

  @override
  State<_TextInputDialogContent> createState() =>
      _TextInputDialogContentState();
}

class _TextInputDialogContentState extends State<_TextInputDialogContent> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TMDialog(
      title: widget.title,
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.post_add_rounded,
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
            if (text.isNotEmpty) {
              Navigator.of(context).pop(text);
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Add Content'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: _focusNode.hasFocus ? 2 : 1.5,
              ),
              color: _focusNode.hasFocus
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.05)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              maxLines: 12,
              minLines: 5,
              enableInteractiveSelection: true,
              contextMenuBuilder: (context, editableTextState) {
                return AdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                );
              },
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                labelText: widget.label,
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: _focusNode.hasFocus
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                alignLabelWithHint: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
