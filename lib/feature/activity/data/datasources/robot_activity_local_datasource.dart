import 'package:lely_assignment/feature/activity/data/models/robot_activity_dto.dart';

abstract interface class RobotActivityLocalDataSource {
  Future<List<RobotActivityDto>> loadActivities();
}
