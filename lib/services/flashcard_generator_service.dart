// ignore_for_file: unnecessary_getters_setters, document_ignores

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/services/question_generator_service.dart';

/// ********************************************************************
/// FlashcardGeneratorService
/// ********************************************************************
///
/// Service for generating flashcards from text content using Google's
/// Generative AI (Gemini) API.
///
/// This service takes text content (e.g., from PDFs) and generates
/// flashcards with front (question) and back (answer) sides.
///
/// Note: Uses the same API key as QuestionGeneratorService.
///
class FlashcardGeneratorService {
  /// Creates a new [FlashcardGeneratorService].
  ///
  /// [flashcardCount] specifies how many flashcards to generate (default: 10).
  const FlashcardGeneratorService({
    this.flashcardCount = 10,
  });

  /// Number of flashcards to generate per request.
  final int flashcardCount;

  /// Sets the Google AI API key (delegates to QuestionGeneratorService).
  static Future<void> setApiKey(String? key) async {
    await QuestionGeneratorService.setApiKey(key);
  }

  /// Gets the current API key (delegates to QuestionGeneratorService).
  static Future<String?> getApiKey() async {
    return QuestionGeneratorService.getApiKey();
  }

  /// Checks if an API key is set (delegates to QuestionGeneratorService).
  static Future<bool> hasApiKey() async {
    return QuestionGeneratorService.hasApiKey();
  }

  /// Generates flashcards from the given text content.
  ///
  /// The text should be study material content (e.g., extracted from a PDF).
  /// The service uses Google's Gemini AI to generate flashcards.
  ///
  /// [flashcardCount] specifies how many flashcards to generate (overrides the
  /// default flashcardCount if provided).
  ///
  /// Returns a list of [Flashcard] objects that can be added to a course.
  ///
  /// Throws an exception if:
  /// - API key is not set
  /// - API request fails
  /// - Generated content cannot be parsed
  Future<List<Flashcard>> generateFlashcardsFromText(
    String text, {
    int? flashcardCount,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Google AI API key not set. Please set it using FlashcardGeneratorService.setApiKey()',
      );
    }

    final count = flashcardCount ?? this.flashcardCount;

    if (text.trim().isEmpty) {
      throw Exception('Text content is empty');
    }

    try {
      final prompt = _buildPrompt(text, count);

      // Use the same model discovery logic as QuestionGeneratorService
      const questionService = QuestionGeneratorService();
      final availableModels = await questionService.listAvailableModels();

      // Build model configs, prioritizing available models
      final modelConfigs = <Map<String, String>>[];

      // Add available models first (if we got them)
      if (availableModels.isNotEmpty) {
        for (final modelName in availableModels) {
          // Extract model name from full path
          final shortName = modelName.replaceAll('models/', '');
          if (shortName.contains('flash') || shortName.contains('pro')) {
            modelConfigs.add(<String, String>{
              'version': 'v1beta',
              'model': shortName,
            });
          }
        }
      }

      // Add fallback models if we didn't get available models or need more options
      if (modelConfigs.isEmpty) {
        modelConfigs.addAll(<Map<String, String>>[
          <String, String>{
            'version': 'v1beta',
            'model': 'gemini-1.5-flash',
          },
          <String, String>{
            'version': 'v1beta',
            'model': 'gemini-1.5-pro',
          },
          <String, String>{
            'version': 'v1beta',
            'model': 'gemini-1.0-pro',
          },
        ]);
      }

      http.Response? lastResponse;
      String? lastError;

      for (final config in modelConfigs) {
        try {
          final url = Uri.parse(
            'https://generativelanguage.googleapis.com/${config['version']}/models/${config['model']}:generateContent?key=$apiKey',
          );

          final response = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'contents': <Map<String, dynamic>>[
                <String, dynamic>{
                  'parts': <Map<String, dynamic>>[
                    <String, dynamic>{'text': prompt},
                  ],
                }
              ],
            }),
          );

          if (response.statusCode == 200) {
            lastResponse = response;
            break; // Success, exit loop
          } else {
            // Try to parse error for logging
            try {
              final errorData =
                  jsonDecode(response.body) as Map<String, dynamic>;
              if (errorData['error'] != null) {
                final error = errorData['error'] as Map<String, dynamic>;
                lastError = error['message'] as String?;
              }
            } on Exception catch (_) {
              // Ignore parse errors
              lastError = 'Failed to parse error';
            }
            lastResponse = response;
          }
        } on Exception catch (e) {
          lastError = e.toString();
          continue; // Try next model
        }
      }

      if (lastResponse == null || lastResponse.statusCode != 200) {
        // All models failed, throw error with last error message
        var errorMessage = 'API request failed. ';
        if (lastError != null) {
          errorMessage += lastError;
        } else if (lastResponse != null) {
          errorMessage += 'Status: ${lastResponse.statusCode}';
        } else {
          errorMessage += 'Could not connect to API.';
        }
        throw Exception(errorMessage);
      }

      final responseData =
          jsonDecode(lastResponse.body) as Map<String, dynamic>;

      if (responseData['candidates'] == null ||
          (responseData['candidates'] as List).isEmpty) {
        throw Exception('No response from AI model');
      }

      final candidates = responseData['candidates'] as List<dynamic>?;
      final firstCandidate = candidates?[0] as Map<String, dynamic>?;
      final content = firstCandidate?['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final firstPart = parts?[0] as Map<String, dynamic>?;
      final generatedText = firstPart?['text'] as String?;

      if (generatedText == null || generatedText.isEmpty) {
        throw Exception('No text in AI response');
      }

      return _parseFlashcardsFromResponse(generatedText);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }

  /// Builds the prompt for the AI model.
  String _buildPrompt(String text, int count) {
    return '''
You are an expert flashcard generator. Generate exactly $count flashcards based on the following study material.

Study Material:
$text

Generate flashcards in the following JSON format (array of flashcard objects):
[
  {
    "id": 1,
    "front": "Question or prompt on the front of the card",
    "back": "Answer or explanation on the back of the card",
    "explanation": "Optional additional context or explanation that helps understand the concept better"
  },
  ...
]

Requirements:
- Generate exactly $count flashcards
- Each flashcard must have a "front" (question/prompt) and "back" (answer)
- The "front" should be a clear question or prompt that tests understanding
- The "back" should be a concise answer
- Each flashcard SHOULD include an "explanation" field that provides additional context or helps understand why the answer is correct
- Flashcards should cover key concepts, definitions, facts, or relationships from the material
- Make flashcards clear and focused on one concept each
- Return ONLY valid JSON, no additional text or explanation

Return the JSON array now:
''';
  }

  /// Parses the AI response and converts it to a list of [Flashcard] objects.
  List<Flashcard> _parseFlashcardsFromResponse(String response) {
    try {
      // Try to extract JSON from the response (might have markdown code blocks)
      var jsonText = response.trim();

      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }

      jsonText = jsonText.trim();

      // Parse JSON
      final dynamic decoded = jsonDecode(jsonText);
      if (decoded is! List) {
        throw Exception('Response is not a JSON array');
      }

      final flashcards = decoded
          .map<Flashcard>(
            (dynamic item) => Flashcard.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      if (flashcards.isEmpty) {
        throw Exception('No flashcards were generated');
      }

      return flashcards;
    } catch (e) {
      throw Exception('Could not parse AI response: $e');
    }
  }
}
