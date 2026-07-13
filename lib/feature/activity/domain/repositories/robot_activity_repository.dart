import 'package:lely_assignment/feature/activity/domain/entities/robot_activity.dart';

abstract interface class RobotActivityRepository {
  Future<List<RobotActivity>> getActivities();

  Future<void> addActivity(RobotActivity activity);
}
