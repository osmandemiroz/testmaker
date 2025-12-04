import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';

/// ********************************************************************
/// CourseService
/// ********************************************************************
///
/// Service responsible for managing courses and their quizzes using
/// SharedPreferences for local storage.
///
/// This service provides CRUD operations for courses:
///  - Create new courses
///  - Read/list all courses
///  - Update existing courses (add quizzes, rename, etc.)
///  - Delete courses
///
/// All data is persisted locally using SharedPreferences, so courses
/// persist across app restarts.
///
class CourseService {
  /// Key used in SharedPreferences to store the list of courses.
  static const String _coursesKey = 'testmaker_courses';

  /// SharedPreferences instance (lazy-loaded).
  SharedPreferences? _prefs;

  /// Initializes SharedPreferences if not already initialized.
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Loads all courses from local storage.
  ///
  /// Returns an empty list if no courses are stored or if there's an error.
  Future<List<Course>> getAllCourses() async {
    try {
      await _ensureInitialized();
      final prefs = _prefs!;

      final coursesJson = prefs.getString(_coursesKey);
      if (coursesJson == null || coursesJson.isEmpty) {
        return <Course>[];
      }

      final decoded = jsonDecode(coursesJson) as List<dynamic>;
      return decoded
          .map<Course>(
            (dynamic item) => Course.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(); // Make it growable so we can add/remove courses
    } on Exception catch (_) {
      // If there's any error parsing, return an empty list.
      // In a production app, you might want to log this error.
      return <Course>[];
    }
  }

  /// Creates a new course with the given name.
  ///
  /// The course will have empty quizzes and PDFs lists initially.
  /// Returns the newly created [Course] with a generated ID.
  Future<Course> createCourse(String name) async {
    await _ensureInitialized();

    final now = DateTime.now().millisecondsSinceEpoch;
    final course = Course(
      id: 'course_${now}_${name.hashCode}',
      name: name,
      quizzes: <List<Question>>[],
      flashcards: <List<Flashcard>>[],
      pdfs: <String>[],
      createdAt: now,
      updatedAt: now,
    );

    final courses = await getAllCourses();
    courses.add(course);
    await _saveCourses(courses);

    return course;
  }

  /// Updates an existing course.
  ///
  /// Replaces the course with the same ID in storage.
  Future<void> updateCourse(Course course) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == course.id);

    if (index == -1) {
      // Course not found; add it as a new course.
      courses.add(course);
    } else {
      // Update the existing course with new updatedAt timestamp.
      courses[index] = course.copyWith(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

    await _saveCourses(courses);
  }

  /// Adds a quiz (list of questions) to a course.
  ///
  /// The quiz is appended to the course's quizzes list.
  Future<void> addQuizToCourse(String courseId, List<Question> quiz) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    final course = courses[index];
    final updatedQuizzes = <List<Question>>[...course.quizzes, quiz];

    courses[index] = course.copyWith(
      quizzes: updatedQuizzes,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveCourses(courses);
  }

  /// Adds a PDF file to a course.
  ///
  /// The PDF file is copied to the app's documents directory and its path
  /// is stored in the course's PDFs list.
  ///
  /// [sourcePath] is the path to the PDF file selected by the user.
  /// Returns the local path where the PDF was saved.
  Future<String> addPdfToCourse(String courseId, String sourcePath) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    // Get app documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final courseDir = Directory('${appDocDir.path}/courses/$courseId');

    // Create course directory if it doesn't exist
    if (!await courseDir.exists()) {
      await courseDir.create(recursive: true);
    }

    // Generate unique filename
    final sourceFile = File(sourcePath);
    final fileName = sourceFile.uri.pathSegments.last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '${timestamp}_$fileName';
    final destinationPath = '${courseDir.path}/$uniqueFileName';

    // Copy file to app documents directory
    final destinationFile = await sourceFile.copy(destinationPath);

    // Update course with new PDF path
    final course = courses[index];
    final updatedPdfs = <String>[...course.pdfs, destinationFile.path];

    courses[index] = course.copyWith(
      pdfs: updatedPdfs,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveCourses(courses);

    return destinationFile.path;
  }

  /// Deletes a PDF file from a course.
  ///
  /// Removes the PDF from the course's list and deletes the file from storage.
  Future<void> deletePdfFromCourse(String courseId, String pdfPath) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    // Delete the file
    final file = File(pdfPath);
    if (await file.exists()) {
      await file.delete();
    }

    // Update course
    final course = courses[index];
    final updatedPdfs =
        course.pdfs.where((String path) => path != pdfPath).toList();

    courses[index] = course.copyWith(
      pdfs: updatedPdfs,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveCourses(courses);
  }

  /// Deletes a quiz from a course by its index.
  ///
  /// Removes the quiz at the specified index from the course's quizzes list.
  Future<void> deleteQuizFromCourse(String courseId, int quizIndex) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    final course = courses[index];
    if (quizIndex < 0 || quizIndex >= course.quizzes.length) {
      throw Exception('Quiz index out of bounds');
    }

    // Remove quiz at the specified index
    final updatedQuizzes = <List<Question>>[
      ...course.quizzes.sublist(0, quizIndex),
      ...course.quizzes.sublist(quizIndex + 1),
    ];

    courses[index] = course.copyWith(
      quizzes: updatedQuizzes,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveCourses(courses);
  }

  /// Adds a flashcard set (list of flashcards) to a course.
  ///
  /// The flashcard set is appended to the course's flashcards list.
  Future<void> addFlashcardSetToCourse(
    String courseId,
    List<Flashcard> flashcardSet,
  ) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    final course = courses[index];
    final updatedFlashcards = <List<Flashcard>>[
      ...course.flashcards,
      flashcardSet,
    ];

    courses[index] = course.copyWith(
      flashcards: updatedFlashcards,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveCourses(courses);
  }

  /// Deletes a flashcard set from a course by its index.
  ///
  /// Removes the flashcard set at the specified index from the course's flashcards list.
  Future<void> deleteFlashcardSetFromCourse(
    String courseId,
    int flashcardSetIndex,
  ) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    final course = courses[index];
    if (flashcardSetIndex < 0 ||
        flashcardSetIndex >= course.flashcards.length) {
      throw Exception('Flashcard set index out of bounds');
    }

    // Remove flashcard set at the specified index
    final updatedFlashcards = <List<Flashcard>>[
      ...course.flashcards.sublist(0, flashcardSetIndex),
      ...course.flashcards.sublist(flashcardSetIndex + 1),
    ];

    courses[index] = course.copyWith(
      flashcards: updatedFlashcards,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveCourses(courses);
  }

  /// Reorders PDFs in a course.
  ///
  /// Moves the PDF at [oldIndex] to [newIndex] in the course's PDFs list.
  /// Also updates the pdfNames map to match the new order.
  Future<void> reorderPdfsInCourse(
    String courseId,
    int oldIndex,
    int newIndex,
  ) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    final course = courses[index];
    if (oldIndex < 0 ||
        oldIndex >= course.pdfs.length ||
        newIndex < 0 ||
        newIndex >= course.pdfs.length) {
      throw Exception('PDF index out of bounds');
    }

    // Reorder PDFs (newIndex is already adjusted by the UI)
    final updatedPdfs = <String>[...course.pdfs];
    final item = updatedPdfs.removeAt(oldIndex);
    updatedPdfs.insert(newIndex, item);

    // Reorder pdfNames map to match the new indices
    // Build mapping by simulating the reorder on the indices themselves
    Map<int, String>? updatedPdfNames;
    if (course.pdfNames != null && course.pdfNames!.isNotEmpty) {
      updatedPdfNames = <int, String>{};
      // Create a list of old indices and reorder them the same way
      final oldIndices = List<int>.generate(
        course.pdfs.length,
        (int i) => i,
      );
      final movedIndex = oldIndices.removeAt(oldIndex);
      oldIndices.insert(newIndex, movedIndex);

      // Now map new index to old index and copy the name
      for (var newIdx = 0; newIdx < updatedPdfs.length; newIdx++) {
        final oldIdx = oldIndices[newIdx];
        if (course.pdfNames!.containsKey(oldIdx)) {
          updatedPdfNames[newIdx] = course.pdfNames![oldIdx]!;
        }
      }
    }

    courses[index] = course.copyWith(
      pdfs: updatedPdfs,
      pdfNames: updatedPdfNames,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveCourses(courses);
  }

  /// Reorders quizzes in a course.
  ///
  /// Moves the quiz at [oldIndex] to [newIndex] in the course's quizzes list.
  /// Also updates the quizNames map to match the new order.
  Future<void> reorderQuizzesInCourse(
    String courseId,
    int oldIndex,
    int newIndex,
  ) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    final course = courses[index];
    if (oldIndex < 0 ||
        oldIndex >= course.quizzes.length ||
        newIndex < 0 ||
        newIndex >= course.quizzes.length) {
      throw Exception('Quiz index out of bounds');
    }

    // Reorder quizzes (newIndex is already adjusted by the UI)
    final updatedQuizzes = <List<Question>>[...course.quizzes];
    final item = updatedQuizzes.removeAt(oldIndex);
    updatedQuizzes.insert(newIndex, item);

    // Reorder quizNames map to match the new quiz order
    // Build a mapping: for each new index, determine which old index it came from
    // IMPORTANT: We preserve ALL names (both custom and default) so they move with items
    final updatedQuizNames = <int, String>{};

    // Create a list representing the original indices
    final originalIndices = List<int>.generate(
      course.quizzes.length,
      (int i) => i,
    );

    // Simulate the reorder on the indices list
    final movedIndex = originalIndices.removeAt(oldIndex);
    originalIndices.insert(newIndex, movedIndex);

    // Now map each new index to the name from its corresponding old index
    // This preserves both custom names and default names
    for (var newIdx = 0; newIdx < updatedQuizzes.length; newIdx++) {
      final oldIdx = originalIndices[newIdx];
      // Get the name (either custom or default) from the old index
      final name = course.getQuizName(oldIdx);
      updatedQuizNames[newIdx] = name;
    }

    courses[index] = course.copyWith(
      quizzes: updatedQuizzes,
      quizNames: updatedQuizNames,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Persist the reordered quizzes and names to local storage
    // This ensures the order is maintained when the app is reopened
    await _saveCourses(courses);
  }

  /// Reorders flashcard sets in a course.
  ///
  /// Moves the flashcard set at [oldIndex] to [newIndex] in the course's flashcards list.
  /// Also updates the flashcardSetNames map to match the new order.
  Future<void> reorderFlashcardSetsInCourse(
    String courseId,
    int oldIndex,
    int newIndex,
  ) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    final index = courses.indexWhere((Course c) => c.id == courseId);

    if (index == -1) {
      throw Exception('Course with id $courseId not found');
    }

    final course = courses[index];
    if (oldIndex < 0 ||
        oldIndex >= course.flashcards.length ||
        newIndex < 0 ||
        newIndex >= course.flashcards.length) {
      throw Exception('Flashcard set index out of bounds');
    }

    // Reorder flashcard sets (newIndex is already adjusted by the UI)
    final updatedFlashcards = <List<Flashcard>>[...course.flashcards];
    final item = updatedFlashcards.removeAt(oldIndex);
    updatedFlashcards.insert(newIndex, item);

    // Reorder flashcardSetNames map to match the new flashcard set order
    // Build a mapping: for each new index, determine which old index it came from
    // IMPORTANT: We preserve ALL names (both custom and default) so they move with items
    final updatedFlashcardSetNames = <int, String>{};

    // Create a list representing the original indices
    final originalIndices = List<int>.generate(
      course.flashcards.length,
      (int i) => i,
    );

    // Simulate the reorder on the indices list
    final movedIndex = originalIndices.removeAt(oldIndex);
    originalIndices.insert(newIndex, movedIndex);

    // Now map each new index to the name from its corresponding old index
    // This preserves both custom names and default names
    for (var newIdx = 0; newIdx < updatedFlashcards.length; newIdx++) {
      final oldIdx = originalIndices[newIdx];
      // Get the name (either custom or default) from the old index
      final name = course.getFlashcardSetName(oldIdx);
      updatedFlashcardSetNames[newIdx] = name;
    }

    courses[index] = course.copyWith(
      flashcards: updatedFlashcards,
      flashcardSetNames: updatedFlashcardSetNames,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Persist the reordered flashcard sets and names to local storage
    // This ensures the order is maintained when the app is reopened
    await _saveCourses(courses);
  }

  /// Deletes a course by its ID.
  Future<void> deleteCourse(String courseId) async {
    await _ensureInitialized();

    final courses = await getAllCourses();
    courses.removeWhere((Course c) => c.id == courseId);

    await _saveCourses(courses);
  }

  /// Saves the list of courses to SharedPreferences.
  ///
  /// This is an internal method used by other methods in this service.
  Future<void> _saveCourses(List<Course> courses) async {
    await _ensureInitialized();

    final coursesJson = jsonEncode(
      courses.map<Map<String, dynamic>>((Course c) => c.toJson()).toList(),
    );

    await _prefs!.setString(_coursesKey, coursesJson);
  }
}
