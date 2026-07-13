import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lely_assignment/core/di/injection.dart';
import 'package:lely_assignment/feature/authentication/presentation/cubit/authentication_cubit.dart';
import 'package:lely_assignment/feature/authentication/presentation/pages/login_page.dart';

class LelyAssignmentApp extends StatelessWidget {
  const LelyAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lely Assignment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => getIt<AuthenticationCubit>(),
        child: LoginPage(),
      ),
    );
  }
}
