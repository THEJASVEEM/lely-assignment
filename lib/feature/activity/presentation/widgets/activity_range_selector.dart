import 'package:flutter/material.dart';
import 'package:lely_assignment/feature/activity/domain/entities/activity_range.dart';

class ActivityRangeSelector extends StatelessWidget {
  const ActivityRangeSelector({
    required this.selectedRange,
    required this.onSelected,
    super.key,
  });

  final ActivityRange selectedRange;
  final ValueChanged<ActivityRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ActivityRange.values
            .map((range) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: Key('activity_range_${range.name}'),
                  label: Text(range.label),
                  selected: selectedRange == range,
                  onSelected: (_) => onSelected(range),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
