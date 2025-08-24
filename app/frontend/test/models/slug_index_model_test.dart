import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../lib/models/slug_index_model.dart';

void main() {
  group('SlugIndex Model', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('Constructor', () {
      test('creates SlugIndex with required fields', () {
        const slugIndex = SlugIndex(
          slug: 'john-doe',
          childId: 'child-id-123',
        );

        expect(slugIndex.slug, equals('john-doe'));
        expect(slugIndex.childId, equals('child-id-123'));
      });
    });

    group('Firestore Serialization', () {
      test('toFirestore converts SlugIndex to Map', () {
        const slugIndex = SlugIndex(
          slug: 'john-doe',
          childId: 'child-id-123',
        );

        final data = slugIndex.toFirestore();

        expect(data['childId'], equals('child-id-123'));
        expect(data.length, equals(1)); // Only childId should be stored
      });

      test('fromFirestore creates SlugIndex from document', () async {
        final docData = {
          'childId': 'child-id-123',
        };

        await fakeFirestore.collection('slugIndex').doc('john-doe').set(docData);
        final doc = await fakeFirestore.collection('slugIndex').doc('john-doe').get();

        final slugIndex = SlugIndex.fromFirestore(doc);

        expect(slugIndex.slug, equals('john-doe'));
        expect(slugIndex.childId, equals('child-id-123'));
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const originalSlugIndex = SlugIndex(
          slug: 'john-doe',
          childId: 'child-id-123',
        );

        final updatedSlugIndex = originalSlugIndex.copyWith(
          slug: 'jane-doe',
          childId: 'child-id-456',
        );

        expect(updatedSlugIndex.slug, equals('jane-doe'));
        expect(updatedSlugIndex.childId, equals('child-id-456'));
      });

      test('creates copy with same fields when no changes', () {
        const originalSlugIndex = SlugIndex(
          slug: 'john-doe',
          childId: 'child-id-123',
        );

        final copiedSlugIndex = originalSlugIndex.copyWith();

        expect(copiedSlugIndex, equals(originalSlugIndex));
      });
    });

    group('Equality', () {
      test('slug indexes with same properties are equal', () {
        const slugIndex1 = SlugIndex(
          slug: 'john-doe',
          childId: 'child-id-123',
        );

        const slugIndex2 = SlugIndex(
          slug: 'john-doe',
          childId: 'child-id-123',
        );

        expect(slugIndex1, equals(slugIndex2));
        expect(slugIndex1.hashCode, equals(slugIndex2.hashCode));
      });

      test('slug indexes with different properties are not equal', () {
        const slugIndex1 = SlugIndex(
          slug: 'john-doe',
          childId: 'child-id-123',
        );

        const slugIndex2 = SlugIndex(
          slug: 'jane-doe',
          childId: 'child-id-456',
        );

        expect(slugIndex1, isNot(equals(slugIndex2)));
      });
    });

    group('Edge Cases', () {
      test('handles empty slug', () {
        const slugIndex = SlugIndex(
          slug: '',
          childId: 'child-id-123',
        );

        expect(slugIndex.slug, equals(''));
        expect(slugIndex.childId, equals('child-id-123'));
      });

      test('handles special characters in slug', () {
        const slugIndex = SlugIndex(
          slug: 'john-o-connor-2',
          childId: 'child-id-123',
        );

        expect(slugIndex.slug, equals('john-o-connor-2'));
        expect(slugIndex.childId, equals('child-id-123'));
      });
    });
  });
}