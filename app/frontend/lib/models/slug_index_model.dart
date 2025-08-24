import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SlugIndex extends Equatable {
  const SlugIndex({
    required this.slug,
    required this.childId,
  });

  /// The unique slug (also serves as the document ID).
  final String slug;

  /// Reference to the child's ID.
  final String childId;

  /// Creates a [SlugIndex] from Firestore document data.
  factory SlugIndex.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SlugIndex(
      slug: doc.id,
      childId: data['childId'] as String,
    );
  }

  /// Converts the [SlugIndex] to a Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
    };
  }

  /// Creates a copy of the current [SlugIndex] with property changes.
  SlugIndex copyWith({
    String? slug,
    String? childId,
  }) {
    return SlugIndex(
      slug: slug ?? this.slug,
      childId: childId ?? this.childId,
    );
  }

  @override
  List<Object?> get props => [slug, childId];
}