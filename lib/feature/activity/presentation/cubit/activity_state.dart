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
  });

  final List<RobotActivity> activities;
  final List<RobotActivity> filteredActivities;
  final ActivityRange selectedRange;
}

final class ActivityFailure extends ActivityState {
  const ActivityFailure({this.message});

  final String? message;
}
