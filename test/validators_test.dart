import 'package:employee_management_app/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
      expect(Validators.email('@nouser.com'), isNotNull);
    });

    test('accepts valid addresses including long TLDs', () {
      expect(Validators.email('jane@example.com'), isNull);
      expect(Validators.email('jane.doe+tag@example.co.uk'), isNull);
      expect(Validators.email('dev@startup.online'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires at least 6 characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('rejects empty input', () {
      expect(Validators.password(''), 'Password is required');
    });
  });

  group('Validators.confirmPassword', () {
    test('fails when passwords differ', () {
      expect(
        Validators.confirmPassword('abc123', 'xyz789'),
        'Passwords do not match',
      );
    });

    test('passes when they match', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });

  group('Validators.mobile', () {
    test('rejects numbers that are too short', () {
      expect(Validators.mobile('12345'), isNotNull);
    });

    test('ignores formatting characters', () {
      expect(Validators.mobile('+91 98765 43210'), isNull);
    });
  });

  group('Validators.required', () {
    test('uses the supplied label in the message', () {
      expect(Validators.required('', 'State'), 'State is required');
      expect(Validators.required('   ', 'District'), 'District is required');
      expect(Validators.required('Pune', 'District'), isNull);
    });
  });
}