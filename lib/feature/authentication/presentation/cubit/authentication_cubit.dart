import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lely_assignment/feature/authentication/domain/entities/login_credentials.dart';
import 'package:lely_assignment/feature/authentication/domain/repositories/authentication_repository.dart';
import 'package:lely_assignment/feature/authentication/domain/validators/username_validator.dart';
import 'package:lely_assignment/feature/authentication/domain/validators/validation_result.dart';

part 'authentication_state.dart';

@injectable
class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit(this._authenticationRepository, this._usernameValidator)
    : super(const AuthenticationInitial());

  final AuthenticationRepository _authenticationRepository;
  final UsernameValidator _usernameValidator;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final usernameResult = _usernameValidator.validate(username);

    final usernameError = switch (usernameResult) {
      EmptyUsername() => 'Username is required.',
      UnsupportedUsernameCharacters() =>
        'Username can only contain letters and numbers.',
      ValidUsername() => null,
    };

    final passwordError = password.isEmpty ? 'Password is required.' : null;

    if (usernameError != null || passwordError != null) {
      emit(
        AuthenticationFailure(
          usernameError: usernameError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    final validUsername = usernameResult as ValidUsername;

    await _authenticate(username: validUsername.value, password: password);
  }

  Future<void> _authenticate({
    required String username,
    required String password,
  }) async {
    emit(const AuthenticationLoading());

    final isAuthenticated = await _authenticationRepository.authenticate(
      LoginCredentials(username: username, password: password),
    );

    if (isAuthenticated) {
      emit(const AuthenticationSuccess());
      return;
    }

    emit(
      const AuthenticationFailure(
        passwordError: 'Invalid username or password.',
      ),
    );
  }

  void usernameChanged(String username) {
    final result = _usernameValidator.validate(username);

    final error = switch (result) {
      EmptyUsername() => null,
      UnsupportedUsernameCharacters() =>
        'Username can only contain letters and numbers.',
      ValidUsername() => null,
    };

    emit(AuthenticationFailure(usernameError: error));
  }
}
