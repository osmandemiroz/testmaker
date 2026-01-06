import 'package:flutter_test/flutter_test.dart';
import 'package:testmaker/models/course.dart';

void main() {
  group('Course', () {
    test('parses JSON with quizSortingPreference', () {
      final json = {
        'id': 'course-1',
        'name': 'Math',
        'quizzes': <Map<String, dynamic>>[],
        'flashcards': <Map<String, dynamic>>[],
        'pdfs': <String>[],
        'createdAt': 123456,
        'updatedAt': 123456,
        'quizSortingPreference': 'sequential',
      };

      final course = Course.fromJson(json);
      expect(course.quizSortingPreference, QuizSortingPreference.sequential);
    });

    test('toJson includes quizSortingPreference', () {
      const course = Course(
        id: 'course-1',
        name: 'Math',
        quizzes: [],
        flashcards: [],
        pdfs: [],
        createdAt: 123456,
        updatedAt: 123456,
        quizSortingPreference: QuizSortingPreference.sequential,
      );

      final json = course.toJson();
      expect(json['quizSortingPreference'], 'sequential');
    });

    test('copyWith updates quizSortingPreference', () {
      const course = Course(
        id: 'course-1',
        name: 'Math',
        quizzes: [],
        flashcards: [],
        pdfs: [],
        createdAt: 123456,
        updatedAt: 123456,
      );

      final updated = course.copyWith(
        quizSortingPreference: QuizSortingPreference.sequential,
      );
      expect(updated.quizSortingPreference, QuizSortingPreference.sequential);
      expect(
        course.quizSortingPreference,
        QuizSortingPreference.random,
      ); // Default
    });
  });
}
