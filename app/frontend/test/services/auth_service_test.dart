import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';
import 'package:resp_gift_app/services/auth_service.dart';
import 'package:resp_gift_app/models/user_model.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

void main() {
  group('AuthService', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseUser mockFirebaseUser;
    late MockUserCredential mockUserCredential;
    late MockUserMetadata mockUserMetadata;
    late AuthService authService;

    const String testEmail = 'test@example.com';
    const String testPassword = 'password123';
    const String testUserId = 'test-user-id';
    const String testDisplayName = 'Test User';

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirebaseUser = MockFirebaseUser();
      mockUserCredential = MockUserCredential();
      mockUserMetadata = MockUserMetadata();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      // Setup mock user
      when(() => mockFirebaseUser.uid).thenReturn(testUserId);
      when(() => mockFirebaseUser.email).thenReturn(testEmail);
      when(() => mockFirebaseUser.displayName).thenReturn(testDisplayName);
      when(() => mockFirebaseUser.photoURL).thenReturn(null);
      when(() => mockFirebaseUser.emailVerified).thenReturn(true);
      when(() => mockFirebaseUser.metadata).thenReturn(mockUserMetadata);
      when(() => mockUserMetadata.creationTime).thenReturn(DateTime.now());
      when(() => mockUserMetadata.lastSignInTime).thenReturn(DateTime.now());
    });

    group('user stream', () {
      test('emits User.empty when firebase user is null', () {
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        expect(
          authService.user,
          emits(User.empty),
        );
      });

      test('emits User when firebase user is not null', () {
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockFirebaseUser));

        final expectedUser = User(
          id: testUserId,
          email: testEmail,
          displayName: testDisplayName,
          emailVerified: true,
          createdAt: mockUserMetadata.creationTime,
          lastSignInAt: mockUserMetadata.lastSignInTime,
        );

        expect(
          authService.user,
          emits(expectedUser),
        );
      });
    });

    group('currentUser', () {
      test('returns User.empty when no current user', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(authService.currentUser, equals(User.empty));
      });

      test('returns User when current user exists', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);

        final result = authService.currentUser;

        expect(result.id, equals(testUserId));
        expect(result.email, equals(testEmail));
        expect(result.displayName, equals(testDisplayName));
      });
    });

    group('signUp', () {
      test('calls createUserWithEmailAndPassword', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockUserCredential);

        await authService.signUp(email: testEmail, password: testPassword);

        verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });

      test('throws SignUpWithEmailAndPasswordFailure on FirebaseAuthException',
          () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'weak-password'),
        );

        expect(
          () async => authService.signUp(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<SignUpWithEmailAndPasswordFailure>()),
        );
      });

      test('throws SignUpWithEmailAndPasswordFailure on generic exception',
          () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Generic error'));

        expect(
          () async => authService.signUp(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<SignUpWithEmailAndPasswordFailure>()),
        );
      });
    });

    group('logInWithEmailAndPassword', () {
      test('calls signInWithEmailAndPassword', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockUserCredential);

        await authService.logInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });

      test('throws LogInWithEmailAndPasswordFailure on FirebaseAuthException',
          () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'user-not-found'),
        );

        expect(
          () async => authService.logInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<LogInWithEmailAndPasswordFailure>()),
        );
      });

      test('throws LogInWithEmailAndPasswordFailure on generic exception',
          () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Generic error'));

        expect(
          () async => authService.logInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<LogInWithEmailAndPasswordFailure>()),
        );
      });
    });

    group('logOut', () {
      test('calls signOut', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        await authService.logOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('throws LogOutFailure on exception', () async {
        when(() => mockFirebaseAuth.signOut())
            .thenThrow(Exception('Sign out error'));

        expect(
          () async => authService.logOut(),
          throwsA(isA<LogOutFailure>()),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      test('calls sendPasswordResetEmail', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email'),
            )).thenAnswer((_) async {});

        await authService.sendPasswordResetEmail(email: testEmail);

        verify(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: testEmail,
            )).called(1);
      });

      test('throws LogInWithEmailAndPasswordFailure on FirebaseAuthException',
          () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email'),
            )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'user-not-found'),
        );

        expect(
          () async => authService.sendPasswordResetEmail(email: testEmail),
          throwsA(isA<LogInWithEmailAndPasswordFailure>()),
        );
      });

      test('throws LogInWithEmailAndPasswordFailure on generic exception',
          () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email'),
            )).thenThrow(Exception('Generic error'));

        expect(
          () async => authService.sendPasswordResetEmail(email: testEmail),
          throwsA(isA<LogInWithEmailAndPasswordFailure>()),
        );
      });
    });
  });

  group('SignUpWithEmailAndPasswordFailure', () {
    test('creates correct message for known error codes', () {
      const testCases = {
        'invalid-email': 'Email is not valid or badly formatted.',
        'user-disabled':
            'This user has been disabled. Please contact support for help.',
        'email-already-in-use': 'An account already exists for that email.',
        'operation-not-allowed':
            'Operation is not allowed. Please contact support.',
        'weak-password': 'Please enter a stronger password.',
        'too-many-requests': 'Too many requests. Try again later.',
        'network-request-failed':
            'Network error occurred. Please check your connection.',
      };

      for (final entry in testCases.entries) {
        final failure = SignUpWithEmailAndPasswordFailure.fromCode(entry.key);
        expect(failure.message, equals(entry.value));
      }
    });

    test('creates default message for unknown error code', () {
      final failure =
          SignUpWithEmailAndPasswordFailure.fromCode('unknown-error');
      expect(failure.message, equals('An unknown exception occurred.'));
    });
  });

  group('LogInWithEmailAndPasswordFailure', () {
    test('creates correct message for known error codes', () {
      const testCases = {
        'invalid-email': 'Email is not valid or badly formatted.',
        'user-disabled':
            'This user has been disabled. Please contact support for help.',
        'user-not-found': 'Email is not found, please create an account.',
        'wrong-password': 'Incorrect password, please try again.',
        'invalid-credential':
            'The credential received is malformed or has expired.',
        'too-many-requests': 'Too many requests. Try again later.',
        'network-request-failed':
            'Network error occurred. Please check your connection.',
      };

      for (final entry in testCases.entries) {
        final failure = LogInWithEmailAndPasswordFailure.fromCode(entry.key);
        expect(failure.message, equals(entry.value));
      }
    });

    test('creates default message for unknown error code', () {
      final failure =
          LogInWithEmailAndPasswordFailure.fromCode('unknown-error');
      expect(failure.message, equals('An unknown exception occurred.'));
    });
  });
}
