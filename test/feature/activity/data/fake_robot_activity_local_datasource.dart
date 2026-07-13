import 'package:lely_assignment/feature/activity/data/datasources/robot_activity_local_datasource.dart';
import 'package:lely_assignment/feature/activity/data/models/robot_activity_dto.dart';

class FakeRobotActivityLocalDataSource implements RobotActivityLocalDataSource {
  FakeRobotActivityLocalDataSource(this.activities);

  final List<RobotActivityDto> activities;
  int loadCallCount = 0;

  @override
  Future<List<RobotActivityDto>> loadActivities() async {
    loadCallCount++;
    return activities;
  }
}
