import 'package:intl/intl.dart';

import '../../domain/entities/robot_activity.dart';
import '../models/robot_activity_dto.dart';

extension RobotActivityDtoMapper on RobotActivityDto {
  RobotActivity toDomain() {
    final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);

    final parsedDurationMinutes = int.parse(
      duration.replaceAll('min', '').trim(),
    );

    return RobotActivity(
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      durationMinutes: parsedDurationMinutes,
    );
  }
}
