import 'package:lely_assignment/feature/activity/domain/entities/add_activity_result.dart';
import 'package:lely_assignment/feature/activity/domain/entities/robot_activity.dart';

abstract interface class RobotActivityRepository {
  Future<List<RobotActivity>> getActivities();

  Future<AddActivityResult> addActivity(RobotActivity activity);
}
