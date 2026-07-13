import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lely_assignment/feature/authentication/domain/validators/username_validator.dart';
import 'package:lely_assignment/feature/authentication/presentation/cubit/authentication_cubit.dart';
import 'package:lely_assignment/feature/authentication/presentation/pages/login_page.dart';

import 'feature/delayed_fake_auth_repository.dart';
import 'feature/fake_authentication_repository.dart';

Finder usernameField() => find.byKey(const Key('username_field'));

Finder passwordField() => find.byKey(const Key('password_field'));

Finder loginButton() => find.byKey(const Key('login_button'));
void main() {
  late FakeAuthenticationRepository repository;
  late AuthenticationCubit cubit;

  setUp(() {
    repository = FakeAuthenticationRepository(shouldAuthenticate: false);

    cubit = AuthenticationCubit(repository, const UsernameValidator());
  });

  tearDown(() async {
    await cubit.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthenticationCubit>.value(
        value: cubit,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders the login form', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Lely'), findsOneWidget);
      expect(find.text('Sign in to view robot activity'), findsOneWidget);
      expect(usernameField(), findsOneWidget);
      expect(passwordField(), findsOneWidget);
      expect(loginButton(), findsOneWidget);
    });

    testWidgets('shows required errors when submitting empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(loginButton());
      await tester.pump();

      expect(find.text('Username is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);

      expect(repository.authenticateCallCount, 0);
    });

    testWidgets('shows unsupported-character error while typing username', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(usernameField(), 'Lely%');
      await tester.pump();

      expect(
        find.text('Username can only contain letters and numbers.'),
        findsOneWidget,
      );

      expect(repository.authenticateCallCount, 0);
    });

    testWidgets(
      'clears unsupported-character error when username becomes valid',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.enterText(usernameField(), 'Lely%');
        await tester.pump();

        expect(
          find.text('Username can only contain letters and numbers.'),
          findsOneWidget,
        );

        await tester.enterText(usernameField(), 'Lely');
        await tester.pump();

        expect(
          find.text('Username can only contain letters and numbers.'),
          findsNothing,
        );
      },
    );

    testWidgets('shows password-required error when username is valid', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(usernameField(), 'Lely');

      await tester.tap(loginButton());
      await tester.pump();

      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.text('Username is required.'), findsNothing);

      expect(repository.authenticateCallCount, 0);
    });

    testWidgets('shows invalid credential error when authentication fails', (
      tester,
    ) async {
      repository.shouldAuthenticate = false;

      await tester.pumpWidget(buildSubject());

      await tester.enterText(usernameField(), 'Lely');
      await tester.enterText(passwordField(), 'WrongPassword');

      await tester.tap(loginButton());

      await tester.pump();
      await tester.pump();

      expect(find.text('Invalid username or password.'), findsOneWidget);

      expect(repository.authenticateCallCount, 1);
      expect(repository.receivedCredentials?.username, 'Lely');
      expect(repository.receivedCredentials?.password, 'WrongPassword');
    });

    testWidgets('shows loading indicator while authentication is in progress', (
      tester,
    ) async {
      final delayedRepository = DelayedFakeAuthenticationRepository(
        shouldAuthenticate: true,
      );

      final delayedCubit = AuthenticationCubit(
        delayedRepository,
        const UsernameValidator(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationCubit>.value(
            value: delayedCubit,
            child: const LoginPage(),
          ),
        ),
      );

      await tester.enterText(usernameField(), 'Lely');
      await tester.enterText(passwordField(), 'LelyControl2');

      await tester.tap(loginButton());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));

      expect(button.onPressed, isNull);

      await delayedRepository.completeAuthentication();
      await tester.pump();

      await delayedCubit.close();
    });

    testWidgets('emits success for valid credentials', (tester) async {
      repository.shouldAuthenticate = true;

      await tester.pumpWidget(buildSubject());

      await tester.enterText(usernameField(), 'Lely');
      await tester.enterText(passwordField(), 'LelyControl2');

      await tester.tap(loginButton());

      await tester.pump();
      await tester.pump();

      expect(cubit.state, isA<AuthenticationSuccess>());

      expect(repository.authenticateCallCount, 1);
      expect(repository.receivedCredentials?.username, 'Lely');
      expect(repository.receivedCredentials?.password, 'LelyControl2');
    });

    testWidgets('submits the form using the password keyboard action', (
      tester,
    ) async {
      repository.shouldAuthenticate = true;

      await tester.pumpWidget(buildSubject());

      await tester.enterText(usernameField(), 'Lely');
      await tester.enterText(passwordField(), 'LelyControl2');

      await tester.tap(passwordField());
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pump();
      await tester.pump();

      expect(repository.authenticateCallCount, 1);
      expect(cubit.state, isA<AuthenticationSuccess>());
    });
  });
}
