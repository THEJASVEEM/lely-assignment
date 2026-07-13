import 'package:flutter_test/flutter_test.dart';
import 'package:lely_assignment/feature/activity/data/mappers/robot_activity_mapper.dart';
import 'package:lely_assignment/feature/activity/data/models/robot_activity_dto.dart';

void main() {
  group('RobotActivityDtoMapper', () {
    test('maps DTO date and duration to domain entity', () {
      const dto = RobotActivityDto(date: '08/10/2025', duration: '742 min');

      final result = dto.toDomain();

      expect(result.date, DateTime(2025, 10, 8));
      expect(result.durationMinutes, 742);
      expect(result.durationHours, closeTo(12.3, 0.1));
    });

    test('trims duration before parsing', () {
      const dto = RobotActivityDto(date: '09/10/2025', duration: ' 60 min ');

      final result = dto.toDomain();

      expect(result.durationMinutes, 60);
      expect(result.durationHours, 1);
    });

    test('throws FormatException for invalid date', () {
      const dto = RobotActivityDto(date: '2025-10-08', duration: '60 min');

      expect(dto.toDomain, throwsFormatException);
    });

    test('throws FormatException for invalid duration', () {
      const dto = RobotActivityDto(date: '08/10/2025', duration: 'unknown');

      expect(dto.toDomain, throwsFormatException);
    });
  });
}
