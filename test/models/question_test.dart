// ignore_for_file: document_ignores

import 'package:flutter_test/flutter_test.dart';
import 'package:testmaker/models/question.dart';

void main() {
  group('Question', () {
    test('parses legacy JSON with single answerIndex', () {
      final json = {
        'id': 1,
        'text': 'What is 2 + 2?',
        'options': ['3', '4', '5'],
        'answerIndex': 1,
      };

      final question = Question.fromJson(json);
      expect(question.id, 1);
      expect(question.text, 'What is 2 + 2?');
      expect(question.options, ['3', '4', '5']);
      expect(question.answerIndices, [1]);
      // ignore: deprecated_member_use_from_same_package
      expect(question.answerIndex, 1);
      expect(question.isMultiSelect, false);
    });

    test('parses new JSON with answerIndices', () {
      final json = {
        'id': 2,
        'text': 'Select prime numbers',
        'options': ['2', '4', '5', '9'],
        'answerIndices': [0, 2],
      };

      final question = Question.fromJson(json);
      expect(question.id, 2);
      expect(question.answerIndices, [0, 2]);
      expect(question.isMultiSelect, true);
    });

    test('toJson includes answerIndices', () {
      final question = Question(
        id: 1,
        text: 'Test',
        options: ['A', 'B'],
        answerIndices: [0],
      );

      final json = question.toJson();
      expect(json['answerIndices'], [0]);
      expect(json.containsKey('answerIndex'), false);
    });

    test('shuffling options updates indices correctly', () {
      final question = Question(
        id: 3,
        text: 'Select vowels',
        options: ['A', 'B', 'E', 'Z'],
        answerIndices: [0, 2], // A and E
      );

      // Verify shuffling 10 times to account for randomness
      for (var i = 0; i < 10; i++) {
        final shuffled = question.withShuffledOptions();

        // Check contents are the same
        expect(shuffled.options, containsAll(question.options));

        // Verify answer logic remains correct
        // The options at the new answer indices should match the original correct answers
        final correctOptions = ['A', 'E'];
        final newCorrectOptions = shuffled.answerIndices
            .map((index) => shuffled.options[index])
            .toList();

        expect(newCorrectOptions, containsAll(correctOptions));
      }
    });
  });
}
