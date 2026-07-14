import 'package:flutter_test/flutter_test.dart';
import 'package:lely_assignment/feature/activity/data/models/robot_activity_dto.dart';
import 'package:lely_assignment/feature/activity/data/repositories/mock_robot_activity_repository.dart';
import 'package:lely_assignment/feature/activity/domain/entities/add_activity_result.dart';
import 'package:lely_assignment/feature/activity/domain/entities/robot_activity.dart';

import '../fake_robot_activity_local_datasource.dart';

void main() {
  late FakeRobotActivityLocalDataSource dataSource;
  late MockRobotActivityRepository repository;

  setUp(() {
    dataSource = FakeRobotActivityLocalDataSource([
      const RobotActivityDto(date: '10/10/2025', duration: '120 min'),
      const RobotActivityDto(date: '08/10/2025', duration: '60 min'),
      const RobotActivityDto(date: '09/10/2025', duration: '90 min'),
    ]);

    repository = MockRobotActivityRepository(dataSource);
  });

  group('MockRobotActivityRepository', () {
    test('loads, maps, and sorts activities by date', () async {
      final result = await repository.getActivities();

      expect(result, hasLength(3));
      expect(result[0].date, DateTime(2025, 10, 8));
      expect(result[1].date, DateTime(2025, 10, 9));
      expect(result[2].date, DateTime(2025, 10, 10));
      expect(result[0].durationMinutes, 60);
    });

    test('loads from data source only once', () async {
      await repository.getActivities();
      await repository.getActivities();

      expect(dataSource.loadCallCount, 1);
    });

    test('adds activity and keeps collection sorted', () async {
      await repository.addActivity(
        RobotActivity(date: DateTime(2025, 10, 7), durationMinutes: 45),
      );

      final result = await repository.getActivities();

      expect(result, hasLength(4));
      expect(result.first.date, DateTime(2025, 10, 7));
      expect(result.first.durationMinutes, 45);
    });

    test('added activity remains available during the session', () async {
      await repository.addActivity(
        RobotActivity(date: DateTime(2025, 10, 11), durationMinutes: 180),
      );

      final firstResult = await repository.getActivities();
      final secondResult = await repository.getActivities();

      expect(firstResult, hasLength(4));
      expect(secondResult, hasLength(4));
      expect(dataSource.loadCallCount, 1);
    });
    test('rejects a duplicate activity date', () async {
      final result = await repository.addActivity(
        RobotActivity(date: DateTime(2025, 10, 8), durationMinutes: 300),
      );

      expect(result, isA<DuplicateActivityDate>());

      final activities = await repository.getActivities();
      expect(activities, hasLength(3));
    });

    test('normalizes the date before duplicate comparison', () async {
      final result = await repository.addActivity(
        RobotActivity(
          date: DateTime(2025, 10, 8, 18, 30),
          durationMinutes: 300,
        ),
      );

      expect(result, isA<DuplicateActivityDate>());
    });
  });
}
