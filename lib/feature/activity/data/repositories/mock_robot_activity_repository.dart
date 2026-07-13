import 'package:injectable/injectable.dart';
import 'package:lely_assignment/feature/activity/data/datasources/robot_activity_local_datasource.dart';
import 'package:lely_assignment/feature/activity/data/mappers/robot_activity_mapper.dart';
import 'package:lely_assignment/feature/activity/domain/entities/robot_activity.dart';
import 'package:lely_assignment/feature/activity/domain/repositories/robot_activity_repository.dart';

@LazySingleton(as: RobotActivityRepository)
class MockRobotActivityRepository implements RobotActivityRepository {
  MockRobotActivityRepository(this._localDataSource);

  final RobotActivityLocalDataSource _localDataSource;

  List<RobotActivity>? _cachedActivities;

  @override
  Future<List<RobotActivity>> getActivities() async {
    if (_cachedActivities == null) {
      final dtos = await _localDataSource.loadActivities();

      _cachedActivities = dtos.map((dto) => dto.toDomain()).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }

    return List.unmodifiable(_cachedActivities!);
  }

  @override
  Future<void> addActivity(RobotActivity activity) async {
    final activities = await getActivities();

    _cachedActivities = [...activities, activity]
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
