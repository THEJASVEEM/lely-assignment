import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lely_assignment/feature/activity/presentation/cubit/activity_cubit.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/activity_content.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/activity_error_view.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/add_activity_bottomsheet.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  Future<void> _openAddActivityBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (_) {
        return BlocProvider<ActivityCubit>.value(
          value: context.read<ActivityCubit>(),
          child: const AddActivityBottomSheet(),
        );
      },
    );

    if (context.mounted) {
      context.read<ActivityCubit>().clearAddActivityError();
    }
  }

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
      floatingActionButton: BlocSelector<ActivityCubit, ActivityState, bool>(
        selector: (state) {
          return state is ActivityLoaded;
        },
        builder: (context, isLoaded) {
          return FloatingActionButton.extended(
            key: const Key('add_activity_button'),
            onPressed: isLoaded
                ? () => _openAddActivityBottomSheet(context)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Add activity'),
          );
        },
      ),
    );
  }
}
