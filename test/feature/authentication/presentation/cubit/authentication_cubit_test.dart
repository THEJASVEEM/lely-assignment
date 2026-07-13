import 'package:flutter_test/flutter_test.dart';

import 'package:lely_assignment/feature/authentication/domain/validators/username_validator.dart';
import 'package:lely_assignment/feature/authentication/presentation/cubit/authentication_cubit.dart';

import '../../../fake_authentication_repository.dart';

void main() {
  group('AuthenticationCubit', () {
    late FakeAuthenticationRepository repository;
    late AuthenticationCubit cubit;

    setUp(() {
      repository = FakeAuthenticationRepository(shouldAuthenticate: false);

      cubit = AuthenticationCubit(repository, const UsernameValidator());
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is AuthenticationInitial', () {
      expect(cubit.state, isA<AuthenticationInitial>());
    });

    test('emits username error when username is empty', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthenticationFailure>()
              .having(
                (state) => state.usernameError,
                'usernameError',
                'Username is required.',
              )
              .having((state) => state.passwordError, 'passwordError', isNull),
        ]),
      );

      await cubit.login(username: '', password: 'LelyControl2');

      await expectation;

      expect(repository.authenticateCallCount, 0);
      expect(repository.receivedCredentials, isNull);
    });

    test('emits password error when password is empty', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthenticationFailure>()
              .having((state) => state.usernameError, 'usernameError', isNull)
              .having(
                (state) => state.passwordError,
                'passwordError',
                'Password is required.',
              ),
        ]),
      );

      await cubit.login(username: 'Lely', password: '');

      await expectation;

      expect(repository.authenticateCallCount, 0);
      expect(repository.receivedCredentials, isNull);
    });

    test('emits both field errors when both fields are empty', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthenticationFailure>()
              .having(
                (state) => state.usernameError,
                'usernameError',
                'Username is required.',
              )
              .having(
                (state) => state.passwordError,
                'passwordError',
                'Password is required.',
              ),
        ]),
      );

      await cubit.login(username: '', password: '');

      await expectation;

      expect(repository.authenticateCallCount, 0);
      expect(repository.receivedCredentials, isNull);
    });

    test('emits unsupported-character error for invalid username', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthenticationFailure>()
              .having(
                (state) => state.usernameError,
                'usernameError',
                'Username can only contain letters and numbers.',
              )
              .having((state) => state.passwordError, 'passwordError', isNull),
        ]),
      );

      await cubit.login(username: 'Lely%', password: 'LelyControl2');

      await expectation;

      expect(repository.authenticateCallCount, 0);
      expect(repository.receivedCredentials, isNull);
    });

    test('emits loading then success for valid credentials', () async {
      repository.shouldAuthenticate = true;

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthenticationLoading>(),
          isA<AuthenticationSuccess>(),
        ]),
      );

      await cubit.login(username: 'Lely', password: 'LelyControl2');

      await expectation;

      expect(repository.authenticateCallCount, 1);
      expect(repository.receivedCredentials?.username, 'Lely');
      expect(repository.receivedCredentials?.password, 'LelyControl2');
    });

    test('passes normalized username to repository', () async {
      repository.shouldAuthenticate = true;

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthenticationLoading>(),
          isA<AuthenticationSuccess>(),
        ]),
      );

      await cubit.login(username: '  Lely  ', password: 'LelyControl2');

      await expectation;

      expect(repository.authenticateCallCount, 1);
      expect(repository.receivedCredentials?.username, 'Lely');
    });

    test(
      'emits loading then credential error when authentication fails',
      () async {
        repository.shouldAuthenticate = false;

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<AuthenticationLoading>(),
            isA<AuthenticationFailure>()
                .having((state) => state.usernameError, 'usernameError', isNull)
                .having(
                  (state) => state.passwordError,
                  'passwordError',
                  'Invalid username or password.',
                ),
          ]),
        );

        await cubit.login(username: 'Lely', password: 'WrongPassword');

        await expectation;

        expect(repository.authenticateCallCount, 1);
      },
    );

    test(
      'emits unsupported-character error while username is being edited',
      () async {
        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<AuthenticationFailure>()
                .having(
                  (state) => state.usernameError,
                  'usernameError',
                  'Username can only contain letters and numbers.',
                )
                .having(
                  (state) => state.passwordError,
                  'passwordError',
                  isNull,
                ),
          ]),
        );

        cubit.usernameChanged('Lely%');

        await expectation;

        expect(repository.authenticateCallCount, 0);
      },
    );

    test(
      'does not show required error while empty username is being edited',
      () async {
        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<AuthenticationFailure>()
                .having((state) => state.usernameError, 'usernameError', isNull)
                .having(
                  (state) => state.passwordError,
                  'passwordError',
                  isNull,
                ),
          ]),
        );

        cubit.usernameChanged('');

        await expectation;

        expect(repository.authenticateCallCount, 0);
      },
    );

    test('clears username editing error when username becomes valid', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthenticationFailure>().having(
            (state) => state.usernameError,
            'usernameError',
            'Username can only contain letters and numbers.',
          ),
          isA<AuthenticationFailure>().having(
            (state) => state.usernameError,
            'usernameError',
            isNull,
          ),
        ]),
      );

      cubit.usernameChanged('Lely%');
      cubit.usernameChanged('Lely');

      await expectation;
    });
  });
}
