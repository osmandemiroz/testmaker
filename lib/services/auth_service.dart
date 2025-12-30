import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:testmaker/models/app_user.dart';

/// ********************************************************************
/// auth_service.dart
/// ********************************************************************
///
/// Firebase Authentication service that handles all authentication
/// operations including Google Sign-In, Apple Sign-In, and Guest
/// (anonymous) authentication.
///
/// This service is designed to:
/// - Provide a clean API for authentication operations
/// - Handle platform-specific authentication flows
/// - Support account linking for anonymous users upgrading to full accounts
/// - Integrate with Firebase for persistent auth state
///

/// Result class for authentication operations
class AuthResult {
  const AuthResult._({
    this.user,
    this.error,
    this.success = false,
  });

  /// Creates a successful authentication result
  factory AuthResult.success(AppUser user) {
    return AuthResult._(user: user, success: true);
  }

  /// Creates a failed authentication result with an error message
  factory AuthResult.failure(String error) {
    return AuthResult._(error: error);
  }

  /// Creates a cancelled authentication result
  factory AuthResult.cancelled() {
    return const AuthResult._(error: 'Authentication cancelled by user');
  }

  /// The authenticated user (if successful)
  final AppUser? user;

  /// Error message (if failed)
  final String? error;

  /// Whether the authentication was successful
  final bool success;
}

/// ********************************************************************
/// AuthService
/// ********************************************************************
///
/// Singleton service for handling Firebase Authentication.
/// Supports Google Sign-In, Apple Sign-In, and Guest authentication.
///
class AuthService {
  /// Private constructor for singleton pattern
  AuthService._();

  /// Singleton instance
  static final AuthService instance = AuthService._();

  /// Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  /// Stream of authentication state changes
  ///
  /// Emits the current user whenever the auth state changes.
  /// Emits null when the user signs out.
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return _createAppUser(user);
    });
  }

  /// The currently signed-in user, or null if not signed in
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _createAppUser(user);
  }

  /// Whether a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Whether the current user is anonymous (guest)
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  // ============================================================
  // SIGN-IN METHODS
  // ============================================================

  /// Signs in with Google
  ///
  /// Opens the Google Sign-In flow and authenticates with Firebase.
  /// Returns an [AuthResult] with the user or an error.
  Future<AuthResult> signInWithGoogle() async {
    try {
      // [AuthService.signInWithGoogle] - Starting Google Sign-In flow
      debugPrint('[AuthService.signInWithGoogle] Starting Google Sign-In...');

      // Trigger the Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in
      if (googleUser == null) {
        debugPrint('[AuthService.signInWithGoogle] User cancelled sign-in');
        return AuthResult.cancelled();
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in with Google');
      }

      debugPrint('[AuthService.signInWithGoogle] Successfully signed in: '
          '${user.email}');
      return AuthResult.success(_createAppUser(user));
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService.signInWithGoogle] Firebase error: ${e.message}');
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.signInWithGoogle] Error: $e');
      return AuthResult.failure('Failed to sign in with Google: $e');
    }
  }

  /// Signs in with Apple
  ///
  /// Opens the Apple Sign-In flow and authenticates with Firebase.
  /// Returns an [AuthResult] with the user or an error.
  ///
  /// Note: Apple Sign-In requires additional setup:
  /// - iOS: Add "Sign in with Apple" capability in Xcode
  /// - Android: Apple Sign-In works via web redirect
  Future<AuthResult> signInWithApple() async {
    try {
      // [AuthService.signInWithApple] - Starting Apple Sign-In flow
      debugPrint('[AuthService.signInWithApple] Starting Apple Sign-In...');

      // Generate a random nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple Sign-In credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in with Apple');
      }

      // Apple may provide name on first sign-in only, so update profile
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((s) => s != null && s.isNotEmpty).join(' ');

        if (displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
          await user.reload();
        }
      }

      debugPrint('[AuthService.signInWithApple] Successfully signed in: '
          '${user.email}');
      return AuthResult.success(_createAppUser(_auth.currentUser ?? user));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint('[AuthService.signInWithApple] User cancelled sign-in');
        return AuthResult.cancelled();
      }
      debugPrint('[AuthService.signInWithApple] Apple error: ${e.message}');
      return AuthResult.failure('Apple Sign-In failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService.signInWithApple] Firebase error: ${e.message}');
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.signInWithApple] Error: $e');
      return AuthResult.failure('Failed to sign in with Apple: $e');
    }
  }

  /// Signs in with email and password
  ///
  /// Authenticates an existing user with their email and password.
  /// Returns an [AuthResult] with the user or an error.
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // [AuthService.signInWithEmailPassword] - Starting email sign-in
      debugPrint('[AuthService.signInWithEmailPassword] Signing in: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in');
      }

      debugPrint('[AuthService.signInWithEmailPassword] Successfully signed in');
      return AuthResult.success(_createAppUser(user));
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService.signInWithEmailPassword] Firebase error: ${e.message}',
      );
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.signInWithEmailPassword] Error: $e');
      return AuthResult.failure('Failed to sign in: $e');
    }
  }

  /// Creates a new account with email and password
  ///
  /// Registers a new user with their email and password.
  /// Optionally sets the display name after creation.
  /// Returns an [AuthResult] with the new user or an error.
  Future<AuthResult> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // [AuthService.registerWithEmailPassword] - Creating new account
      debugPrint('[AuthService.registerWithEmailPassword] Registering: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to create account');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
        await user.reload();
      }

      debugPrint(
        '[AuthService.registerWithEmailPassword] Successfully registered',
      );
      return AuthResult.success(_createAppUser(_auth.currentUser ?? user));
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService.registerWithEmailPassword] Firebase error: ${e.message}',
      );
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.registerWithEmailPassword] Error: $e');
      return AuthResult.failure('Failed to create account: $e');
    }
  }

  /// Sends a password reset email
  ///
  /// Sends an email to the specified address with a link to reset password.
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('[AuthService.sendPasswordResetEmail] Sending to: $email');

      await _auth.sendPasswordResetEmail(email: email.trim());

      debugPrint('[AuthService.sendPasswordResetEmail] Email sent successfully');
      // Return a success result without a user
      return const AuthResult._(success: true);
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService.sendPasswordResetEmail] Firebase error: ${e.message}',
      );
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.sendPasswordResetEmail] Error: $e');
      return AuthResult.failure('Failed to send reset email: $e');
    }
  }

  /// Signs in as a guest (anonymous authentication)
  ///
  /// Creates an anonymous Firebase account that can be upgraded later
  /// by linking to Google or Apple credentials.
  /// Returns an [AuthResult] with the guest user or an error.
  Future<AuthResult> signInAsGuest() async {
    try {
      // [AuthService.signInAsGuest] - Starting anonymous sign-in
      debugPrint('[AuthService.signInAsGuest] Starting anonymous sign-in...');

      final userCredential = await _auth.signInAnonymously();

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in as guest');
      }

      debugPrint('[AuthService.signInAsGuest] Successfully signed in as guest: '
          '${user.uid}');
      return AuthResult.success(_createAppUser(user));
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService.signInAsGuest] Firebase error: ${e.message}');
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.signInAsGuest] Error: $e');
      return AuthResult.failure('Failed to sign in as guest: $e');
    }
  }

  // ============================================================
  // SIGN-OUT
  // ============================================================

  /// Signs out the current user
  ///
  /// Signs out from Firebase and any linked providers (Google).
  Future<void> signOut() async {
    try {
      // [AuthService.signOut] - Signing out user
      debugPrint('[AuthService.signOut] Signing out...');

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      debugPrint('[AuthService.signOut] Successfully signed out');
    } catch (e) {
      debugPrint('[AuthService.signOut] Error: $e');
      rethrow;
    }
  }

  // ============================================================
  // ACCOUNT LINKING (for upgrading guest accounts)
  // ============================================================

  /// Links the current anonymous account to Google
  ///
  /// Allows a guest user to upgrade to a full Google account
  /// while preserving their data.
  Future<AuthResult> linkWithGoogle() async {
    if (!isAnonymous) {
      return AuthResult.failure('Only anonymous users can link accounts');
    }

    try {
      debugPrint('[AuthService.linkWithGoogle] Starting account linking...');

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.cancelled();
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.currentUser!.linkWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to link with Google');
      }

      debugPrint('[AuthService.linkWithGoogle] Successfully linked account');
      return AuthResult.success(_createAppUser(user));
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService.linkWithGoogle] Firebase error: ${e.message}');
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.linkWithGoogle] Error: $e');
      return AuthResult.failure('Failed to link with Google: $e');
    }
  }

  /// Links the current anonymous account to Apple
  ///
  /// Allows a guest user to upgrade to a full Apple account
  /// while preserving their data.
  Future<AuthResult> linkWithApple() async {
    if (!isAnonymous) {
      return AuthResult.failure('Only anonymous users can link accounts');
    }

    try {
      debugPrint('[AuthService.linkWithApple] Starting account linking...');

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await _auth.currentUser!.linkWithCredential(oauthCredential);

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to link with Apple');
      }

      debugPrint('[AuthService.linkWithApple] Successfully linked account');
      return AuthResult.success(_createAppUser(user));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult.cancelled();
      }
      return AuthResult.failure('Apple Sign-In failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService.linkWithApple] Firebase error: ${e.message}');
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } on Exception catch (e) {
      debugPrint('[AuthService.linkWithApple] Error: $e');
      return AuthResult.failure('Failed to link with Apple: $e');
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Creates an AppUser from a Firebase User
  AppUser _createAppUser(User user) {
    return AppUser.fromFirebase(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      providerIds: user.providerData.map((info) => info.providerId).toList(),
      isAnonymous: user.isAnonymous,
    );
  }

  /// Generates a random nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the SHA256 hash of a string (for Apple Sign-In nonce)
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Converts Firebase Auth error codes to user-friendly messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but '
            'different sign-in credentials. Sign in using the original method.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired. Please try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification. Please restart the sign-in process.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different account.';
      // Email/Password specific errors
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      default:
        return e.message ??
            'An error occurred during sign-in. Please try again.';
    }
  }

  /// Checks if Apple Sign-In is available on the current platform
  ///
  /// Apple Sign-In is available on iOS 13+, macOS 10.15+, and web.
  Future<bool> get isAppleSignInAvailable async {
    // Apple Sign-In is always available on iOS/macOS
    if (Platform.isIOS || Platform.isMacOS) {
      return SignInWithApple.isAvailable();
    }
    // On Android, Apple Sign-In works via web but may not be ideal
    return false;
  }
}
