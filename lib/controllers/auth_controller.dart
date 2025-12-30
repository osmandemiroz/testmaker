import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:testmaker/models/app_user.dart';
import 'package:testmaker/services/auth_service.dart';

/// ********************************************************************
/// auth_controller.dart
/// ********************************************************************
///
/// Controller for managing authentication state throughout the app.
/// Uses ChangeNotifier to provide reactive updates to the UI when
/// the authentication state changes.
///
/// This controller:
/// - Listens to Firebase auth state changes
/// - Provides methods for sign-in, sign-out, and account linking
/// - Tracks loading and error states for UI feedback
/// - Exposes the current user and authentication status
///

/// Enum representing the current authentication state
enum AuthState {
  /// Initial state, checking auth status
  initial,

  /// User is authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// Authentication is in progress
  loading,
}

/// ********************************************************************
/// AuthController
/// ********************************************************************
///
/// ChangeNotifier-based controller for authentication state management.
/// Provides a reactive interface for the UI to respond to auth changes.
///
class AuthController extends ChangeNotifier {
  /// Creates an AuthController and starts listening to auth state changes
  AuthController() {
    _init();
  }

  /// The auth service instance
  final AuthService _authService = AuthService.instance;

  /// Subscription to auth state changes
  StreamSubscription<AppUser?>? _authSubscription;

  /// Current authentication state
  AuthState _state = AuthState.initial;

  /// The currently authenticated user
  AppUser? _user;

  /// Error message from the last operation
  String? _error;

  /// Whether an authentication operation is in progress
  bool _isLoading = false;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Current authentication state
  AuthState get state => _state;

  /// The currently authenticated user (null if not authenticated)
  AppUser? get user => _user;

  /// Error message from the last failed operation
  String? get error => _error;

  /// Whether an authentication operation is in progress
  bool get isLoading => _isLoading;

  /// Whether a user is currently authenticated
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  /// Whether the current user is anonymous (guest)
  bool get isAnonymous => _user?.isAnonymous ?? false;

  /// Whether Apple Sign-In is available on this platform
  Future<bool> get isAppleSignInAvailable => _authService.isAppleSignInAvailable;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initializes the controller by checking current auth state
  void _init() {
    // [AuthController._init] - Initializing auth controller
    debugPrint('[AuthController._init] Initializing...');

    // Check if user is already signed in
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      _state = AuthState.authenticated;
      debugPrint('[AuthController._init] User already signed in: '
          '${currentUser.displayNameOrFallback}');
    } else {
      _state = AuthState.unauthenticated;
      debugPrint('[AuthController._init] No user signed in');
    }

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (Object error) {
        debugPrint('[AuthController._init] Auth stream error: $error');
        _error = 'Authentication error: $error';
        notifyListeners();
      },
    );

    notifyListeners();
  }

  /// Handles auth state changes from Firebase
  void _onAuthStateChanged(AppUser? user) {
    // [AuthController._onAuthStateChanged] - Auth state changed
    debugPrint('[AuthController._onAuthStateChanged] User: '
        '${user?.displayNameOrFallback ?? 'null'}');

    _user = user;
    _state = user != null ? AuthState.authenticated : AuthState.unauthenticated;
    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // SIGN-IN METHODS
  // ============================================================

  /// Signs in with Google
  ///
  /// Returns true if successful, false otherwise.
  /// Sets [error] if the operation fails.
  Future<bool> signInWithGoogle() async {
    return _performAuthOperation(_authService.signInWithGoogle);
  }

  /// Signs in with Apple
  ///
  /// Returns true if successful, false otherwise.
  /// Sets [error] if the operation fails.
  Future<bool> signInWithApple() async {
    return _performAuthOperation(_authService.signInWithApple);
  }

  /// Signs in as a guest (anonymous)
  ///
  /// Returns true if successful, false otherwise.
  /// Sets [error] if the operation fails.
  Future<bool> signInAsGuest() async {
    return _performAuthOperation(_authService.signInAsGuest);
  }

  /// Signs in with email and password
  ///
  /// Returns true if successful, false otherwise.
  /// Sets [error] if the operation fails.
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _performAuthOperation(
      () => _authService.signInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  /// Registers a new account with email and password
  ///
  /// Returns true if successful, false otherwise.
  /// Sets [error] if the operation fails.
  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _performAuthOperation(
      () => _authService.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  /// Sends a password reset email
  ///
  /// Returns true if the email was sent successfully, false otherwise.
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.sendPasswordResetEmail(email);

      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _error = result.error ?? 'Failed to send reset email';
        _setLoading(false);
        return false;
      }
    } on Exception catch (e) {
      debugPrint('[AuthController.sendPasswordResetEmail] Error: $e');
      _error = 'An unexpected error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Signs out the current user
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();

      _user = null;
      _state = AuthState.unauthenticated;
      _setLoading(false);
      return true;
    } on Exception catch (e) {
      debugPrint('[AuthController.signOut] Error: $e');
      _error = 'Failed to sign out: $e';
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // ACCOUNT LINKING (for upgrading guest accounts)
  // ============================================================

  /// Links the current anonymous account to Google
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> linkWithGoogle() async {
    if (!isAnonymous) {
      _error = 'Only guest accounts can be upgraded';
      notifyListeners();
      return false;
    }
    return _performAuthOperation(_authService.linkWithGoogle);
  }

  /// Links the current anonymous account to Apple
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> linkWithApple() async {
    if (!isAnonymous) {
      _error = 'Only guest accounts can be upgraded';
      notifyListeners();
      return false;
    }
    return _performAuthOperation(_authService.linkWithApple);
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Performs an authentication operation with loading and error handling
  Future<bool> _performAuthOperation(
    Future<AuthResult> Function() operation,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await operation();

      if (result.success && result.user != null) {
        _user = result.user;
        _state = AuthState.authenticated;
        _setLoading(false);
        return true;
      } else {
        _error = result.error ?? 'Authentication failed';
        _setLoading(false);
        return false;
      }
    } on Exception catch (e) {
      debugPrint('[AuthController._performAuthOperation] Error: $e');
      _error = 'An unexpected error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Sets the loading state and notifies listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = AuthState.loading;
    }
    notifyListeners();
  }

  /// Clears the current error
  void _clearError() {
    _error = null;
  }

  /// Clears any error message (can be called from UI)
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void dispose() {
    // [AuthController.dispose] - Disposing controller
    debugPrint('[AuthController.dispose] Disposing...');
    _authSubscription?.cancel();
    super.dispose();
  }
}
