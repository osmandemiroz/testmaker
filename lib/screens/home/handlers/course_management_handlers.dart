import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';

/// Handlers for course management operations.
class CourseManagementHandlers {
  /// Creates a new course with the given name.
  static Future<void> createCourse(
    HomeController controller,
    String name,
  ) async {
    await controller.createCourse(name);
  }

  /// Deletes a course from local storage.
  static Future<void> deleteCourse(
    HomeController controller,
    Course course,
  ) async {
    await controller.deleteCourse(course.id);
  }

  /// Uploads a PDF file to the selected course.
  static Future<void> uploadPdfToCourse(
    HomeController controller,
    Course? course,
  ) async {
    if (course == null) return;
    controller.selectCourse(course);
    await controller.uploadPdfToCourse();
  }
}
