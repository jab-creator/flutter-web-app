import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a gift transaction.
enum GiftStatus {
  pending('pending'),
  succeeded('succeeded'),
  failed('failed'),
  refunded('refunded');

  const GiftStatus(this.value);
  final String value;

  static GiftStatus fromString(String value) {
    return GiftStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => GiftStatus.pending,
    );
  }
}

class Gift extends Equatable {
  const Gift({
    required this.id,
    required this.childId,
    this.gifterName,
    this.gifterEmail,
    this.message,
    required this.amountCents,
    required this.stripePaymentIntent,
    this.status = GiftStatus.pending,
    required this.createdAt,
  });

  /// The gift's unique ID.
  final String id;

  /// Reference to the child's ID.
  final String childId;

  /// The gifter's name (optional).
  final String? gifterName;

  /// The gifter's email (optional).
  final String? gifterEmail;

  /// Personal message from the gifter (optional).
  final String? message;

  /// The gift amount in cents (source of truth for money).
  final int amountCents;

  /// Stripe payment intent ID.
  final String stripePaymentIntent;

  /// Current status of the gift transaction.
  final GiftStatus status;

  /// When the gift was created.
  final DateTime createdAt;

  /// Gets the gift amount in CAD dollars (derived from cents).
  double get amountCad => amountCents / 100.0;

  /// Gets a formatted CAD amount string (e.g., "$25.00").
  String get formattedAmount => '\$${amountCad.toStringAsFixed(2)}';

  /// Gets the gifter's display name or "Anonymous" if not provided.
  String get displayName => gifterName?.isNotEmpty == true ? gifterName! : 'Anonymous';

  /// Whether this gift has been successfully processed.
  bool get isSuccessful => status == GiftStatus.succeeded;

  /// Whether this gift is still pending.
  bool get isPending => status == GiftStatus.pending;

  /// Whether this gift has failed.
  bool get hasFailed => status == GiftStatus.failed;

  /// Whether this gift has been refunded.
  bool get isRefunded => status == GiftStatus.refunded;

  /// Creates a [Gift] from Firestore document data.
  factory Gift.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Gift(
      id: doc.id,
      childId: data['childId'] as String,
      gifterName: data['gifterName'] as String?,
      gifterEmail: data['gifterEmail'] as String?,
      message: data['message'] as String?,
      amountCents: data['amountCents'] as int,
      stripePaymentIntent: data['stripePaymentIntent'] as String,
      status: GiftStatus.fromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts the [Gift] to a Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'gifterName': gifterName,
      'gifterEmail': gifterEmail,
      'message': message,
      'amountCents': amountCents,
      'stripePaymentIntent': stripePaymentIntent,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a gift from CAD amount (converts to cents).
  factory Gift.fromCadAmount({
    required String id,
    required String childId,
    String? gifterName,
    String? gifterEmail,
    String? message,
    required double amountCad,
    required String stripePaymentIntent,
    GiftStatus status = GiftStatus.pending,
    required DateTime createdAt,
  }) {
    return Gift(
      id: id,
      childId: childId,
      gifterName: gifterName,
      gifterEmail: gifterEmail,
      message: message,
      amountCents: (amountCad * 100).round(),
      stripePaymentIntent: stripePaymentIntent,
      status: status,
      createdAt: createdAt,
    );
  }

  /// Creates a copy of the current [Gift] with property changes.
  Gift copyWith({
    String? id,
    String? childId,
    String? gifterName,
    String? gifterEmail,
    String? message,
    int? amountCents,
    String? stripePaymentIntent,
    GiftStatus? status,
    DateTime? createdAt,
  }) {
    return Gift(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      gifterName: gifterName ?? this.gifterName,
      gifterEmail: gifterEmail ?? this.gifterEmail,
      message: message ?? this.message,
      amountCents: amountCents ?? this.amountCents,
      stripePaymentIntent: stripePaymentIntent ?? this.stripePaymentIntent,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        gifterName,
        gifterEmail,
        message,
        amountCents,
        stripePaymentIntent,
        status,
        createdAt,
      ];
}