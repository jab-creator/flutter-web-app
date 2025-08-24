import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Child extends Equatable {
  const Child({
    required this.id,
    required this.userId,
    required this.firstName,
    this.lastName,
    this.dob,
    required this.slug,
    this.heroPhotoUrl,
    this.goalCad,
    required this.createdAt,
  });

  /// The child's unique ID.
  final String id;

  /// Reference to the parent user's ID.
  final String userId;

  /// The child's first name.
  final String firstName;

  /// The child's last name (optional).
  final String? lastName;

  /// The child's date of birth (optional).
  final DateTime? dob;

  /// Unique slug for public URLs (e.g., "brennan").
  final String slug;

  /// URL to the child's hero photo (optional).
  final String? heroPhotoUrl;

  /// The savings goal in CAD dollars (optional).
  final double? goalCad;

  /// When the child record was created.
  final DateTime createdAt;

  /// Gets the child's full name.
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  /// Gets the child's display name for public pages.
  String get displayName => firstName;

  /// Creates a [Child] from Firestore document data.
  factory Child.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Child(
      id: doc.id,
      userId: data['userId'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String?,
      dob: (data['dob'] as Timestamp?)?.toDate(),
      slug: data['slug'] as String,
      heroPhotoUrl: data['heroPhotoUrl'] as String?,
      goalCad: (data['goalCad'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts the [Child] to a Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'slug': slug,
      'heroPhotoUrl': heroPhotoUrl,
      'goalCad': goalCad,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Generates a unique slug from the child's first name.
  /// This should be used with the FirestoreService to ensure uniqueness.
  static String generateBaseSlug(String firstName) {
    return firstName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .replaceAll(RegExp(r'\s+'), '');
  }

  /// Creates a copy of the current [Child] with property changes.
  Child copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? slug,
    String? heroPhotoUrl,
    double? goalCad,
    DateTime? createdAt,
  }) {
    return Child(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      slug: slug ?? this.slug,
      heroPhotoUrl: heroPhotoUrl ?? this.heroPhotoUrl,
      goalCad: goalCad ?? this.goalCad,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        dob,
        slug,
        heroPhotoUrl,
        goalCad,
        createdAt,
      ];
}