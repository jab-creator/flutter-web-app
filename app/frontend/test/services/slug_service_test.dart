import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:resp_gift_app/services/slug_service.dart';

void main() {
  group('SlugService', () {
    late SlugService slugService;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      slugService = SlugService(firestore: fakeFirestore);
    });

    tearDown(() {
      slugService.dispose();
    });

    group('generateBaseSlug', () {
      test('should generate valid slug from first name', () {
        expect(slugService.generateBaseSlug('John'), equals('john'));
        expect(slugService.generateBaseSlug('Mary Jane'), equals('maryjane'));
        expect(slugService.generateBaseSlug('José'), equals('jos'));
        expect(slugService.generateBaseSlug('O\'Connor'), equals('oconnor'));
      });

      test('should handle empty or invalid input', () {
        expect(slugService.generateBaseSlug(''), equals(''));
        expect(slugService.generateBaseSlug('123'), equals('123'));
      });
    });

    group('isValidSlugFormat', () {
      test('should return true for valid slug formats', () {
        expect(slugService.isValidSlugFormat('john'), isTrue);
        expect(slugService.isValidSlugFormat('mary-jane'), isTrue);
        expect(slugService.isValidSlugFormat('child123'), isTrue);
        expect(slugService.isValidSlugFormat('a-b-c-d'), isTrue);
      });

      test('should return false for invalid slug formats', () {
        expect(slugService.isValidSlugFormat(''), isFalse);
        expect(slugService.isValidSlugFormat('a'), isFalse); // too short
        expect(slugService.isValidSlugFormat('John'), isFalse); // uppercase
        expect(slugService.isValidSlugFormat('john_doe'), isFalse); // underscore
        expect(slugService.isValidSlugFormat('john doe'), isFalse); // space
        expect(slugService.isValidSlugFormat('-john'), isFalse); // starts with hyphen
        expect(slugService.isValidSlugFormat('john-'), isFalse); // ends with hyphen
        expect(slugService.isValidSlugFormat('john--doe'), isFalse); // consecutive hyphens
      });
    });

    group('isSlugAvailable', () {
      test('should return true for available slugs', () async {
        final isAvailable = await slugService.isSlugAvailable('available-slug');
        expect(isAvailable, isTrue);
      });

      test('should return false for taken slugs', () async {
        // Add a slug to the fake firestore
        await fakeFirestore.collection('slugIndex').doc('taken-slug').set({
          'childId': 'child123',
        });

        final isAvailable = await slugService.isSlugAvailable('taken-slug');
        expect(isAvailable, isFalse);
      });

      test('should return false for invalid slug formats', () async {
        final isAvailable = await slugService.isSlugAvailable('Invalid-Slug');
        expect(isAvailable, isFalse);
      });
    });

    group('generateUniqueSlug', () {
      test('should return base slug if available', () async {
        final uniqueSlug = await slugService.generateUniqueSlug('John');
        expect(uniqueSlug, equals('john'));
      });

      test('should append number if base slug is taken', () async {
        // Add base slug to firestore
        await fakeFirestore.collection('slugIndex').doc('john').set({
          'childId': 'child123',
        });

        final uniqueSlug = await slugService.generateUniqueSlug('John');
        expect(uniqueSlug, equals('john1'));
      });

      test('should increment number until unique slug is found', () async {
        // Add multiple slugs to firestore
        await fakeFirestore.collection('slugIndex').doc('john').set({
          'childId': 'child123',
        });
        await fakeFirestore.collection('slugIndex').doc('john1').set({
          'childId': 'child124',
        });
        await fakeFirestore.collection('slugIndex').doc('john2').set({
          'childId': 'child125',
        });

        final uniqueSlug = await slugService.generateUniqueSlug('John');
        expect(uniqueSlug, equals('john3'));
      });
    });

    group('suggestAlternativeSlugs', () {
      test('should return original slug if available', () async {
        final suggestions = await slugService.suggestAlternativeSlugs('available');
        expect(suggestions, contains('available'));
      });

      test('should suggest alternatives if slug is taken', () async {
        // Add base slug to firestore
        await fakeFirestore.collection('slugIndex').doc('taken').set({
          'childId': 'child123',
        });

        final suggestions = await slugService.suggestAlternativeSlugs('taken');
        expect(suggestions, isNotEmpty);
        expect(suggestions, contains('taken1'));
      });
    });

    group('clearCache', () {
      test('should clear the availability cache', () async {
        // First call to populate cache
        await slugService.isSlugAvailable('test-slug');
        
        // Clear cache
        slugService.clearCache();
        
        // This should work without errors
        await slugService.isSlugAvailable('test-slug');
      });
    });
  });
}