import 'package:flutter/material.dart';
import 'package:lely_assignment/app.dart';
import 'package:lely_assignment/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  runApp(const LelyAssignmentApp());
}
