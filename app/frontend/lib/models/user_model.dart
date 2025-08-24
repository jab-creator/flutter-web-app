import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.createdAt,
    this.lastSignInAt,
  });

  /// The current user's id.
  final String id;

  /// The current user's email address.
  final String email;

  /// The current user's display name (optional).
  final String? displayName;

  /// The current user's photo URL (optional).
  final String? photoURL;

  /// Whether the current user's email address is verified.
  final bool emailVerified;

  /// The time the user was created.
  final DateTime? createdAt;

  /// The time the user last signed in.
  final DateTime? lastSignInAt;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '', email: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  /// Creates a [User] from a [firebase_auth.User].
  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
      lastSignInAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  /// Creates a copy of the current [User] with property changes.
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        emailVerified,
        createdAt,
        lastSignInAt,
      ];
}