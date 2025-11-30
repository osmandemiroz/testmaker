// ignore_for_file: unnecessary_getters_setters, document_ignores

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testmaker/models/question.dart';

/// ********************************************************************
/// QuestionGeneratorService
/// ********************************************************************
///
/// Service for generating quiz questions from text content using Google's
/// Generative AI (Gemini) API.
///
/// This service takes text content (e.g., from PDFs) and generates
/// multiple-choice questions that can be used for quizzes.
///
/// Note: You need to set your Google AI API key. You can get one from:
/// https://makersuite.google.com/app/apikey
///
class QuestionGeneratorService {
  /// Creates a new [QuestionGeneratorService].
  ///
  /// [questionCount] specifies how many questions to generate (default: 5).
  const QuestionGeneratorService({
    this.questionCount = 5,
  });

  /// Key used in SharedPreferences to store the API key.
  static const String _apiKeyPrefsKey = 'testmaker_gemini_api_key';

  /// Google Generative AI API key (cached in memory).
  ///
  /// IMPORTANT: The API key is stored in SharedPreferences for persistence.
  static String? _apiKey;

  /// Number of questions to generate per request.
  final int questionCount;

  /// Initializes SharedPreferences and loads the API key.
  static Future<void> _ensureInitialized() async {
    if (_apiKey == null) {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString(_apiKeyPrefsKey);
    }
  }

  /// Sets the Google AI API key and saves it to local storage.
  ///
  /// This should be set before using the service.
  /// You can get an API key from: https://makersuite.google.com/app/apikey
  static Future<void> setApiKey(String? key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    if (key != null && key.isNotEmpty) {
      await prefs.setString(_apiKeyPrefsKey, key);
    } else {
      await prefs.remove(_apiKeyPrefsKey);
    }
  }

  /// Gets the current API key (loads from storage if not in memory).
  static Future<String?> getApiKey() async {
    await _ensureInitialized();
    return _apiKey;
  }

  /// Checks if an API key is set.
  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Lists available models from the Gemini API.
  ///
  /// This helps determine which models are available for the current API key.
  Future<List<String>> listAvailableModels() async {
    await _ensureInitialized();
    if (_apiKey == null || _apiKey!.isEmpty) {
      return <String>[];
    }

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = data['models'] as List<dynamic>? ?? <dynamic>[];

        return models
            .map<String>(
              (dynamic model) =>
                  (model as Map<String, dynamic>)['name'] as String? ?? '',
            )
            .where((String name) => name.isNotEmpty)
            .toList();
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[QuestionGeneratorService.listAvailableModels] Error: $e');
      }
    }

    return <String>[];
  }

  /// Generates quiz questions from the given text content.
  ///
  /// The text should be study material content (e.g., extracted from a PDF).
  /// The service uses Google's Gemini AI to generate multiple-choice questions.
  ///
  /// [questionCount] specifies how many questions to generate (overrides the
  /// default questionCount if provided).
  ///
  /// Returns a list of [Question] objects that can be added to a course.
  ///
  /// Throws an exception if:
  /// - API key is not set
  /// - API request fails
  /// - Generated content cannot be parsed
  Future<List<Question>> generateQuestionsFromText(
    String text, {
    int? questionCount,
  }) async {
    await _ensureInitialized();
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception(
        'Google AI API key not set. Please set it using QuestionGeneratorService.setApiKey()',
      );
    }

    final count = questionCount ?? this.questionCount;

    if (text.trim().isEmpty) {
      throw Exception('Text content is empty');
    }

    try {
      final prompt = _buildPrompt(text, count);

      // First, try to get available models to use the correct one
      final availableModels = await listAvailableModels();

      // Build model configs, prioritizing available models
      final modelConfigs = <Map<String, String>>[];

      // Add available models first (if we got them)
      if (availableModels.isNotEmpty) {
        for (final modelName in availableModels) {
          // Extract model name from full path (e.g., "models/gemini-1.5-flash" -> "gemini-1.5-flash")
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
            'https://generativelanguage.googleapis.com/${config['version']}/models/${config['model']}:generateContent?key=$_apiKey',
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

      return _parseQuestionsFromResponse(generatedText);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to generate questions: $e');
    }
  }

  /// Builds the prompt for the AI model.
  String _buildPrompt(String text, int count) {
    return '''
You are an expert quiz generator. Generate exactly $count multiple-choice questions based on the following study material.

Study Material:
$text

Generate questions in the following JSON format (array of question objects):
[
  {
    "id": 1,
    "text": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "answerIndex": 0,
    "explanation": "Brief explanation of why the correct answer is correct, referencing the study material."
  },
  ...
]

Requirements:
- Generate exactly $count questions
- Each question must have exactly 4 options
- answerIndex must be 0, 1, 2, or 3 (pointing to the correct option)
- Each question MUST include an "explanation" field that explains why the correct answer is correct, referencing specific concepts from the study material
- Questions should test understanding of key concepts from the material
- Make questions clear and unambiguous
- Ensure only one correct answer per question
- Explanations should be concise (1-2 sentences) and help students understand the concept
- Return ONLY valid JSON, no additional text or explanation

Return the JSON array now:
''';
  }

  /// Parses the AI response and converts it to a list of [Question] objects.
  List<Question> _parseQuestionsFromResponse(String response) {
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

      final questions = decoded
          .map<Question>(
            (dynamic item) => Question.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      if (questions.isEmpty) {
        throw Exception('No questions were generated');
      }

      return questions;
    } catch (e) {
      throw Exception('Could not parse AI response: $e');
    }
  }
}
