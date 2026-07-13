import 'package:injectable/injectable.dart';
import 'package:lely_assignment/feature/authentication/domain/validators/validation_result.dart';

@lazySingleton
class UsernameValidator {
  const UsernameValidator();

  static final RegExp _allowedCharacters = RegExp(r'^[a-zA-Z0-9]+$');

  UsernameValidationResult validate(String value) {
    final username = value.trim();

    if (username.isEmpty) {
      return const EmptyUsername();
    }

    if (!_allowedCharacters.hasMatch(username)) {
      return const UnsupportedUsernameCharacters();
    }

    return ValidUsername(username);
  }
}
