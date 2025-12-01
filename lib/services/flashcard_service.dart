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
}
