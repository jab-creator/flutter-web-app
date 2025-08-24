import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Theme options for gift pages.
enum GiftPageTheme {
  defaultTheme('default'),
  soft('soft'),
  bold('bold');

  const GiftPageTheme(this.value);
  final String value;

  static GiftPageTheme fromString(String value) {
    return GiftPageTheme.values.firstWhere(
      (theme) => theme.value == value,
      orElse: () => GiftPageTheme.defaultTheme,
    );
  }
}

class GiftPage extends Equatable {
  const GiftPage({
    required this.id,
    required this.childId,
    required this.headline,
    required this.blurb,
    this.theme = GiftPageTheme.defaultTheme,
    this.isPublic = false,
  });

  /// The gift page's unique ID.
  final String id;

  /// Reference to the child's ID.
  final String childId;

  /// The main headline for the gift page.
  final String headline;

  /// The descriptive text/blurb for the gift page.
  final String blurb;

  /// The visual theme for the gift page.
  final GiftPageTheme theme;

  /// Whether the gift page is publicly accessible.
  final bool isPublic;

  /// Creates a [GiftPage] from Firestore document data.
  factory GiftPage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GiftPage(
      id: doc.id,
      childId: data['childId'] as String,
      headline: data['headline'] as String,
      blurb: data['blurb'] as String,
      theme: GiftPageTheme.fromString(data['theme'] as String? ?? 'default'),
      isPublic: data['isPublic'] as bool? ?? false,
    );
  }

  /// Converts the [GiftPage] to a Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'headline': headline,
      'blurb': blurb,
      'theme': theme.value,
      'isPublic': isPublic,
    };
  }

  /// Creates a copy of the current [GiftPage] with property changes.
  GiftPage copyWith({
    String? id,
    String? childId,
    String? headline,
    String? blurb,
    GiftPageTheme? theme,
    bool? isPublic,
  }) {
    return GiftPage(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      headline: headline ?? this.headline,
      blurb: blurb ?? this.blurb,
      theme: theme ?? this.theme,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        headline,
        blurb,
        theme,
        isPublic,
      ];
}