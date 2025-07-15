import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/services/auth_service.dart';

void main() {
  group('Password Validation Tests', () {
    group('Password Strength Validation', () {
      test('should return true for strong passwords', () {
        final strongPasswords = [
          'StrongPass123!',
          'MySecure@Pass1',
          'Complex&Password9',
          'Valid*Strong8',
          'Test\$Password123',
        ];

        for (final password in strongPasswords) {
          expect(
            AuthService.isPasswordStrong(password),
            true,
            reason: 'Password "$password" should be considered strong',
          );
        }
      });

      test('should return false for weak passwords', () {
        final weakPasswords = [
          'weak', // Too short
          'password', // No uppercase, numbers, special chars
          'PASSWORD', // No lowercase, numbers, special chars
          '12345678', // No letters, special chars
          'Password', // No numbers, special chars
          'Password123', // No special chars
          'Password!', // No numbers
          'password123!', // No uppercase
          'PASSWORD123!', // No lowercase
          '', // Empty
          'Pass!1', // Too short
          'Complex#Password9', // Invalid special char (#)
        ];

        for (final password in weakPasswords) {
          expect(
            AuthService.isPasswordStrong(password),
            false,
            reason: 'Password "$password" should be considered weak',
          );
        }
      });
    });

    group('Password Strength Score', () {
      test('should return correct score for various passwords', () {
        final testCases = [
          {'password': '', 'expectedScore': 0},
          {'password': 'weak', 'expectedScore': 1}, // Only lowercase
          {'password': 'WEAK', 'expectedScore': 1}, // Only uppercase
          {'password': '1234', 'expectedScore': 1}, // Only numbers
          {'password': '!@\$&', 'expectedScore': 1}, // Only special chars
          {
            'password': 'weakWEAK',
            'expectedScore': 3,
          }, // Lower + upper + length
          {
            'password': 'weak1234',
            'expectedScore': 3,
          }, // Lower + numbers + length
          {
            'password': 'weak!@\$&',
            'expectedScore': 3,
          }, // Lower + special + length
          {
            'password': 'WEAK1234',
            'expectedScore': 3,
          }, // Upper + numbers + length
          {
            'password': 'WEAK!@\$&',
            'expectedScore': 3,
          }, // Upper + special + length
          {
            'password': '1234!@\$&',
            'expectedScore': 3,
          }, // Numbers + special + length
          {
            'password': 'weakWEAK1234',
            'expectedScore': 4,
          }, // Lower + upper + numbers + length
          {
            'password': 'weakWEAK!@\$&',
            'expectedScore': 4,
          }, // Lower + upper + special + length
          {
            'password': 'weak1234!@\$&',
            'expectedScore': 4,
          }, // Lower + numbers + special + length
          {
            'password': 'WEAK1234!@\$&',
            'expectedScore': 4,
          }, // Upper + numbers + special + length
          {'password': 'weakWEAK1234!@\$&', 'expectedScore': 5}, // All criteria
        ];

        for (final testCase in testCases) {
          final password = testCase['password'] as String;
          final expectedScore = testCase['expectedScore'] as int;

          expect(
            AuthService.getPasswordStrength(password),
            expectedScore,
            reason: 'Password "$password" should have score $expectedScore',
          );
        }
      });
    });

    group('Password Requirements', () {
      test('should validate minimum length requirement', () {
        expect(AuthService.isPasswordStrong('Short1!'), false);
        expect(AuthService.isPasswordStrong('LongEnough1!'), true);
      });

      test('should validate lowercase letter requirement', () {
        expect(AuthService.isPasswordStrong('NOLOWER123!'), false);
        expect(AuthService.isPasswordStrong('HasLower123!'), true);
      });

      test('should validate uppercase letter requirement', () {
        expect(AuthService.isPasswordStrong('noupper123!'), false);
        expect(AuthService.isPasswordStrong('HasUpper123!'), true);
      });

      test('should validate number requirement', () {
        expect(AuthService.isPasswordStrong('NoNumbers!'), false);
        expect(AuthService.isPasswordStrong('HasNumbers1!'), true);
      });

      test('should validate special character requirement', () {
        expect(AuthService.isPasswordStrong('NoSpecial123'), false);
        expect(AuthService.isPasswordStrong('HasSpecial123!'), true);
      });

      test('should only accept specific special characters', () {
        // Valid special characters: [@$!%*?&]
        expect(AuthService.isPasswordStrong('ValidPass123@'), true);
        expect(AuthService.isPasswordStrong('ValidPass123\$'), true);
        expect(AuthService.isPasswordStrong('ValidPass123!'), true);
        expect(AuthService.isPasswordStrong('ValidPass123%'), true);
        expect(AuthService.isPasswordStrong('ValidPass123*'), true);
        expect(AuthService.isPasswordStrong('ValidPass123?'), true);
        expect(AuthService.isPasswordStrong('ValidPass123&'), true);

        // Invalid special characters
        expect(AuthService.isPasswordStrong('InvalidPass123#'), false);
        expect(AuthService.isPasswordStrong('InvalidPass123+'), false);
        expect(AuthService.isPasswordStrong('InvalidPass123-'), false);
        expect(AuthService.isPasswordStrong('InvalidPass123='), false);
      });
    });

    group('Edge Cases', () {
      test('should handle empty password', () {
        expect(AuthService.isPasswordStrong(''), false);
        expect(AuthService.getPasswordStrength(''), 0);
      });

      test('should handle very long passwords', () {
        final longPassword = 'A' * 100 + 'a' * 100 + '1' * 100 + '!' * 100;
        expect(AuthService.isPasswordStrong(longPassword), true);
        expect(AuthService.getPasswordStrength(longPassword), 5);
      });

      test('should handle passwords with only allowed special characters', () {
        final specialOnlyPassword = '@\$!%*?&@\$!%*?&@\$!%*?&';
        expect(AuthService.isPasswordStrong(specialOnlyPassword), false);
        expect(
          AuthService.getPasswordStrength(specialOnlyPassword),
          2,
        ); // Length + special
      });

      test('should reject unicode characters', () {
        // Unicode characters are not allowed in the strict regex
        final unicodePassword = 'Pässwörd123!';
        expect(AuthService.isPasswordStrong(unicodePassword), false);
        expect(
          AuthService.getPasswordStrength(unicodePassword),
          5,
        ); // Score counts them but regex rejects
      });
    });

    group('Common Password Patterns', () {
      test('should reject common weak patterns', () {
        final commonWeakPasswords = [
          'password123',
          'Password123',
          '123456789',
          'qwerty123',
          'admin123',
          'user123',
          'test123',
          'welcome123',
          'login123',
          'password1',
        ];

        for (final password in commonWeakPasswords) {
          expect(
            AuthService.isPasswordStrong(password),
            false,
            reason: 'Common weak password "$password" should be rejected',
          );
        }
      });

      test('should accept strong patterns', () {
        final strongPatterns = [
          'MyStr0ng!Pass',
          'Secure*2024\$',
          'Complex@Auth9',
          'Valid&Token7',
          'Strong%Key123',
        ];

        for (final password in strongPatterns) {
          expect(
            AuthService.isPasswordStrong(password),
            true,
            reason: 'Strong password "$password" should be accepted',
          );
        }
      });
    });

    group('Password Feedback', () {
      test('should provide appropriate feedback for weak passwords', () {
        // This would test the password feedback functionality
        // if it were exposed from the AuthService
        final weakPassword = 'weak';
        final score = AuthService.getPasswordStrength(weakPassword);

        expect(score, lessThan(5));
        expect(AuthService.isPasswordStrong(weakPassword), false);
      });
    });
  });
}
