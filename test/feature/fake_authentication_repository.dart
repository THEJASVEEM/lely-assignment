import 'package:lely_assignment/feature/authentication/domain/entities/login_credentials.dart';
import 'package:lely_assignment/feature/authentication/domain/repositories/authentication_repository.dart';

class FakeAuthenticationRepository implements AuthenticationRepository {
  FakeAuthenticationRepository({required this.shouldAuthenticate});

  bool shouldAuthenticate;
  LoginCredentials? receivedCredentials;
  int authenticateCallCount = 0;

  @override
  Future<bool> authenticate(LoginCredentials credentials) async {
    authenticateCallCount++;
    receivedCredentials = credentials;

    return shouldAuthenticate;
  }
}
