import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lely_assignment/feature/authentication/presentation/cubit/authentication_cubit.dart';
import 'package:lely_assignment/feature/authentication/presentation/widgets/login_button.dart';
import 'package:lely_assignment/feature/authentication/presentation/widgets/password_textfield.dart';
import 'package:lely_assignment/feature/authentication/presentation/widgets/username_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();

    context.read<AuthenticationCubit>().login(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationSuccess) {
              debugPrint('Login successful');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthenticationLoading;

            final usernameError = state is AuthenticationFailure
                ? state.usernameError
                : null;

            final passwordError = state is AuthenticationFailure
                ? state.passwordError
                : null;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.agriculture_outlined,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Lely',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to view robot activity',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      UsernameTextField(
                        controller: _usernameController,
                        errorText: usernameError,
                        onChanged: context
                            .read<AuthenticationCubit>()
                            .usernameChanged,
                      ),
                      const SizedBox(height: 16),
                      PasswordTextField(
                        controller: _passwordController,
                        errorText: passwordError,
                        onSubmitted: _login,
                      ),
                      const SizedBox(height: 24),
                      LoginButton(
                        key: const Key('login_button'),
                        isLoading: isLoading,
                        onPressed: _login,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
