import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/services/course_service.dart';
import 'package:testmaker/services/flashcard_generator_service.dart';
import 'package:testmaker/services/flashcard_service.dart';
import 'package:testmaker/services/pdf_text_extractor.dart';
import 'package:testmaker/services/question_generator_service.dart';
import 'package:testmaker/services/quiz_service.dart';

/// Controller for HomeScreen following MVC architecture.
///
/// Handles all business logic for course management, file uploads,
/// and AI content generation. The view (HomeScreen) should only
/// display data and forward user actions to this controller.
class HomeController extends ChangeNotifier {
  final QuizService _quizService = const QuizService();
  final FlashcardService _flashcardService = const FlashcardService();
  final CourseService _courseService = CourseService();
  final PdfTextExtractor _pdfTextExtractor = const PdfTextExtractor();

  List<Course> _courses = <Course>[];
  Course? _selectedCourse;
  bool _isLoadingCourses = true;
  final bool _isLoading = false;
  bool _isCustomLoading = false;
  bool _isFlashcardLoading = false;
  bool _isPdfLoading = false;
  bool _isGeneratingQuestions = false;
  bool _isGeneratingFlashcards = false;
  String? _error;
  bool _isFabExpanded = false;

  // Getters
  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoadingCourses => _isLoadingCourses;
  bool get isLoading => _isLoading;
  bool get isCustomLoading => _isCustomLoading;
  bool get isFlashcardLoading => _isFlashcardLoading;
  bool get isPdfLoading => _isPdfLoading;
  bool get isGeneratingQuestions => _isGeneratingQuestions;
  bool get isGeneratingFlashcards => _isGeneratingFlashcards;
  String? get error => _error;
  bool get isFabExpanded => _isFabExpanded;

  /// Initializes the controller by loading courses and API key.
  Future<void> initialize() async {
    await Future.wait([
      _loadCourses(),
      _loadApiKey(),
    ]);
  }

  /// Loads the API key from local storage.
  Future<void> _loadApiKey() async {
    await QuestionGeneratorService.getApiKey();
  }

  /// Loads all courses from local storage.
  Future<void> _loadCourses() async {
    _isLoadingCourses = true;
    _error = null;
    notifyListeners();

    try {
      final courses = await _courseService.getAllCourses();
      Course? updatedSelectedCourse;
      if (_selectedCourse != null) {
        try {
          updatedSelectedCourse = courses.firstWhere(
            (Course c) => c.id == _selectedCourse!.id,
          );
        } on Exception catch (_) {
          updatedSelectedCourse = null;
        }
      }

      _courses = courses;
      _selectedCourse = updatedSelectedCourse;
      _isLoadingCourses = false;
      notifyListeners();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController._loadCourses] Failed to load courses: $e');
      }
      _isLoadingCourses = false;
      _error = 'Failed to load courses';
      notifyListeners();
    }
  }

  /// Reloads courses from storage.
  Future<void> reloadCourses() async {
    await _loadCourses();
  }

  /// Creates a new course with the given name.
  Future<bool> createCourse(String name) async {
    if (name.trim().isEmpty) {
      return false;
    }

    try {
      final newCourse = await _courseService.createCourse(name.trim());
      await _loadCourses();

      if (_courses.isNotEmpty) {
        try {
          final createdCourse = _courses.firstWhere(
            (Course c) => c.id == newCourse.id,
          );
          selectCourse(createdCourse);
        } on Exception catch (_) {
          // Course not found, ignore
        }
      }

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.createCourse] Failed: $e');
      }
      _error = 'Failed to create course';
      notifyListeners();
      return false;
    }
  }

  /// Selects a course.
  void selectCourse(Course? course) {
    _selectedCourse = course;
    _error = null;
    notifyListeners();
  }

  /// Deletes a course.
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _courseService.deleteCourse(courseId);
      if (_selectedCourse?.id == courseId) {
        _selectedCourse = null;
      }
      await _loadCourses();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.deleteCourse] Failed: $e');
      }
      _error = 'Failed to delete course';
      notifyListeners();
      return false;
    }
  }

  /// Uploads a quiz JSON file to the selected course.
  Future<bool> uploadQuizToCourse() async {
    if (_selectedCourse == null) {
      return false;
    }

    _isCustomLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );

      if (result == null || result.files.isEmpty) {
        _isCustomLoading = false;
        notifyListeners();
        return false;
      }

      final file = result.files.first;
      final filePath = file.path;

      if (filePath == null) {
        _isCustomLoading = false;
        _error = 'Selected file path could not be read.';
        notifyListeners();
        return false;
      }

      final questions = await _quizService.loadQuestionsFromFile(filePath);
      await _courseService.addQuizToCourse(_selectedCourse!.id, questions);
      await _loadCourses();

      _isCustomLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.uploadQuizToCourse] Failed: $e');
      }
      _isCustomLoading = false;
      _error = 'Unable to read that quiz file. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Uploads a flashcard JSON file to the selected course.
  Future<bool> uploadFlashcardsToCourse() async {
    if (_selectedCourse == null) {
      return false;
    }

    _isFlashcardLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );

      if (result == null || result.files.isEmpty) {
        _isFlashcardLoading = false;
        notifyListeners();
        return false;
      }

      final file = result.files.first;
      final filePath = file.path;

      if (filePath == null) {
        _isFlashcardLoading = false;
        _error = 'Selected file path could not be read.';
        notifyListeners();
        return false;
      }

      final flashcards =
          await _flashcardService.loadFlashcardsFromFile(filePath);
      await _courseService.addFlashcardSetToCourse(
        _selectedCourse!.id,
        flashcards,
      );
      await _loadCourses();

      _isFlashcardLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.uploadFlashcardsToCourse] Failed: $e');
      }
      _isFlashcardLoading = false;
      _error = 'Unable to read that flashcard file. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Uploads a PDF file to the selected course.
  Future<bool> uploadPdfToCourse() async {
    if (_selectedCourse == null) {
      return false;
    }

    _isPdfLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        _isPdfLoading = false;
        notifyListeners();
        return false;
      }

      final file = result.files.first;
      final filePath = file.path;

      if (filePath == null) {
        _isPdfLoading = false;
        _error = 'Selected file path could not be read.';
        notifyListeners();
        return false;
      }

      await _courseService.addPdfToCourse(_selectedCourse!.id, filePath);
      await _loadCourses();

      _isPdfLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.uploadPdfToCourse] Failed: $e');
      }
      _isPdfLoading = false;
      _error = 'Unable to read that PDF file. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Generates quiz questions from a PDF using AI.
  Future<bool> generateQuestionsFromPdf(
    String pdfPath,
    int questionCount,
  ) async {
    if (_selectedCourse == null) {
      return false;
    }

    _isGeneratingQuestions = true;
    _error = null;
    notifyListeners();

    try {
      final text = await _pdfTextExtractor.extractText(pdfPath);
      final generator = QuestionGeneratorService(questionCount: questionCount);
      final questions = await generator.generateQuestionsFromText(text);
      await _courseService.addQuizToCourse(_selectedCourse!.id, questions);
      await _loadCourses();

      _isGeneratingQuestions = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.generateQuestionsFromPdf] Failed: $e');
      }
      _isGeneratingQuestions = false;
      _error = 'Failed to generate questions: $e';
      notifyListeners();
      return false;
    }
  }

  /// Generates flashcards from a PDF using AI.
  Future<bool> generateFlashcardsFromPdf(
    String pdfPath,
    int flashcardCount,
  ) async {
    if (_selectedCourse == null) {
      return false;
    }

    _isGeneratingFlashcards = true;
    _error = null;
    notifyListeners();

    try {
      final text = await _pdfTextExtractor.extractText(pdfPath);
      const generator = FlashcardGeneratorService();
      final flashcards = await generator.generateFlashcardsFromText(
        text,
        flashcardCount: flashcardCount,
      );
      await _courseService.addFlashcardSetToCourse(
        _selectedCourse!.id,
        flashcards,
      );
      await _loadCourses();

      _isGeneratingFlashcards = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.generateFlashcardsFromPdf] Failed: $e');
      }
      _isGeneratingFlashcards = false;
      _error = 'Failed to generate flashcards: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a quiz from the selected course.
  Future<bool> deleteQuizFromCourse(int quizIndex) async {
    if (_selectedCourse == null) {
      return false;
    }

    try {
      await _courseService.deleteQuizFromCourse(
        _selectedCourse!.id,
        quizIndex,
      );
      await _loadCourses();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.deleteQuizFromCourse] Failed: $e');
      }
      _error = 'Failed to delete quiz';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a flashcard set from the selected course.
  Future<bool> deleteFlashcardSetFromCourse(int flashcardSetIndex) async {
    if (_selectedCourse == null) {
      return false;
    }

    try {
      await _courseService.deleteFlashcardSetFromCourse(
        _selectedCourse!.id,
        flashcardSetIndex,
      );
      await _loadCourses();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.deleteFlashcardSetFromCourse] Failed: $e');
      }
      _error = 'Failed to delete flashcard set';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a PDF from the selected course.
  Future<bool> deletePdfFromCourse(int pdfIndex) async {
    if (_selectedCourse == null) {
      return false;
    }

    if (pdfIndex < 0 || pdfIndex >= _selectedCourse!.pdfs.length) {
      return false;
    }

    try {
      final pdfPath = _selectedCourse!.pdfs[pdfIndex];
      await _courseService.deletePdfFromCourse(_selectedCourse!.id, pdfPath);
      await _loadCourses();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.deletePdfFromCourse] Failed: $e');
      }
      _error = 'Failed to delete PDF';
      notifyListeners();
      return false;
    }
  }

  /// Toggles the FAB expanded state.
  void toggleFab() {
    _isFabExpanded = !_isFabExpanded;
    notifyListeners();
  }

  /// Closes the FAB.
  void closeFab() {
    _isFabExpanded = false;
    notifyListeners();
  }

  /// Clears the error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
