import 'dart:async';

import 'package:lely_assignment/feature/authentication/domain/entities/login_credentials.dart';
import 'package:lely_assignment/feature/authentication/domain/repositories/authentication_repository.dart';

class DelayedFakeAuthenticationRepository implements AuthenticationRepository {
  DelayedFakeAuthenticationRepository({required this.shouldAuthenticate});

  final bool shouldAuthenticate;

  final Completer<bool> _completer = Completer<bool>();

  @override
  Future<bool> authenticate(LoginCredentials credentials) {
    return _completer.future;
  }

  Future<void> completeAuthentication() async {
    if (!_completer.isCompleted) {
      _completer.complete(shouldAuthenticate);
    }
  }
}
