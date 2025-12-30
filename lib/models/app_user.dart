// ********************************************************************
// app_user.dart
// ********************************************************************
//
// User model for Firebase Authentication.
// Tracks the authenticated user's information including their
// authentication provider (Google, Apple, or Guest/Anonymous).
//
// This model is designed to support future premium membership features
// by tracking whether a user is anonymous (guest) and can be upgraded.

import 'package:flutter/foundation.dart';

/// Enum representing the authentication provider used
enum AuthProvider {
  /// User signed in with Google
  google,

  /// User signed in with Apple
  apple,

  /// User is using guest/anonymous authentication
  guest,

  /// Unknown or unset provider
  unknown,
}

/// ********************************************************************
/// AppUser
/// ********************************************************************
///
/// Represents an authenticated user in the application.
/// Contains all relevant user information from Firebase Auth.
///
@immutable
class AppUser {
  /// Creates an AppUser instance
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.authProvider = AuthProvider.unknown,
    this.isAnonymous = false,
  });

  /// Creates an AppUser from Firebase User data
  ///
  /// [uid] The unique user ID from Firebase
  /// [email] The user's email (may be null for anonymous users)
  /// [displayName] The user's display name
  /// [photoUrl] URL to the user's profile photo
  /// [providerData] List of provider information to determine auth method
  /// [isAnonymous] Whether the user is anonymous (guest)
  factory AppUser.fromFirebase({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? providerIds,
    bool isAnonymous = false,
  }) {
    // Determine the auth provider based on provider IDs
    var provider = AuthProvider.unknown;

    if (isAnonymous) {
      provider = AuthProvider.guest;
    } else if (providerIds != null && providerIds.isNotEmpty) {
      // Check provider IDs to determine sign-in method
      if (providerIds.any((id) => id.contains('google'))) {
        provider = AuthProvider.google;
      } else if (providerIds.any((id) => id.contains('apple'))) {
        provider = AuthProvider.apple;
      }
    }

    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      authProvider: provider,
      isAnonymous: isAnonymous,
    );
  }

  /// The unique user ID from Firebase
  final String uid;

  /// The user's email address (may be null for anonymous users)
  final String? email;

  /// The user's display name
  final String? displayName;

  /// URL to the user's profile photo
  final String? photoUrl;

  /// The authentication provider used to sign in
  final AuthProvider authProvider;

  /// Whether this is an anonymous (guest) user
  final bool isAnonymous;

  /// Returns a display-friendly name for the user
  ///
  /// Returns the display name if available, otherwise returns the
  /// email address, or 'Guest' for anonymous users.
  String get displayNameOrFallback {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (email != null && email!.isNotEmpty) {
      // Return the part before @ for emails
      final atIndex = email!.indexOf('@');
      if (atIndex > 0) {
        return email!.substring(0, atIndex);
      }
      return email!;
    }
    return 'Guest';
  }

  /// Whether this user can be upgraded to a full account
  ///
  /// Anonymous users can link their account to Google or Apple
  /// to preserve their data when upgrading.
  bool get canUpgrade => isAnonymous;

  /// Returns a human-readable string for the auth provider
  String get providerDisplayName {
    switch (authProvider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.guest:
        return 'Guest';
      case AuthProvider.unknown:
        return 'Unknown';
    }
  }

  /// Creates a copy of this AppUser with the given fields replaced
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider? authProvider,
    bool? isAnonymous,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName, '
        'provider: $authProvider, isAnonymous: $isAnonymous)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.authProvider == authProvider &&
        other.isAnonymous == isAnonymous;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      email,
      displayName,
      photoUrl,
      authProvider,
      isAnonymous,
    );
  }
}
