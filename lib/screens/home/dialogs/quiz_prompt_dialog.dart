import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testmaker/screens/home/dialogs/prompt_preview_dialog.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';
import 'package:testmaker/screens/home/templates/prompt_generator.dart';

/// Shows a dialog to generate a quiz prompt for AI agents.
Future<void> showQuizPromptDialog(
  BuildContext context,
  ThemeData theme,
  TextTheme textTheme,
  BoxConstraints constraints,
) async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (BuildContext context) => const _QuizPromptDialogContent(),
  );

  if (result != null && context.mounted) {
    final prompt = PromptGenerator.generateQuizPrompt(
      result['type'] as String,
      result['count'] as int,
    );
    await Clipboard.setData(ClipboardData(text: prompt));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prompt copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _QuizPromptDialogContent extends StatefulWidget {
  const _QuizPromptDialogContent();

  @override
  State<_QuizPromptDialogContent> createState() =>
      _QuizPromptDialogContentState();
}

class _QuizPromptDialogContentState extends State<_QuizPromptDialogContent> {
  final List<String> _quizTypes = [
    'Multiple Choice',
    'True/False',
    'Fill in the Blank',
    'Short Answer',
  ];
  String? _selectedType;
  late TextEditingController _countController;
  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: '10');
    _selectedType = _quizTypes.first;
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TMDialog(
      title: 'Quiz Prompt',
      subtitle: 'Configure and generate a prompt for AI study agents.',
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
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
          onPressed: _selectedType != null &&
                  int.tryParse(_countController.text) != null &&
                  int.parse(_countController.text) > 0
              ? () {
                  Navigator.of(context).pop(<String, dynamic>{
                    'type': _selectedType,
                    'count': int.parse(_countController.text),
                  });
                }
              : null,
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
          Text(
            'Quiz Type',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          ..._quizTypes.map((type) {
            final isSelected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedType = type),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 20,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        type,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Number of Questions',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (hasFocus) =>
                setState(() => _isInputFocused = hasFocus),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isInputFocused
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: _isInputFocused ? 2 : 1.5,
                ),
                color: _isInputFocused
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.05)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
              ),
              child: TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                style:
                    textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g., 10',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
