import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';
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

  /// Adds quiz questions from pasted text to the selected course.
  ///
  /// The text can be in JSON format (from AI agents) or simple text format.
  /// The app automatically converts it to the required format internally.
  Future<bool> addQuizFromText(String text) async {
    if (_selectedCourse == null) {
      return false;
    }

    _isCustomLoading = true;
    _error = null;
    notifyListeners();

    try {
      final questions = _quizService.parseQuestionsFromText(text);
      await _courseService.addQuizToCourse(_selectedCourse!.id, questions);
      await _loadCourses();

      _isCustomLoading = false;
      notifyListeners();
      return true;
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('[HomeController.addQuizFromText] Failed to parse: $e');
      }
      _isCustomLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.addQuizFromText] Failed: $e');
      }
      _isCustomLoading = false;
      _error =
          'Unable to process the quiz content. Please check the format and try again.';
      notifyListeners();
      return false;
    }
  }

  /// Adds flashcards from pasted text to the selected course.
  ///
  /// The text can be in JSON format (from AI agents) or simple text format.
  /// The app automatically converts it to the required format internally.
  Future<bool> addFlashcardsFromText(String text) async {
    if (_selectedCourse == null) {
      return false;
    }

    _isFlashcardLoading = true;
    _error = null;
    notifyListeners();

    try {
      final flashcards = _flashcardService.parseFlashcardsFromText(text);
      await _courseService.addFlashcardSetToCourse(
        _selectedCourse!.id,
        flashcards,
      );
      await _loadCourses();

      _isFlashcardLoading = false;
      notifyListeners();
      return true;
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('[HomeController.addFlashcardsFromText] Failed to parse: $e');
      }
      _isFlashcardLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.addFlashcardsFromText] Failed: $e');
      }
      _isFlashcardLoading = false;
      _error =
          'Unable to process the flashcard content. Please check the format and try again.';
      notifyListeners();
      return false;
    }
  }

  /// Imports a quiz with questions and a name into a specific course.
  Future<void> importQuizToCourse(
    String courseId,
    List<Question> questions,
    String name,
  ) async {
    try {
      await _courseService.addQuizToCourse(
        courseId,
        questions,
        quizName: name,
      );
      await _loadCourses();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.importQuizToCourse] Failed: $e');
      }
      rethrow;
    }
  }

  /// Imports a flashcard set into a specific course.
  Future<void> importFlashcardSetToCourse(
    String courseId,
    List<Flashcard> flashcards,
    String name,
  ) async {
    try {
      await _courseService.addFlashcardSetToCourse(
        courseId,
        flashcards,
        flashcardSetName: name,
      );
      await _loadCourses();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.importFlashcardSetToCourse] Failed: $e');
      }
      rethrow;
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

  /// Reorders PDFs in the selected course.
  Future<bool> reorderPdfsInCourse(int oldIndex, int newIndex) async {
    if (_selectedCourse == null) {
      return false;
    }

    // Optimistically update the UI immediately to prevent visual glitch
    final updatedPdfs = <String>[..._selectedCourse!.pdfs];
    final item = updatedPdfs.removeAt(oldIndex);
    updatedPdfs.insert(newIndex, item);

    // Reorder pdfNames map
    Map<int, String>? updatedPdfNames;
    if (_selectedCourse!.pdfNames != null &&
        _selectedCourse!.pdfNames!.isNotEmpty) {
      updatedPdfNames = <int, String>{};
      final oldIndices = List<int>.generate(
        _selectedCourse!.pdfs.length,
        (int i) => i,
      );
      final movedIndex = oldIndices.removeAt(oldIndex);
      oldIndices.insert(newIndex, movedIndex);
      for (var newIdx = 0; newIdx < updatedPdfs.length; newIdx++) {
        final oldIdx = oldIndices[newIdx];
        if (_selectedCourse!.pdfNames!.containsKey(oldIdx)) {
          updatedPdfNames[newIdx] = _selectedCourse!.pdfNames![oldIdx]!;
        }
      }
    }

    _selectedCourse = _selectedCourse!.copyWith(
      pdfs: updatedPdfs,
      pdfNames: updatedPdfNames,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    notifyListeners();

    try {
      await _courseService.reorderPdfsInCourse(
        _selectedCourse!.id,
        oldIndex,
        newIndex,
      );
      await _loadCourses();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.reorderPdfsInCourse] Failed: $e');
      }
      _error = 'Failed to reorder PDFs';
      // Reload to revert optimistic update
      await _loadCourses();
      notifyListeners();
      return false;
    }
  }

  /// Reorders quizzes in the selected course.
  Future<bool> reorderQuizzesInCourse(int oldIndex, int newIndex) async {
    if (_selectedCourse == null) {
      return false;
    }

    // Optimistically update the UI immediately to prevent visual glitch
    final updatedQuizzes = <List<Question>>[..._selectedCourse!.quizzes];
    final item = updatedQuizzes.removeAt(oldIndex);
    updatedQuizzes.insert(newIndex, item);

    // Reorder quizNames map to match the new quiz order
    // Build a mapping: for each new index, determine which old index it came from
    // IMPORTANT: We preserve ALL names (both custom and default) so they move with items
    final updatedQuizNames = <int, String>{};

    // Create a list representing the original indices
    final originalIndices = List<int>.generate(
      _selectedCourse!.quizzes.length,
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
      final name = _selectedCourse!.getQuizName(oldIdx);
      updatedQuizNames[newIdx] = name;
    }

    _selectedCourse = _selectedCourse!.copyWith(
      quizzes: updatedQuizzes,
      quizNames: updatedQuizNames,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    notifyListeners();

    try {
      await _courseService.reorderQuizzesInCourse(
        _selectedCourse!.id,
        oldIndex,
        newIndex,
      );
      await _loadCourses();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.reorderQuizzesInCourse] Failed: $e');
      }
      _error = 'Failed to reorder quizzes';
      // Reload to revert optimistic update
      await _loadCourses();
      notifyListeners();
      return false;
    }
  }

  /// Reorders flashcard sets in the selected course.
  Future<bool> reorderFlashcardSetsInCourse(
    int oldIndex,
    int newIndex,
  ) async {
    if (_selectedCourse == null) {
      return false;
    }

    // Optimistically update the UI immediately to prevent visual glitch
    final updatedFlashcards = <List<Flashcard>>[..._selectedCourse!.flashcards];
    final item = updatedFlashcards.removeAt(oldIndex);
    updatedFlashcards.insert(newIndex, item);

    // Reorder flashcardSetNames map to match the new flashcard set order
    // Build a mapping: for each new index, determine which old index it came from
    // IMPORTANT: We preserve ALL names (both custom and default) so they move with items
    final updatedFlashcardSetNames = <int, String>{};

    // Create a list representing the original indices
    final originalIndices = List<int>.generate(
      _selectedCourse!.flashcards.length,
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
      final name = _selectedCourse!.getFlashcardSetName(oldIdx);
      updatedFlashcardSetNames[newIdx] = name;
    }

    _selectedCourse = _selectedCourse!.copyWith(
      flashcards: updatedFlashcards,
      flashcardSetNames: updatedFlashcardSetNames,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    notifyListeners();

    try {
      await _courseService.reorderFlashcardSetsInCourse(
        _selectedCourse!.id,
        oldIndex,
        newIndex,
      );
      await _loadCourses();
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.reorderFlashcardSetsInCourse] Failed: $e');
      }
      _error = 'Failed to reorder flashcard sets';
      // Reload to revert optimistic update
      await _loadCourses();
      notifyListeners();
      return false;
    }
  }

  /// Renames a quiz in the selected course.
  Future<bool> renameQuiz(int quizIndex, String newName) async {
    if (_selectedCourse == null) {
      return false;
    }

    if (quizIndex < 0 || quizIndex >= _selectedCourse!.quizzes.length) {
      return false;
    }

    if (newName.trim().isEmpty) {
      return false;
    }

    try {
      final updatedQuizNames = Map<int, String>.from(
        _selectedCourse!.quizNames ?? <int, String>{},
      );
      updatedQuizNames[quizIndex] = newName.trim();

      final updatedCourse = _selectedCourse!.copyWith(
        quizNames: updatedQuizNames,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _courseService.updateCourse(updatedCourse);
      await _loadCourses();

      // Update selected course reference
      if (_courses.isNotEmpty) {
        try {
          final refreshedCourse = _courses.firstWhere(
            (Course c) => c.id == _selectedCourse!.id,
          );
          _selectedCourse = refreshedCourse;
        } on Exception catch (_) {
          // Course not found, ignore
        }
      }

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.renameQuiz] Failed: $e');
      }
      _error = 'Failed to rename quiz';
      notifyListeners();
      return false;
    }
  }

  /// Renames a flashcard set in the selected course.
  Future<bool> renameFlashcardSet(int flashcardSetIndex, String newName) async {
    if (_selectedCourse == null) {
      return false;
    }

    if (flashcardSetIndex < 0 ||
        flashcardSetIndex >= _selectedCourse!.flashcards.length) {
      return false;
    }

    if (newName.trim().isEmpty) {
      return false;
    }

    try {
      final updatedFlashcardSetNames = Map<int, String>.from(
        _selectedCourse!.flashcardSetNames ?? <int, String>{},
      );
      updatedFlashcardSetNames[flashcardSetIndex] = newName.trim();

      final updatedCourse = _selectedCourse!.copyWith(
        flashcardSetNames: updatedFlashcardSetNames,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _courseService.updateCourse(updatedCourse);
      await _loadCourses();

      // Update selected course reference
      if (_courses.isNotEmpty) {
        try {
          final refreshedCourse = _courses.firstWhere(
            (Course c) => c.id == _selectedCourse!.id,
          );
          _selectedCourse = refreshedCourse;
        } on Exception catch (_) {
          // Course not found, ignore
        }
      }

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.renameFlashcardSet] Failed: $e');
      }
      _error = 'Failed to rename flashcard set';
      notifyListeners();
      return false;
    }
  }

  /// Renames a PDF in the selected course.
  Future<bool> renamePdf(int pdfIndex, String newName) async {
    if (_selectedCourse == null) {
      return false;
    }

    if (pdfIndex < 0 || pdfIndex >= _selectedCourse!.pdfs.length) {
      return false;
    }

    if (newName.trim().isEmpty) {
      return false;
    }

    try {
      final updatedPdfNames = Map<int, String>.from(
        _selectedCourse!.pdfNames ?? <int, String>{},
      );
      updatedPdfNames[pdfIndex] = newName.trim();

      final updatedCourse = _selectedCourse!.copyWith(
        pdfNames: updatedPdfNames,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _courseService.updateCourse(updatedCourse);
      await _loadCourses();

      // Update selected course reference
      if (_courses.isNotEmpty) {
        try {
          final refreshedCourse = _courses.firstWhere(
            (Course c) => c.id == _selectedCourse!.id,
          );
          _selectedCourse = refreshedCourse;
        } on Exception catch (_) {
          // Course not found, ignore
        }
      }

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.renamePdf] Failed: $e');
      }
      _error = 'Failed to rename PDF';
      notifyListeners();
      return false;
    }
  }

  /// Toggles the quiz sorting preference for the selected course.
  Future<bool> toggleQuizSortingPreference() async {
    if (_selectedCourse == null) {
      return false;
    }

    try {
      final currentPreference = _selectedCourse!.quizSortingPreference;
      final newPreference = currentPreference == QuizSortingPreference.random
          ? QuizSortingPreference.sequential
          : QuizSortingPreference.random;

      final updatedCourse = _selectedCourse!.copyWith(
        quizSortingPreference: newPreference,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Optimistic update
      _selectedCourse = updatedCourse;
      notifyListeners();

      await _courseService.updateCourse(updatedCourse);
      await _loadCourses();

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[HomeController.toggleQuizSortingPreference] Failed: $e');
      }
      _error = 'Failed to update sorting preference';
      await _loadCourses(); // Revert optimistic update
      notifyListeners();
      return false;
    }
  }
}
