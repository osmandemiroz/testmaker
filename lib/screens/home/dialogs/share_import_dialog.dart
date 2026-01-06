import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/shared_content.dart';
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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Import Shared Content'),
      content: _buildContent(theme),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_content != null)
          ElevatedButton(
            onPressed: _selectedCourse != null && !_isLoading ? _import : null,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Import'),
          ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading && _content == null) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Text(_error!, style: TextStyle(color: theme.colorScheme.error));
    }

    if (_content == null) {
      return const Text('No content found.');
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _content!.type == SharedContentType.quiz
                  ? Icons.quiz
                  : Icons.style,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              _content!.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _content!.type == SharedContentType.quiz
                  ? 'Quiz'
                  : 'Flashcard Set',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Module to add to:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: widget.homeController,
            builder: (context, _) {
              final courses = widget.homeController.courses;
              if (courses.isEmpty) {
                return const Text(
                  'No modules created yet. Please create a module first.',
                );
              }

              return Container(
                constraints: const BoxConstraints(maxHeight: 200),
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return RadioListTile<Course>(
                      title: Text(course.name),
                      value: course,
                      groupValue: _selectedCourse,
                      onChanged: (value) =>
                          setState(() => _selectedCourse = value),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
