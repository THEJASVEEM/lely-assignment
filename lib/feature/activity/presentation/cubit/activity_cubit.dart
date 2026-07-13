import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lely_assignment/feature/activity/domain/entities/activity_range.dart';
import 'package:lely_assignment/feature/activity/domain/entities/robot_activity.dart';
import 'package:lely_assignment/feature/activity/domain/repositories/robot_activity_repository.dart';

part 'activity_state.dart';

@injectable
class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(this._repository) : super(ActivityInitial());

  final RobotActivityRepository _repository;

  Future<void> loadActivities() async {
    emit(ActivityLoading());

    try {
      final activities = await _repository.getActivities();

      const selectedRange = ActivityRange.oneMonth;

      emit(
        ActivityLoaded(
          activities: activities,
          filteredActivities: _filterActivities(
            activities: activities,
            range: selectedRange,
          ),
          selectedRange: selectedRange,
        ),
      );
    } on FormatException {
      emit(
        const ActivityFailure(message: 'Unable to read robot activity data.'),
      );
    } catch (_) {
      emit(
        const ActivityFailure(
          message: 'Something went wrong while loading activity data.',
        ),
      );
    }
  }

  List<RobotActivity> _filterActivities({
    required List<RobotActivity> activities,
    required ActivityRange range,
  }) {
    if (activities.isEmpty) {
      return const [];
    }

    final latestDate = activities.last.date;
    final startDate = _startDateForRange(latestDate, range);

    return activities
        .where(
          (activity) =>
              !activity.date.isBefore(startDate) &&
              !activity.date.isAfter(latestDate),
        )
        .toList();
  }

  DateTime _startDateForRange(DateTime endDate, ActivityRange range) {
    return switch (range) {
      ActivityRange.oneWeek => endDate.subtract(const Duration(days: 6)),
      ActivityRange.oneMonth => DateTime(
        endDate.year,
        endDate.month - 1,
        endDate.day,
      ),
      ActivityRange.threeMonths => DateTime(
        endDate.year,
        endDate.month - 3,
        endDate.day,
      ),
      ActivityRange.sixMonths => DateTime(
        endDate.year,
        endDate.month - 6,
        endDate.day,
      ),
      ActivityRange.oneYear => DateTime(
        endDate.year - 1,
        endDate.month,
        endDate.day,
      ),
    };
  }
}
