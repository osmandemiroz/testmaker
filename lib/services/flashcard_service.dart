// ignore_for_file: curly_braces_in_flow_control_structures, document_ignores

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import 'package:testmaker/models/flashcard.dart';

/// ********************************************************************
/// FlashcardService
/// ********************************************************************
///
/// Service layer responsible for loading flashcards from JSON.
/// This keeps asset + parsing logic out of the widgets and makes it easy
/// to swap in a different JSON file or change the storage mechanism later.
///
class FlashcardService {
  const FlashcardService();

  /// Default asset path used by the app.
  ///
  /// To use a different flashcard set, you can either:
  ///  - Replace the file at this path, or
  ///  - Call [loadFlashcards] with a different asset path.
  static const String defaultFlashcardAssetPath =
      'assets/flashcards/sample_flashcards.json';

  /// Loads a list of [Flashcard] objects from the given JSON asset.
  ///
  /// The expected JSON top level structure is a list:
  /// [
  ///   { "id": 1, "front": "...", "back": "...", "explanation": "..." },
  ///   ...
  /// ]
  Future<List<Flashcard>> loadFlashcards({
    String assetPath = defaultFlashcardAssetPath,
  }) async {
    // NOTE: Keeping this method small and focused: load -> decode -> map.
    try {
      final raw = await rootBundle.loadString(assetPath);
      return _decodeFlashcards(raw);
    } on Exception {
      // If asset doesn't exist, return empty list
      return <Flashcard>[];
    }
  }

  /// Loads flashcards from an arbitrary JSON file on disk.
  ///
  /// This is used when the user selects their own flashcard JSON via the
  /// upload functionality.
  Future<List<Flashcard>> loadFlashcardsFromFile(String filePath) async {
    final file = File(filePath);
    final raw = await file.readAsString();

    return _decodeFlashcards(raw);
  }

  /// Shared JSON decoding logic so both asset and file loading paths
  /// behave identically.
  List<Flashcard> _decodeFlashcards(String rawJson) {
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final flashcards = decoded
        .map<Flashcard>(
          (dynamic item) => Flashcard.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);

    return flashcards;
  }

  /// Parses flashcards from pasted text.
  ///
  /// First tries to parse as JSON (for AI-generated content).
  /// If that fails, attempts to parse as simple text format.
  /// Returns a list of [Flashcard] objects.
  ///
  /// Throws [FormatException] if the text cannot be parsed.
  List<Flashcard> parseFlashcardsFromText(String text) {
    // Trim whitespace
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw const FormatException('No content provided');
    }

    // First, try to parse as JSON (most common case with AI-generated content)
    try {
      return _decodeFlashcards(trimmedText);
    } on FormatException {
      // If JSON parsing fails, try simple text format
      return _parseFlashcardsFromSimpleText(trimmedText);
    }
  }

  /// Splits text by blank lines (newline, optional whitespace, newline)
  /// without using RegExp to avoid deprecation.
  List<String> _splitByBlankLines(String text) {
    final blocks = <String>[];
    final lines = text.split('\n');
    final currentBlock = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Check if line is empty or contains only whitespace
      if (line.trim().isEmpty) {
        // If we have content in current block, save it and start new block
        if (currentBlock.isNotEmpty) {
          blocks.add(currentBlock.join('\n'));
          currentBlock.clear();
        }
        // Skip the blank line(s)
        continue;
      }
      // Add non-blank line to current block
      currentBlock.add(line);
    }

    // Add the last block if it has content
    if (currentBlock.isNotEmpty) {
      blocks.add(currentBlock.join('\n'));
    }

    return blocks;
  }

  /// Parses flashcards from a simple text format.
  ///
  /// Expected format (one flashcard per block, separated by blank lines):
  /// Front: Question or term
  /// Back: Answer or definition
  /// Explanation: Optional explanation
  ///
  /// Or simpler format:
  /// Q: Question
  /// A: Answer
  ///
  /// Or tab-separated:
  /// Term\tDefinition
  List<Flashcard> _parseFlashcardsFromSimpleText(String text) {
    final flashcards = <Flashcard>[];
    // Split by blank lines without RegExp to avoid deprecation
    // Pattern: \n\s*\n (newline, optional whitespace, newline)
    final blocks = _splitByBlankLines(text);

    var flashcardId = 1;
    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      try {
        String? front;
        String? back;
        String? explanation;

        // Try different formats
        for (final line in lines) {
          if (line.startsWith('Front:') || line.startsWith('Q:')) {
            front = line.substring(line.indexOf(':') + 1).trim();
          } else if (line.startsWith('Back:') || line.startsWith('A:')) {
            back = line.substring(line.indexOf(':') + 1).trim();
          } else if (line.startsWith('Explanation:')) {
            explanation = line.substring(line.indexOf(':') + 1).trim();
          } else if (front == null && back == null && line.contains('\t')) {
            // Tab-separated format
            final parts = line.split('\t');
            if (parts.length >= 2) {
              front = parts[0].trim();
              back = parts[1].trim();
            }
          } else if (front == null) {
            front = line;
          } else if (back == null) {
            back = line;
          } else
            explanation ??= line;
        }

        // If we found front and back, create the flashcard
        if (front != null &&
            front.isNotEmpty &&
            back != null &&
            back.isNotEmpty) {
          flashcards.add(
            Flashcard(
              id: flashcardId++,
              front: front,
              back: back,
              explanation: explanation != null && explanation.isNotEmpty
                  ? explanation
                  : null,
            ),
          );
        }
      } on Exception {
        // Skip malformed flashcards
        continue;
      }
    }

    if (flashcards.isEmpty) {
      throw const FormatException(
        'Could not parse flashcards from text. '
        'Please ensure the text is in JSON format or a supported text format.',
      );
    }

    return flashcards;
  }
}
