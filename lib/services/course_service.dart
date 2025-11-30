import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:testmaker/models/course.dart';
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
