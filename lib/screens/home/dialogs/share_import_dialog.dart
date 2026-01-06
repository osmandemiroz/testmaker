import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/shared_content.dart';
import 'package:testmaker/screens/home/dialogs/tm_dialog.dart';
import 'package:testmaker/services/sharing_service.dart';

/// Dialog to import shared content.
class ShareImportDialog extends StatefulWidget {
  const ShareImportDialog({
    required this.sharedContentId,
    required this.homeController,
    super.key,
  });

  final String sharedContentId;
  final HomeController homeController;

  @override
  State<ShareImportDialog> createState() => _ShareImportDialogState();
}

class _ShareImportDialogState extends State<ShareImportDialog> {
  SharedContent? _content;
  bool _isLoading = true;
  String? _error;
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final content = await SharingService.instance
          .getSharedContent(widget.sharedContentId);
      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
          if (content == null) {
            _error = 'Shared content not found or link expired.';
          }
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load shared content: $e';
        });
      }
    }
  }

  Future<void> _import() async {
    if (_content == null || _selectedCourse == null) return;

    setState(() => _isLoading = true);

    try {
      if (_content!.type == SharedContentType.quiz) {
        await widget.homeController.importQuizToCourse(
          _selectedCourse!.id,
          _content!.asQuestions,
          _content!.title,
        );
      } else {
        await widget.homeController.importFlashcardSetToCourse(
          _selectedCourse!.id,
          _content!.asFlashcards,
          _content!.title,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported "${_content!.title}" to "${_selectedCourse!.name}"',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TMDialog(
      title: 'Import Content',
      subtitle: _content != null ? 'Choose where to add this content' : null,
      icon: Icon(
        Icons.system_update_alt_rounded,
        color: theme.colorScheme.primary,
        size: 32,
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
        if (_content != null)
          FilledButton(
            onPressed: _selectedCourse != null && !_isLoading ? _import : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Import'),
          ),
      ],
      child: _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading && _content == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_content == null) {
      return const Center(child: Text('No content found.'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _content!.type == SharedContentType.quiz
                      ? Icons.quiz_rounded
                      : Icons.style_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _content!.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _content!.type == SharedContentType.quiz
                          ? 'Quiz'
                          : 'Flashcard Set',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Select Module',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: widget.homeController,
          builder: (context, _) {
            final courses = widget.homeController.courses;
            if (courses.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No modules created yet. Please create a module first.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: courses.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final isSelected = _selectedCourse == course;
                  return InkWell(
                    onTap: () => setState(() => _selectedCourse = course),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: theme.colorScheme.outline,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
