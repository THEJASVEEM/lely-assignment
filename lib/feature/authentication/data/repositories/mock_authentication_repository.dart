import 'package:injectable/injectable.dart';
import 'package:lely_assignment/feature/authentication/domain/entities/login_credentials.dart';
import 'package:lely_assignment/feature/authentication/domain/repositories/authentication_repository.dart';

@LazySingleton(as: AuthenticationRepository)
class MockAuthenticationRepository implements AuthenticationRepository {
  static const String _validUsername = 'Lely';
  static const String _validPassword = 'LelyControl2';

  @override
  Future<bool> authenticate(LoginCredentials credentials) async {
    return credentials.username == _validUsername &&
        credentials.password == _validPassword;
  }
}
