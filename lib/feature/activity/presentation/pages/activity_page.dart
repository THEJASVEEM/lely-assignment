import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lely_assignment/feature/activity/presentation/cubit/activity_cubit.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/activity_content.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/activity_error_view.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Robot Activity')),
      body: BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          return switch (state) {
            ActivityInitial() => const SizedBox.shrink(),
            ActivityLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ActivityFailure(:final message) => ActivityErrorView(
              message: message,
              onRetry: context.read<ActivityCubit>().loadActivities,
            ),
            ActivityLoaded() => ActivityContent(state: state),
          };
        },
      ),
    );
  }
}
