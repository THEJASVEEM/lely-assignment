part of 'activity_cubit.dart';

@immutable
sealed class ActivityState {
  const ActivityState();
}

final class ActivityInitial extends ActivityState {
  const ActivityInitial();
}

final class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

final class ActivityLoaded extends ActivityState {
  const ActivityLoaded({
    required this.activities,
    required this.filteredActivities,
    required this.selectedRange,
    this.isSubmitting = false,
    this.addActivityError,
  });

  final List<RobotActivity> activities;
  final List<RobotActivity> filteredActivities;
  final ActivityRange selectedRange;
  final bool isSubmitting;
  final String? addActivityError;

  ActivityLoaded copyWith({
    List<RobotActivity>? activities,
    List<RobotActivity>? filteredActivities,
    ActivityRange? selectedRange,
    bool? isSubmitting,
    String? addActivityError,
    bool clearAddActivityError = false,
  }) {
    return ActivityLoaded(
      activities: activities ?? this.activities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      selectedRange: selectedRange ?? this.selectedRange,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      addActivityError: clearAddActivityError
          ? null
          : addActivityError ?? this.addActivityError,
    );
  }
}

final class ActivityFailure extends ActivityState {
  const ActivityFailure({required this.message});

  final String message;
}
