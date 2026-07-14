import 'robot_activity.dart';

sealed class AddActivityResult {
  const AddActivityResult();
}

final class AddActivitySuccess extends AddActivityResult {
  const AddActivitySuccess(this.activities);

  final List<RobotActivity> activities;
}

final class DuplicateActivityDate extends AddActivityResult {
  const DuplicateActivityDate(this.date);

  final DateTime date;
}
