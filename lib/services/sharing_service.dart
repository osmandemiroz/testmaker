import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/models/question.dart';
import 'package:testmaker/models/shared_content.dart';

/// Service for sharing quizzes and flashcards.
class SharingService {
  SharingService._();
  static final SharingService instance = SharingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'shared_content';

  /// Shares a quiz by uploading it to Firestore and showing the share sheet.
  Future<void> shareQuiz({
    required String title,
    required List<Question> questions,
    required String creatorId,
  }) async {
    final data = questions.map((q) => q.toJson()).toList();
    await _share(
      title: title,
      type: SharedContentType.quiz,
      data: data,
      creatorId: creatorId,
    );
  }

  /// Shares a flashcard set by uploading it to Firestore and showing the share sheet.
  Future<void> shareFlashcardSet({
    required String title,
    required List<Flashcard> flashcards,
    required String creatorId,
  }) async {
    final data = flashcards.map((f) => f.toJson()).toList();
    await _share(
      title: title,
      type: SharedContentType.flashcardSet,
      data: data,
      creatorId: creatorId,
    );
  }

  /// Internal helper to upload and share.
  Future<void> _share({
    required String title,
    required SharedContentType type,
    required List<dynamic> data,
    required String creatorId,
  }) async {
    try {
      debugPrint('[SharingService._share] Uploading to Firestore...');
      final docRef = await _firestore.collection(_collectionPath).add({
        'title': title,
        'type': type.name,
        'data': data,
        'creatorId': creatorId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      }).timeout(const Duration(seconds: 15));

      final shareUrl = 'https://testmaker-f7dd2.web.app/share/${docRef.id}';
      debugPrint(
        '[SharingService._share] Firestore upload successful. ID: ${docRef.id}',
      );
      debugPrint('[SharingService._share] Attempting to share...');

      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out this ${type == SharedContentType.quiz ? 'quiz' : 'flashcard set'}: $title\n\n'
              'Link: $shareUrl\n'
              'Share Code: ${docRef.id}\n\n'
              'To import manually, open TestMaker, go to Sidebar, and select "Import Content".',
          subject: 'Shared from TestMaker',
        ),
      );
      debugPrint('[SharingService._share] Share sheet opened successfully');
    } catch (e, s) {
      debugPrint('[SharingService._share] Error: $e');
      debugPrint('[SharingService._share] StackTrace: $s');

      if (e.toString().contains('permission-denied')) {
        throw Exception(
          'Firebase Permission Denied. Please ensure your Firestore Security Rules allow "create" for authenticated users in the "shared_content" collection.',
        );
      }
      rethrow;
    }
  }

  /// Fetches shared content by its ID.
  Future<SharedContent?> getSharedContent(String id) async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(id)
          .get()
          .timeout(const Duration(seconds: 15));
      if (!doc.exists) return null;

      return SharedContent.fromFirestore(doc.id, doc.data()!);
    } on Exception catch (e) {
      debugPrint('[SharingService.getSharedContent] Error: $e');
      return null;
    }
  }
}
