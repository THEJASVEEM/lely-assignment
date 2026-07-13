sealed class UsernameValidationResult {
  const UsernameValidationResult();
}

final class ValidUsername extends UsernameValidationResult {
  const ValidUsername(this.value);

  final String value;
}

sealed class InvalidUsername extends UsernameValidationResult {
  const InvalidUsername();
}

final class EmptyUsername extends InvalidUsername {
  const EmptyUsername();
}

final class UnsupportedUsernameCharacters extends InvalidUsername {
  const UnsupportedUsernameCharacters();
}
