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
    final result = _usernameValidator.validate(username);

    if (password.isEmpty) {
      emit(const AuthenticationFailure('Password is required.'));
      return;
    }

    switch (result) {
      case EmptyUsername():
        emit(const AuthenticationFailure('Username is required.'));
        return;

      case UnsupportedUsernameCharacters():
        emit(
          const AuthenticationFailure(
            'Username can only contain letters and numbers.',
          ),
        );
        return;

      case ValidUsername(:final value):
        await _authenticate(username: value, password: password);
    }
  }

  Future<void> _authenticate({
    required String username,
    required String password,
  }) async {
    emit(const AuthenticationLoading());

    final isAuthenticated = await _authenticationRepository.authenticate(
      LoginCredentials(username: username.trim(), password: password),
    );

    if (isAuthenticated) {
      emit(const AuthenticationSuccess());
    } else {
      emit(const AuthenticationFailure('Invalid username or password.'));
    }
  }

  void reset() {
    emit(const AuthenticationInitial());
  }
}
