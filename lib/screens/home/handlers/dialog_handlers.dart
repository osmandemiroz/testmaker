import 'package:flutter/material.dart';
import 'package:testmaker/screens/home/dialogs/create_course_dialog.dart';
import 'package:testmaker/screens/home/dialogs/dialogs.dart' as dialogs;
import 'package:testmaker/screens/home/dialogs/manual_import_dialog.dart';
import 'package:testmaker/screens/home/dialogs/settings_dialog.dart';

/// Handlers for showing dialogs.
class DialogHandlers {
  /// Shows a dialog to rename an item (quiz, PDF, or flashcard set).
  static Future<void> showRenameDialog({
    required BuildContext context,
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) async {
    await dialogs.showRenameDialog(
      context: context,
      title: title,
      currentName: currentName,
      onSave: onSave,
    );
  }

  /// Shows a beautifully designed dialog to create a new course.
  static Future<String?> showCreateCourseDialog(BuildContext context) async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return CreateCourseDialog(controller: textController);
      },
    );

    return result;
  }

  /// Shows the settings dialog with options to change the API key.
  static Future<void> showSettingsDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const SettingsDialog();
      },
    );
  }

  /// Shows the manual import dialog.
  static Future<String?> showManualImportDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return const ManualImportDialog();
      },
    );

    return result;
  }
}
