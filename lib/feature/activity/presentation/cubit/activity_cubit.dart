import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lely_assignment/feature/activity/domain/entities/activity_range.dart';
import 'package:lely_assignment/feature/activity/domain/entities/add_activity_result.dart';
import 'package:lely_assignment/feature/activity/domain/entities/robot_activity.dart';
import 'package:lely_assignment/feature/activity/domain/repositories/robot_activity_repository.dart';

part 'activity_state.dart';

@injectable
class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(this._repository) : super(const ActivityInitial());

  final RobotActivityRepository _repository;

  Future<void> loadActivities() async {
    emit(const ActivityLoading());

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

  void selectRange(ActivityRange range) {
    final currentState = state;

    if (currentState is! ActivityLoaded || currentState.isSubmitting) {
      return;
    }

    emit(
      currentState.copyWith(
        selectedRange: range,
        filteredActivities: _filterActivities(
          activities: currentState.activities,
          range: range,
        ),
        clearAddActivityError: true,
      ),
    );
  }

  Future<void> addActivity({
    required DateTime date,
    required int durationMinutes,
  }) async {
    final currentState = state;

    if (currentState is! ActivityLoaded || currentState.isSubmitting) {
      return;
    }

    emit(
      currentState.copyWith(isSubmitting: true, clearAddActivityError: true),
    );

    try {
      final result = await _repository.addActivity(
        RobotActivity(date: _dateOnly(date), durationMinutes: durationMinutes),
      );

      switch (result) {
        case AddActivitySuccess(:final activities):
          emit(
            ActivityLoaded(
              activities: activities,
              filteredActivities: _filterActivities(
                activities: activities,
                range: currentState.selectedRange,
              ),
              selectedRange: currentState.selectedRange,
            ),
          );

        case DuplicateActivityDate():
          emit(
            currentState.copyWith(
              isSubmitting: false,
              addActivityError:
                  'Activity already exists for the selected date.',
            ),
          );
      }
    } catch (_) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          addActivityError: 'Unable to add the activity. Please try again.',
        ),
      );
    }
  }

  void clearAddActivityError() {
    final currentState = state;

    if (currentState is! ActivityLoaded ||
        currentState.addActivityError == null) {
      return;
    }

    emit(currentState.copyWith(clearAddActivityError: true));
  }

  List<RobotActivity> _filterActivities({
    required List<RobotActivity> activities,
    required ActivityRange range,
  }) {
    if (activities.isEmpty) {
      return const [];
    }

    final sortedActivities = List<RobotActivity>.of(activities)
      ..sort((first, second) => first.date.compareTo(second.date));

    final latestDate = sortedActivities.last.date;
    final startDate = _startDateForRange(latestDate, range);

    return sortedActivities
        .where(
          (activity) =>
              !activity.date.isBefore(startDate) &&
              !activity.date.isAfter(latestDate),
        )
        .toList(growable: false);
  }

  DateTime _startDateForRange(DateTime endDate, ActivityRange range) {
    return switch (range) {
      ActivityRange.oneWeek => endDate.subtract(const Duration(days: 6)),
      ActivityRange.oneMonth => _subtractMonths(endDate, 1),
      ActivityRange.threeMonths => _subtractMonths(endDate, 3),
    };
  }

  DateTime _subtractMonths(DateTime date, int months) {
    final targetMonth = date.month - months;

    final firstDayOfTargetMonth = DateTime(date.year, targetMonth, 1);

    final lastDayOfTargetMonth = DateTime(
      firstDayOfTargetMonth.year,
      firstDayOfTargetMonth.month + 1,
      0,
    ).day;

    final safeDay = date.day > lastDayOfTargetMonth
        ? lastDayOfTargetMonth
        : date.day;

    return DateTime(
      firstDayOfTargetMonth.year,
      firstDayOfTargetMonth.month,
      safeDay,
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
