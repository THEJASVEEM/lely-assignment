import 'package:flutter_test/flutter_test.dart';
import 'package:lely_assignment/feature/authentication/domain/validators/username_validator.dart';
import 'package:lely_assignment/feature/authentication/domain/validators/validation_result.dart';

void main() {
  late UsernameValidator validator;

  setUp(() {
    validator = const UsernameValidator();
  });

  group('UsernameValidator', () {
    test('returns EmptyUsername when value is empty', () {
      final result = validator.validate('');

      expect(result, isA<EmptyUsername>());
    });

    test('returns EmptyUsername when value contains only spaces', () {
      final result = validator.validate('   ');

      expect(result, isA<EmptyUsername>());
    });

    test('returns ValidUsername for valid alphanumeric input', () {
      final result = validator.validate('Lely');

      expect(result, isA<ValidUsername>());
      expect((result as ValidUsername).value, 'Lely');
    });

    test('returns normalized username without surrounding spaces', () {
      final result = validator.validate('  Lely  ');

      expect(result, isA<ValidUsername>());
      expect((result as ValidUsername).value, 'Lely');
    });

    test('returns UnsupportedUsernameCharacters for percent symbol', () {
      final result = validator.validate('Lely%');

      expect(result, isA<UnsupportedUsernameCharacters>());
    });

    test('returns UnsupportedUsernameCharacters for ampersand', () {
      final result = validator.validate('Lely&');

      expect(result, isA<UnsupportedUsernameCharacters>());
    });

    test('returns UnsupportedUsernameCharacters for caret', () {
      final result = validator.validate('Lely^');

      expect(result, isA<UnsupportedUsernameCharacters>());
    });

    test(
      'returns UnsupportedUsernameCharacters for whitespace inside username',
      () {
        final result = validator.validate('Lely User');

        expect(result, isA<UnsupportedUsernameCharacters>());
      },
    );

    test('returns UnsupportedUsernameCharacters for underscore', () {
      final result = validator.validate('Lely_User');

      expect(result, isA<UnsupportedUsernameCharacters>());
    });

    test('returns UnsupportedUsernameCharacters for hyphen', () {
      final result = validator.validate('Lely-User');

      expect(result, isA<UnsupportedUsernameCharacters>());
    });
  });
}
