import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lely_assignment/feature/activity/presentation/cubit/activity_cubit.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/activity_line_chart.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/activity_range_selector.dart';

class ActivityContent extends StatelessWidget {
  const ActivityContent({super.key, required this.state});

  final ActivityLoaded state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hours active per day',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ActivityRangeSelector(
              selectedRange: state.selectedRange,
              onSelected: context.read<ActivityCubit>().selectRange,
            ),
            const SizedBox(height: 24),
            Container(
              key: const Key('activity_chart_placeholder'),
              height: 320,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: state.filteredActivities.isEmpty
                  ? Text(
                      'No activity available for this range',
                      textAlign: TextAlign.center,
                    )
                  : ActivityLineChart(activities: state.filteredActivities),
            ),
          ],
        ),
      ),
    );
  }
}
