import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../lib/models/gift_model.dart';

void main() {
  group('GiftStatus', () {
    test('has correct values', () {
      expect(GiftStatus.pending.value, equals('pending'));
      expect(GiftStatus.succeeded.value, equals('succeeded'));
      expect(GiftStatus.failed.value, equals('failed'));
      expect(GiftStatus.refunded.value, equals('refunded'));
    });

    test('fromString returns correct status', () {
      expect(GiftStatus.fromString('pending'), equals(GiftStatus.pending));
      expect(GiftStatus.fromString('succeeded'), equals(GiftStatus.succeeded));
      expect(GiftStatus.fromString('failed'), equals(GiftStatus.failed));
      expect(GiftStatus.fromString('refunded'), equals(GiftStatus.refunded));
    });

    test('fromString returns pending for unknown value', () {
      expect(GiftStatus.fromString('unknown'), equals(GiftStatus.pending));
      expect(GiftStatus.fromString(''), equals(GiftStatus.pending));
    });
  });

  group('Gift Model', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('Constructor', () {
      test('creates Gift with required fields', () {
        final createdAt = DateTime.now();
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: createdAt,
        );

        expect(gift.id, equals('gift-id'));
        expect(gift.childId, equals('child-id'));
        expect(gift.gifterName, isNull);
        expect(gift.gifterEmail, isNull);
        expect(gift.message, isNull);
        expect(gift.amountCents, equals(2500));
        expect(gift.stripePaymentIntent, equals('pi_test123'));
        expect(gift.status, equals(GiftStatus.pending));
        expect(gift.createdAt, equals(createdAt));
      });

      test('creates Gift with all fields', () {
        final createdAt = DateTime.now();
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: 'John Doe',
          gifterEmail: 'john@example.com',
          message: 'Happy birthday!',
          amountCents: 5000,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.succeeded,
          createdAt: createdAt,
        );

        expect(gift.id, equals('gift-id'));
        expect(gift.childId, equals('child-id'));
        expect(gift.gifterName, equals('John Doe'));
        expect(gift.gifterEmail, equals('john@example.com'));
        expect(gift.message, equals('Happy birthday!'));
        expect(gift.amountCents, equals(5000));
        expect(gift.stripePaymentIntent, equals('pi_test123'));
        expect(gift.status, equals(GiftStatus.succeeded));
        expect(gift.createdAt, equals(createdAt));
      });
    });

    group('Money Calculations', () {
      test('amountCad converts cents to dollars correctly', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        expect(gift.amountCad, equals(25.0));
      });

      test('formattedAmount returns correct CAD format', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        expect(gift.formattedAmount, equals('\$25.00'));
      });

      test('formattedAmount handles cents correctly', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2550,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        expect(gift.formattedAmount, equals('\$25.50'));
      });
    });

    group('Display Properties', () {
      test('displayName returns gifter name when provided', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: 'John Doe',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        expect(gift.displayName, equals('John Doe'));
      });

      test('displayName returns Anonymous when name is null', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        expect(gift.displayName, equals('Anonymous'));
      });

      test('displayName returns Anonymous when name is empty', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: '',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        expect(gift.displayName, equals('Anonymous'));
      });
    });

    group('Status Properties', () {
      test('isSuccessful returns true for succeeded status', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.succeeded,
          createdAt: DateTime.now(),
        );

        expect(gift.isSuccessful, isTrue);
        expect(gift.isPending, isFalse);
        expect(gift.hasFailed, isFalse);
        expect(gift.isRefunded, isFalse);
      });

      test('isPending returns true for pending status', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(gift.isPending, isTrue);
        expect(gift.isSuccessful, isFalse);
        expect(gift.hasFailed, isFalse);
        expect(gift.isRefunded, isFalse);
      });

      test('hasFailed returns true for failed status', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.failed,
          createdAt: DateTime.now(),
        );

        expect(gift.hasFailed, isTrue);
        expect(gift.isSuccessful, isFalse);
        expect(gift.isPending, isFalse);
        expect(gift.isRefunded, isFalse);
      });

      test('isRefunded returns true for refunded status', () {
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.refunded,
          createdAt: DateTime.now(),
        );

        expect(gift.isRefunded, isTrue);
        expect(gift.isSuccessful, isFalse);
        expect(gift.isPending, isFalse);
        expect(gift.hasFailed, isFalse);
      });
    });

    group('fromCadAmount Factory', () {
      test('creates Gift from CAD amount', () {
        final createdAt = DateTime.now();
        final gift = Gift.fromCadAmount(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: 'John Doe',
          gifterEmail: 'john@example.com',
          message: 'Happy birthday!',
          amountCad: 25.50,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.succeeded,
          createdAt: createdAt,
        );

        expect(gift.amountCents, equals(2550));
        expect(gift.amountCad, equals(25.50));
        expect(gift.formattedAmount, equals('\$25.50'));
      });

      test('rounds CAD amount to nearest cent', () {
        final gift = Gift.fromCadAmount(
          id: 'gift-id',
          childId: 'child-id',
          amountCad: 25.555,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        expect(gift.amountCents, equals(2556));
      });
    });

    group('Firestore Serialization', () {
      test('toFirestore converts Gift to Map', () {
        final createdAt = DateTime.now();
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: 'John Doe',
          gifterEmail: 'john@example.com',
          message: 'Happy birthday!',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.succeeded,
          createdAt: createdAt,
        );

        final data = gift.toFirestore();

        expect(data['childId'], equals('child-id'));
        expect(data['gifterName'], equals('John Doe'));
        expect(data['gifterEmail'], equals('john@example.com'));
        expect(data['message'], equals('Happy birthday!'));
        expect(data['amountCents'], equals(2500));
        expect(data['stripePaymentIntent'], equals('pi_test123'));
        expect(data['status'], equals('succeeded'));
        expect(data['createdAt'], isA<Timestamp>());
        expect((data['createdAt'] as Timestamp).toDate(), equals(createdAt));
      });

      test('toFirestore handles null fields', () {
        final createdAt = DateTime.now();
        final gift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: createdAt,
        );

        final data = gift.toFirestore();

        expect(data['childId'], equals('child-id'));
        expect(data['gifterName'], isNull);
        expect(data['gifterEmail'], isNull);
        expect(data['message'], isNull);
        expect(data['amountCents'], equals(2500));
        expect(data['stripePaymentIntent'], equals('pi_test123'));
        expect(data['status'], equals('pending'));
        expect(data['createdAt'], isA<Timestamp>());
      });

      test('fromFirestore creates Gift from document', () async {
        final createdAt = DateTime.now();
        final docData = {
          'childId': 'child-id',
          'gifterName': 'John Doe',
          'gifterEmail': 'john@example.com',
          'message': 'Happy birthday!',
          'amountCents': 2500,
          'stripePaymentIntent': 'pi_test123',
          'status': 'succeeded',
          'createdAt': Timestamp.fromDate(createdAt),
        };

        await fakeFirestore.collection('gifts').doc('gift-id').set(docData);
        final doc = await fakeFirestore.collection('gifts').doc('gift-id').get();

        final gift = Gift.fromFirestore(doc);

        expect(gift.id, equals('gift-id'));
        expect(gift.childId, equals('child-id'));
        expect(gift.gifterName, equals('John Doe'));
        expect(gift.gifterEmail, equals('john@example.com'));
        expect(gift.message, equals('Happy birthday!'));
        expect(gift.amountCents, equals(2500));
        expect(gift.stripePaymentIntent, equals('pi_test123'));
        expect(gift.status, equals(GiftStatus.succeeded));
        expect(gift.createdAt, equals(createdAt));
      });

      test('fromFirestore handles null optional fields', () async {
        final createdAt = DateTime.now();
        final docData = {
          'childId': 'child-id',
          'amountCents': 2500,
          'stripePaymentIntent': 'pi_test123',
          'createdAt': Timestamp.fromDate(createdAt),
        };

        await fakeFirestore.collection('gifts').doc('gift-id').set(docData);
        final doc = await fakeFirestore.collection('gifts').doc('gift-id').get();

        final gift = Gift.fromFirestore(doc);

        expect(gift.id, equals('gift-id'));
        expect(gift.childId, equals('child-id'));
        expect(gift.gifterName, isNull);
        expect(gift.gifterEmail, isNull);
        expect(gift.message, isNull);
        expect(gift.amountCents, equals(2500));
        expect(gift.stripePaymentIntent, equals('pi_test123'));
        expect(gift.status, equals(GiftStatus.pending));
        expect(gift.createdAt, equals(createdAt));
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final originalGift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: 'John Doe',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.pending,
          createdAt: DateTime.now(),
        );

        final updatedGift = originalGift.copyWith(
          gifterName: 'Jane Doe',
          amountCents: 5000,
          status: GiftStatus.succeeded,
        );

        expect(updatedGift.id, equals('gift-id'));
        expect(updatedGift.childId, equals('child-id'));
        expect(updatedGift.gifterName, equals('Jane Doe'));
        expect(updatedGift.amountCents, equals(5000));
        expect(updatedGift.stripePaymentIntent, equals('pi_test123'));
        expect(updatedGift.status, equals(GiftStatus.succeeded));
        expect(updatedGift.createdAt, equals(originalGift.createdAt));
      });

      test('creates copy with same fields when no changes', () {
        final originalGift = Gift(
          id: 'gift-id',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: DateTime.now(),
        );

        final copiedGift = originalGift.copyWith();

        expect(copiedGift, equals(originalGift));
      });
    });

    group('Equality', () {
      test('gifts with same properties are equal', () {
        final createdAt = DateTime.now();
        final gift1 = Gift(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: 'John Doe',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.succeeded,
          createdAt: createdAt,
        );

        final gift2 = Gift(
          id: 'gift-id',
          childId: 'child-id',
          gifterName: 'John Doe',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          status: GiftStatus.succeeded,
          createdAt: createdAt,
        );

        expect(gift1, equals(gift2));
        expect(gift1.hashCode, equals(gift2.hashCode));
      });

      test('gifts with different properties are not equal', () {
        final createdAt = DateTime.now();
        final gift1 = Gift(
          id: 'gift-id-1',
          childId: 'child-id',
          amountCents: 2500,
          stripePaymentIntent: 'pi_test123',
          createdAt: createdAt,
        );

        final gift2 = Gift(
          id: 'gift-id-2',
          childId: 'child-id',
          amountCents: 5000,
          stripePaymentIntent: 'pi_test456',
          createdAt: createdAt,
        );

        expect(gift1, isNot(equals(gift2)));
      });
    });
  });
}