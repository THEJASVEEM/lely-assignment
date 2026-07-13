part of 'authentication_cubit.dart';

@immutable
sealed class AuthenticationState {
  const AuthenticationState();
}

final class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

final class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

final class AuthenticationSuccess extends AuthenticationState {
  const AuthenticationSuccess();
}

final class AuthenticationFailure extends AuthenticationState {
  const AuthenticationFailure(this.message);

  final String message;
}
