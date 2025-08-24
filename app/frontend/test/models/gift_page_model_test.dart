import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../lib/models/gift_page_model.dart';

void main() {
  group('GiftPageTheme', () {
    test('has correct values', () {
      expect(GiftPageTheme.defaultTheme.value, equals('default'));
      expect(GiftPageTheme.soft.value, equals('soft'));
      expect(GiftPageTheme.bold.value, equals('bold'));
    });

    test('fromString returns correct theme', () {
      expect(GiftPageTheme.fromString('default'), equals(GiftPageTheme.defaultTheme));
      expect(GiftPageTheme.fromString('soft'), equals(GiftPageTheme.soft));
      expect(GiftPageTheme.fromString('bold'), equals(GiftPageTheme.bold));
    });

    test('fromString returns default for unknown value', () {
      expect(GiftPageTheme.fromString('unknown'), equals(GiftPageTheme.defaultTheme));
      expect(GiftPageTheme.fromString(''), equals(GiftPageTheme.defaultTheme));
    });
  });

  group('GiftPage Model', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('Constructor', () {
      test('creates GiftPage with required fields', () {
        const giftPage = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
        );

        expect(giftPage.id, equals('page-id'));
        expect(giftPage.childId, equals('child-id'));
        expect(giftPage.headline, equals('Help John\'s RESP grow'));
        expect(giftPage.blurb, equals('Instead of toys, help John save for education.'));
        expect(giftPage.theme, equals(GiftPageTheme.defaultTheme));
        expect(giftPage.isPublic, isFalse);
      });

      test('creates GiftPage with all fields', () {
        const giftPage = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
          theme: GiftPageTheme.soft,
          isPublic: true,
        );

        expect(giftPage.id, equals('page-id'));
        expect(giftPage.childId, equals('child-id'));
        expect(giftPage.headline, equals('Help John\'s RESP grow'));
        expect(giftPage.blurb, equals('Instead of toys, help John save for education.'));
        expect(giftPage.theme, equals(GiftPageTheme.soft));
        expect(giftPage.isPublic, isTrue);
      });
    });

    group('Firestore Serialization', () {
      test('toFirestore converts GiftPage to Map', () {
        const giftPage = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
          theme: GiftPageTheme.bold,
          isPublic: true,
        );

        final data = giftPage.toFirestore();

        expect(data['childId'], equals('child-id'));
        expect(data['headline'], equals('Help John\'s RESP grow'));
        expect(data['blurb'], equals('Instead of toys, help John save for education.'));
        expect(data['theme'], equals('bold'));
        expect(data['isPublic'], isTrue);
      });

      test('toFirestore handles default values', () {
        const giftPage = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
        );

        final data = giftPage.toFirestore();

        expect(data['theme'], equals('default'));
        expect(data['isPublic'], isFalse);
      });

      test('fromFirestore creates GiftPage from document', () async {
        final docData = {
          'childId': 'child-id',
          'headline': 'Help John\'s RESP grow',
          'blurb': 'Instead of toys, help John save for education.',
          'theme': 'soft',
          'isPublic': true,
        };

        await fakeFirestore.collection('giftPages').doc('page-id').set(docData);
        final doc = await fakeFirestore.collection('giftPages').doc('page-id').get();

        final giftPage = GiftPage.fromFirestore(doc);

        expect(giftPage.id, equals('page-id'));
        expect(giftPage.childId, equals('child-id'));
        expect(giftPage.headline, equals('Help John\'s RESP grow'));
        expect(giftPage.blurb, equals('Instead of toys, help John save for education.'));
        expect(giftPage.theme, equals(GiftPageTheme.soft));
        expect(giftPage.isPublic, isTrue);
      });

      test('fromFirestore handles null optional fields', () async {
        final docData = {
          'childId': 'child-id',
          'headline': 'Help John\'s RESP grow',
          'blurb': 'Instead of toys, help John save for education.',
        };

        await fakeFirestore.collection('giftPages').doc('page-id').set(docData);
        final doc = await fakeFirestore.collection('giftPages').doc('page-id').get();

        final giftPage = GiftPage.fromFirestore(doc);

        expect(giftPage.id, equals('page-id'));
        expect(giftPage.childId, equals('child-id'));
        expect(giftPage.headline, equals('Help John\'s RESP grow'));
        expect(giftPage.blurb, equals('Instead of toys, help John save for education.'));
        expect(giftPage.theme, equals(GiftPageTheme.defaultTheme));
        expect(giftPage.isPublic, isFalse);
      });

      test('fromFirestore handles unknown theme', () async {
        final docData = {
          'childId': 'child-id',
          'headline': 'Help John\'s RESP grow',
          'blurb': 'Instead of toys, help John save for education.',
          'theme': 'unknown-theme',
          'isPublic': false,
        };

        await fakeFirestore.collection('giftPages').doc('page-id').set(docData);
        final doc = await fakeFirestore.collection('giftPages').doc('page-id').get();

        final giftPage = GiftPage.fromFirestore(doc);

        expect(giftPage.theme, equals(GiftPageTheme.defaultTheme));
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const originalPage = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Original Headline',
          blurb: 'Original blurb',
          theme: GiftPageTheme.defaultTheme,
          isPublic: false,
        );

        final updatedPage = originalPage.copyWith(
          headline: 'Updated Headline',
          theme: GiftPageTheme.bold,
          isPublic: true,
        );

        expect(updatedPage.id, equals('page-id'));
        expect(updatedPage.childId, equals('child-id'));
        expect(updatedPage.headline, equals('Updated Headline'));
        expect(updatedPage.blurb, equals('Original blurb'));
        expect(updatedPage.theme, equals(GiftPageTheme.bold));
        expect(updatedPage.isPublic, isTrue);
      });

      test('creates copy with same fields when no changes', () {
        const originalPage = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
        );

        final copiedPage = originalPage.copyWith();

        expect(copiedPage, equals(originalPage));
      });
    });

    group('Equality', () {
      test('gift pages with same properties are equal', () {
        const page1 = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
          theme: GiftPageTheme.soft,
          isPublic: true,
        );

        const page2 = GiftPage(
          id: 'page-id',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
          theme: GiftPageTheme.soft,
          isPublic: true,
        );

        expect(page1, equals(page2));
        expect(page1.hashCode, equals(page2.hashCode));
      });

      test('gift pages with different properties are not equal', () {
        const page1 = GiftPage(
          id: 'page-id-1',
          childId: 'child-id',
          headline: 'Help John\'s RESP grow',
          blurb: 'Instead of toys, help John save for education.',
        );

        const page2 = GiftPage(
          id: 'page-id-2',
          childId: 'child-id',
          headline: 'Help Jane\'s RESP grow',
          blurb: 'Instead of toys, help Jane save for education.',
        );

        expect(page1, isNot(equals(page2)));
      });
    });
  });
}