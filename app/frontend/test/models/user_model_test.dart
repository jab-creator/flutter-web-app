import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';

import '../../lib/models/user_model.dart';

class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

void main() {
  group('User Model', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('Constructor', () {
      test('creates User with required fields', () {
        const user = User(
          id: 'test-id',
          email: 'test@example.com',
        );

        expect(user.id, equals('test-id'));
        expect(user.email, equals('test@example.com'));
        expect(user.fullName, isNull);
        expect(user.displayName, isNull);
        expect(user.photoURL, isNull);
        expect(user.emailVerified, isFalse);
        expect(user.createdAt, isNull);
        expect(user.lastSignInAt, isNull);
      });

      test('creates User with all fields', () {
        final createdAt = DateTime.now();
        final lastSignInAt = DateTime.now();

        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          fullName: 'Test User',
          displayName: 'Test',
          photoURL: 'https://example.com/photo.jpg',
          emailVerified: true,
          createdAt: createdAt,
          lastSignInAt: lastSignInAt,
        );

        expect(user.id, equals('test-id'));
        expect(user.email, equals('test@example.com'));
        expect(user.fullName, equals('Test User'));
        expect(user.displayName, equals('Test'));
        expect(user.photoURL, equals('https://example.com/photo.jpg'));
        expect(user.emailVerified, isTrue);
        expect(user.createdAt, equals(createdAt));
        expect(user.lastSignInAt, equals(lastSignInAt));
      });
    });

    group('Empty User', () {
      test('empty user has correct properties', () {
        expect(User.empty.id, equals(''));
        expect(User.empty.email, equals(''));
        expect(User.empty.isEmpty, isTrue);
        expect(User.empty.isNotEmpty, isFalse);
      });

      test('non-empty user has correct properties', () {
        const user = User(id: 'test-id', email: 'test@example.com');
        expect(user.isEmpty, isFalse);
        expect(user.isNotEmpty, isTrue);
      });
    });

    group('fromFirebaseUser', () {
      test('creates User from Firebase User', () {
        final mockUser = MockFirebaseUser();
        final mockMetadata = MockUserMetadata();
        final createdAt = DateTime.now();
        final lastSignInAt = DateTime.now();

        when(() => mockUser.uid).thenReturn('firebase-uid');
        when(() => mockUser.email).thenReturn('firebase@example.com');
        when(() => mockUser.displayName).thenReturn('Firebase User');
        when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(createdAt);
        when(() => mockMetadata.lastSignInTime).thenReturn(lastSignInAt);

        final user = User.fromFirebaseUser(mockUser);

        expect(user.id, equals('firebase-uid'));
        expect(user.email, equals('firebase@example.com'));
        expect(user.fullName, equals('Firebase User'));
        expect(user.displayName, equals('Firebase User'));
        expect(user.photoURL, equals('https://example.com/photo.jpg'));
        expect(user.emailVerified, isTrue);
        expect(user.createdAt, equals(createdAt));
        expect(user.lastSignInAt, equals(lastSignInAt));
      });

      test('handles null email from Firebase User', () {
        final mockUser = MockFirebaseUser();
        final mockMetadata = MockUserMetadata();

        when(() => mockUser.uid).thenReturn('firebase-uid');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(false);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(null);
        when(() => mockMetadata.lastSignInTime).thenReturn(null);

        final user = User.fromFirebaseUser(mockUser);

        expect(user.id, equals('firebase-uid'));
        expect(user.email, equals(''));
        expect(user.fullName, isNull);
        expect(user.displayName, isNull);
        expect(user.photoURL, isNull);
        expect(user.emailVerified, isFalse);
        expect(user.createdAt, isNull);
        expect(user.lastSignInAt, isNull);
      });
    });

    group('Firestore Serialization', () {
      test('toFirestore converts User to Map', () {
        final createdAt = DateTime.now();
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          fullName: 'Test User',
          createdAt: createdAt,
        );

        final data = user.toFirestore();

        expect(data['email'], equals('test@example.com'));
        expect(data['fullName'], equals('Test User'));
        expect(data['createdAt'], isA<Timestamp>());
        expect((data['createdAt'] as Timestamp).toDate(), equals(createdAt));
      });

      test('toFirestore handles null fullName', () {
        const user = User(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Display Name',
        );

        final data = user.toFirestore();

        expect(data['email'], equals('test@example.com'));
        expect(data['fullName'], equals('Display Name'));
        expect(data['createdAt'], isA<FieldValue>());
      });

      test('toFirestore handles null createdAt with server timestamp', () {
        const user = User(
          id: 'test-id',
          email: 'test@example.com',
        );

        final data = user.toFirestore();

        expect(data['createdAt'], isA<FieldValue>());
      });

      test('fromFirestore creates User from document', () async {
        final createdAt = DateTime.now();
        final docData = {
          'email': 'firestore@example.com',
          'fullName': 'Firestore User',
          'createdAt': Timestamp.fromDate(createdAt),
        };

        await fakeFirestore.collection('users').doc('doc-id').set(docData);
        final doc = await fakeFirestore.collection('users').doc('doc-id').get();

        final user = User.fromFirestore(doc);

        expect(user.id, equals('doc-id'));
        expect(user.email, equals('firestore@example.com'));
        expect(user.fullName, equals('Firestore User'));
        expect(user.displayName, equals('Firestore User'));
        expect(user.createdAt, equals(createdAt));
      });

      test('fromFirestore handles null fields', () async {
        final docData = {
          'email': 'minimal@example.com',
        };

        await fakeFirestore.collection('users').doc('doc-id').set(docData);
        final doc = await fakeFirestore.collection('users').doc('doc-id').get();

        final user = User.fromFirestore(doc);

        expect(user.id, equals('doc-id'));
        expect(user.email, equals('minimal@example.com'));
        expect(user.fullName, isNull);
        expect(user.displayName, isNull);
        expect(user.createdAt, isNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const originalUser = User(
          id: 'original-id',
          email: 'original@example.com',
          fullName: 'Original Name',
        );

        final updatedUser = originalUser.copyWith(
          email: 'updated@example.com',
          fullName: 'Updated Name',
        );

        expect(updatedUser.id, equals('original-id'));
        expect(updatedUser.email, equals('updated@example.com'));
        expect(updatedUser.fullName, equals('Updated Name'));
      });

      test('creates copy with same fields when no changes', () {
        const originalUser = User(
          id: 'original-id',
          email: 'original@example.com',
        );

        final copiedUser = originalUser.copyWith();

        expect(copiedUser.id, equals(originalUser.id));
        expect(copiedUser.email, equals(originalUser.email));
        expect(copiedUser, equals(originalUser));
      });
    });

    group('Equality', () {
      test('users with same properties are equal', () {
        const user1 = User(
          id: 'test-id',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        const user2 = User(
          id: 'test-id',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('users with different properties are not equal', () {
        const user1 = User(
          id: 'test-id-1',
          email: 'test1@example.com',
        );

        const user2 = User(
          id: 'test-id-2',
          email: 'test2@example.com',
        );

        expect(user1, isNot(equals(user2)));
      });
    });
  });
}