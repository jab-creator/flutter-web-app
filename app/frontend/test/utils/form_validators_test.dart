import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/utils/form_validators.dart';

void main() {
  group('FormValidators', () {
    group('validateFirstName', () {
      test('should return null for valid first names', () {
        expect(FormValidators.validateFirstName('John'), isNull);
        expect(FormValidators.validateFirstName('Mary-Jane'), isNull);
        expect(FormValidators.validateFirstName("O'Connor"), isNull);
        expect(FormValidators.validateFirstName('José'), isNull);
      });

      test('should return error for empty or null names', () {
        expect(FormValidators.validateFirstName(null), isNotNull);
        expect(FormValidators.validateFirstName(''), isNotNull);
        expect(FormValidators.validateFirstName('   '), isNotNull);
      });

      test('should return error for names that are too short', () {
        expect(FormValidators.validateFirstName('A'), isNotNull);
      });

      test('should return error for names that are too long', () {
        final longName = 'A' * 51;
        expect(FormValidators.validateFirstName(longName), isNotNull);
      });

      test('should return error for names with invalid characters', () {
        expect(FormValidators.validateFirstName('John123'), isNotNull);
        expect(FormValidators.validateFirstName('John@'), isNotNull);
      });
    });

    group('validateSlug', () {
      test('should return null for valid slugs', () {
        expect(FormValidators.validateSlug('john'), isNull);
        expect(FormValidators.validateSlug('mary-jane'), isNull);
        expect(FormValidators.validateSlug('child123'), isNull);
      });

      test('should return error for empty or null slugs', () {
        expect(FormValidators.validateSlug(null), isNotNull);
        expect(FormValidators.validateSlug(''), isNotNull);
        expect(FormValidators.validateSlug('   '), isNotNull);
      });

      test('should return error for slugs that are too short', () {
        expect(FormValidators.validateSlug('a'), isNotNull);
      });

      test('should return error for slugs with invalid characters', () {
        expect(FormValidators.validateSlug('John'), isNotNull); // uppercase
        expect(FormValidators.validateSlug('john_doe'), isNotNull); // underscore
        expect(FormValidators.validateSlug('john doe'), isNotNull); // space
        expect(FormValidators.validateSlug('john@'), isNotNull); // special char
      });

      test('should return error for slugs starting or ending with hyphen', () {
        expect(FormValidators.validateSlug('-john'), isNotNull);
        expect(FormValidators.validateSlug('john-'), isNotNull);
      });

      test('should return error for slugs with consecutive hyphens', () {
        expect(FormValidators.validateSlug('john--doe'), isNotNull);
      });

      test('should return error for reserved words', () {
        expect(FormValidators.validateSlug('admin'), isNotNull);
        expect(FormValidators.validateSlug('api'), isNotNull);
        expect(FormValidators.validateSlug('login'), isNotNull);
      });
    });

    group('validateHeadline', () {
      test('should return null for valid headlines', () {
        expect(FormValidators.validateHeadline('Help Emma\'s RESP grow'), isNull);
        expect(FormValidators.validateHeadline('Support John\'s Education'), isNull);
      });

      test('should return error for empty headlines', () {
        expect(FormValidators.validateHeadline(null), isNotNull);
        expect(FormValidators.validateHeadline(''), isNotNull);
        expect(FormValidators.validateHeadline('   '), isNotNull);
      });

      test('should return error for headlines that are too short', () {
        expect(FormValidators.validateHeadline('Help'), isNotNull);
      });

      test('should return error for headlines that are too long', () {
        final longHeadline = 'A' * 101;
        expect(FormValidators.validateHeadline(longHeadline), isNotNull);
      });
    });

    group('validateBlurb', () {
      test('should return null for valid blurbs', () {
        expect(FormValidators.validateBlurb('This is a valid description for the gift page.'), isNull);
      });

      test('should return error for empty blurbs', () {
        expect(FormValidators.validateBlurb(null), isNotNull);
        expect(FormValidators.validateBlurb(''), isNotNull);
        expect(FormValidators.validateBlurb('   '), isNotNull);
      });

      test('should return error for blurbs that are too short', () {
        expect(FormValidators.validateBlurb('Too short'), isNotNull);
      });

      test('should return error for blurbs that are too long', () {
        final longBlurb = 'A' * 501;
        expect(FormValidators.validateBlurb(longBlurb), isNotNull);
      });
    });

    group('validateDateOfBirth', () {
      test('should return null for valid dates', () {
        final validDate = DateTime(2020, 1, 1);
        expect(FormValidators.validateDateOfBirth(validDate), isNull);
      });

      test('should return null for null date (optional field)', () {
        expect(FormValidators.validateDateOfBirth(null), isNull);
      });

      test('should return error for future dates', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        expect(FormValidators.validateDateOfBirth(futureDate), isNotNull);
      });

      test('should return error for dates more than 18 years ago', () {
        final tooOldDate = DateTime.now().subtract(const Duration(days: 365 * 19));
        expect(FormValidators.validateDateOfBirth(tooOldDate), isNotNull);
      });
    });

    group('formatName', () {
      test('should capitalize names correctly', () {
        expect(FormValidators.formatName('john'), equals('John'));
        expect(FormValidators.formatName('mary jane'), equals('Mary Jane'));
        expect(FormValidators.formatName('JOHN DOE'), equals('John Doe'));
        expect(FormValidators.formatName('  john  doe  '), equals('John Doe'));
      });

      test('should handle empty or null input', () {
        expect(FormValidators.formatName(null), equals(''));
        expect(FormValidators.formatName(''), equals(''));
        expect(FormValidators.formatName('   '), equals(''));
      });
    });

    group('formatSlug', () {
      test('should format slugs correctly', () {
        expect(FormValidators.formatSlug('John Doe'), equals('john-doe'));
        expect(FormValidators.formatSlug('Mary-Jane'), equals('mary-jane'));
        expect(FormValidators.formatSlug('  John  Doe  '), equals('john-doe'));
        expect(FormValidators.formatSlug('John@#$Doe'), equals('johndoe'));
      });

      test('should handle empty or null input', () {
        expect(FormValidators.formatSlug(null), equals(''));
        expect(FormValidators.formatSlug(''), equals(''));
        expect(FormValidators.formatSlug('   '), equals(''));
      });
    });
  });
}