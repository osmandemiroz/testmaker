/// Utility class for generating AI prompts for quizzes and flashcards.
// ignore_for_file: leading_newlines_in_multiline_strings, dangling_library_doc_comments

/// ********************************************************************
/// PromptGenerator
/// ********************************************************************
///
/// Utility class for generating AI prompts for quizzes and flashcards.
///
class PromptGenerator {
  /// Generates a quiz prompt for AI agents based on type and count.
  static String generateQuizPrompt(String type, int count) {
    final typeInstructions = <String, String>{
      'Multiple Choice':
          'Each question should have 4 answer options with one correct answer.',
      'True/False':
          'Each question should have exactly 2 options: "True" and "False".',
      'Fill in the Blank':
          'Each question should have 4 answer options where one is the correct fill-in answer.',
      'Short Answer':
          'Each question should have 4 answer options with one correct short answer.',
    };

    return '''Generate $count ${type.toLowerCase()} quiz questions for a mobile quiz application.

Requirements:
- Generate exactly $count questions
- ${typeInstructions[type] ?? 'Each question should have 4 answer options with one correct answer.'}
- Each question must include an explanation field

Format (array of question objects):
[
  {
    "id": 1,
    "text": "The question text here",
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
    "answerIndex": 0,
    "explanation": "Explanation of why the correct answer is correct"
  },
  ...
]

Field Requirements:
- "id": Sequential number starting from 1
- "text": Clear, concise question text
- "options": Array of exactly 4 strings (or 2 for True/False)
- "answerIndex": Zero-based index (0-3, or 0-1 for True/False) pointing to the correct option
- "explanation": Brief explanation of the correct answer

Return ONLY valid JSON array, no additional text or markdown formatting.''';
  }

  /// Generates a flashcard prompt for AI agents based on type and count.
  static String generateFlashcardPrompt(String type, int count) {
    final typeInstructions = <String, String>{
      'Q&A':
          'Create question and answer pairs where the front is a question and the back is the answer.',
      'Definition':
          'Create definition cards where the front is a term and the back is its definition.',
      'Concept Explanation':
          'Create concept cards where the front is a concept name and the back explains the concept.',
      'Term & Definition':
          'Create term-definition pairs where the front is a term and the back is its definition.',
    };

    return '''Generate $count ${type.toLowerCase()} flashcards for a mobile flashcard application.

Requirements:
- Generate exactly $count flashcards
- ${typeInstructions[type] ?? 'Create question and answer pairs.'}
- Each flashcard should include an explanation field for additional context

Format (array of flashcard objects):
[
  {
    "id": 1,
    "front": "The question, term, or concept on the front of the card",
    "back": "The answer, definition, or explanation on the back of the card",
    "explanation": "Additional context or explanation that helps understand the concept better"
  },
  ...
]

Field Requirements:
- "id": Sequential number starting from 1
- "front": Clear, concise question, term, or concept
- "back": Clear, concise answer, definition, or explanation
- "explanation": Optional additional context that helps understand the concept

Return ONLY valid array format, no additional text or markdown formatting.''';
  }
}
