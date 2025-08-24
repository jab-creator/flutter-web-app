import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../lib/models/child_model.dart';

void main() {
  group('Child Model', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('Constructor', () {
      test('creates Child with required fields', () {
        final createdAt = DateTime.now();
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: createdAt,
        );

        expect(child.id, equals('child-id'));
        expect(child.userId, equals('user-id'));
        expect(child.firstName, equals('John'));
        expect(child.lastName, isNull);
        expect(child.dob, isNull);
        expect(child.slug, equals('john'));
        expect(child.heroPhotoUrl, isNull);
        expect(child.goalCad, isNull);
        expect(child.createdAt, equals(createdAt));
      });

      test('creates Child with all fields', () {
        final createdAt = DateTime.now();
        final dob = DateTime(2020, 1, 1);
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          lastName: 'Doe',
          dob: dob,
          slug: 'john-doe',
          heroPhotoUrl: 'https://example.com/photo.jpg',
          goalCad: 5000.0,
          createdAt: createdAt,
        );

        expect(child.id, equals('child-id'));
        expect(child.userId, equals('user-id'));
        expect(child.firstName, equals('John'));
        expect(child.lastName, equals('Doe'));
        expect(child.dob, equals(dob));
        expect(child.slug, equals('john-doe'));
        expect(child.heroPhotoUrl, equals('https://example.com/photo.jpg'));
        expect(child.goalCad, equals(5000.0));
        expect(child.createdAt, equals(createdAt));
      });
    });

    group('Display Names', () {
      test('fullName returns first name only when no last name', () {
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: DateTime.now(),
        );

        expect(child.fullName, equals('John'));
      });

      test('fullName returns first and last name when both provided', () {
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          lastName: 'Doe',
          slug: 'john-doe',
          createdAt: DateTime.now(),
        );

        expect(child.fullName, equals('John Doe'));
      });

      test('fullName returns first name when last name is empty', () {
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          lastName: '',
          slug: 'john',
          createdAt: DateTime.now(),
        );

        expect(child.fullName, equals('John'));
      });

      test('displayName always returns first name', () {
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          lastName: 'Doe',
          slug: 'john-doe',
          createdAt: DateTime.now(),
        );

        expect(child.displayName, equals('John'));
      });
    });

    group('Slug Generation', () {
      test('generateBaseSlug creates lowercase slug from first name', () {
        expect(Child.generateBaseSlug('John'), equals('john'));
        expect(Child.generateBaseSlug('MARY'), equals('mary'));
        expect(Child.generateBaseSlug('Anna-Belle'), equals('annabelle'));
      });

      test('generateBaseSlug removes special characters', () {
        expect(Child.generateBaseSlug('José'), equals('jos'));
        expect(Child.generateBaseSlug('Mary-Jane'), equals('maryjane'));
        expect(Child.generateBaseSlug('O\'Connor'), equals('oconnor'));
      });

      test('generateBaseSlug removes spaces', () {
        expect(Child.generateBaseSlug('John Paul'), equals('johnpaul'));
        expect(Child.generateBaseSlug('Mary  Jane'), equals('maryjane'));
      });

      test('generateBaseSlug handles numbers', () {
        expect(Child.generateBaseSlug('John2'), equals('john2'));
        expect(Child.generateBaseSlug('Mary123'), equals('mary123'));
      });
    });

    group('Firestore Serialization', () {
      test('toFirestore converts Child to Map', () {
        final createdAt = DateTime.now();
        final dob = DateTime(2020, 1, 1);
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          lastName: 'Doe',
          dob: dob,
          slug: 'john-doe',
          heroPhotoUrl: 'https://example.com/photo.jpg',
          goalCad: 5000.0,
          createdAt: createdAt,
        );

        final data = child.toFirestore();

        expect(data['userId'], equals('user-id'));
        expect(data['firstName'], equals('John'));
        expect(data['lastName'], equals('Doe'));
        expect(data['dob'], isA<Timestamp>());
        expect((data['dob'] as Timestamp).toDate(), equals(dob));
        expect(data['slug'], equals('john-doe'));
        expect(data['heroPhotoUrl'], equals('https://example.com/photo.jpg'));
        expect(data['goalCad'], equals(5000.0));
        expect(data['createdAt'], isA<Timestamp>());
        expect((data['createdAt'] as Timestamp).toDate(), equals(createdAt));
      });

      test('toFirestore handles null fields', () {
        final createdAt = DateTime.now();
        final child = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: createdAt,
        );

        final data = child.toFirestore();

        expect(data['userId'], equals('user-id'));
        expect(data['firstName'], equals('John'));
        expect(data['lastName'], isNull);
        expect(data['dob'], isNull);
        expect(data['slug'], equals('john'));
        expect(data['heroPhotoUrl'], isNull);
        expect(data['goalCad'], isNull);
        expect(data['createdAt'], isA<Timestamp>());
      });

      test('fromFirestore creates Child from document', () async {
        final createdAt = DateTime.now();
        final dob = DateTime(2020, 1, 1);
        final docData = {
          'userId': 'user-id',
          'firstName': 'John',
          'lastName': 'Doe',
          'dob': Timestamp.fromDate(dob),
          'slug': 'john-doe',
          'heroPhotoUrl': 'https://example.com/photo.jpg',
          'goalCad': 5000.0,
          'createdAt': Timestamp.fromDate(createdAt),
        };

        await fakeFirestore.collection('children').doc('child-id').set(docData);
        final doc = await fakeFirestore.collection('children').doc('child-id').get();

        final child = Child.fromFirestore(doc);

        expect(child.id, equals('child-id'));
        expect(child.userId, equals('user-id'));
        expect(child.firstName, equals('John'));
        expect(child.lastName, equals('Doe'));
        expect(child.dob, equals(dob));
        expect(child.slug, equals('john-doe'));
        expect(child.heroPhotoUrl, equals('https://example.com/photo.jpg'));
        expect(child.goalCad, equals(5000.0));
        expect(child.createdAt, equals(createdAt));
      });

      test('fromFirestore handles null optional fields', () async {
        final createdAt = DateTime.now();
        final docData = {
          'userId': 'user-id',
          'firstName': 'John',
          'slug': 'john',
          'createdAt': Timestamp.fromDate(createdAt),
        };

        await fakeFirestore.collection('children').doc('child-id').set(docData);
        final doc = await fakeFirestore.collection('children').doc('child-id').get();

        final child = Child.fromFirestore(doc);

        expect(child.id, equals('child-id'));
        expect(child.userId, equals('user-id'));
        expect(child.firstName, equals('John'));
        expect(child.lastName, isNull);
        expect(child.dob, isNull);
        expect(child.slug, equals('john'));
        expect(child.heroPhotoUrl, isNull);
        expect(child.goalCad, isNull);
        expect(child.createdAt, equals(createdAt));
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final originalChild = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: DateTime.now(),
        );

        final updatedChild = originalChild.copyWith(
          firstName: 'Jane',
          lastName: 'Doe',
          slug: 'jane-doe',
        );

        expect(updatedChild.id, equals('child-id'));
        expect(updatedChild.userId, equals('user-id'));
        expect(updatedChild.firstName, equals('Jane'));
        expect(updatedChild.lastName, equals('Doe'));
        expect(updatedChild.slug, equals('jane-doe'));
        expect(updatedChild.createdAt, equals(originalChild.createdAt));
      });

      test('creates copy with same fields when no changes', () {
        final originalChild = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: DateTime.now(),
        );

        final copiedChild = originalChild.copyWith();

        expect(copiedChild, equals(originalChild));
      });
    });

    group('Equality', () {
      test('children with same properties are equal', () {
        final createdAt = DateTime.now();
        final child1 = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: createdAt,
        );

        final child2 = Child(
          id: 'child-id',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: createdAt,
        );

        expect(child1, equals(child2));
        expect(child1.hashCode, equals(child2.hashCode));
      });

      test('children with different properties are not equal', () {
        final createdAt = DateTime.now();
        final child1 = Child(
          id: 'child-id-1',
          userId: 'user-id',
          firstName: 'John',
          slug: 'john',
          createdAt: createdAt,
        );

        final child2 = Child(
          id: 'child-id-2',
          userId: 'user-id',
          firstName: 'Jane',
          slug: 'jane',
          createdAt: createdAt,
        );

        expect(child1, isNot(equals(child2)));
      });
    });
  });
}