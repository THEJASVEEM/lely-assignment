import 'package:lely_assignment/feature/authentication/domain/entities/login_credentials.dart';

abstract interface class AuthenticationRepository {
  Future<bool> authenticate(LoginCredentials credentials);
}
