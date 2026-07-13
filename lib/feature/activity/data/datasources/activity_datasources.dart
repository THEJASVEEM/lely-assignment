import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:lely_assignment/feature/activity/data/datasources/robot_activity_local_datasource.dart';
import 'package:lely_assignment/feature/activity/data/models/robot_activity_dto.dart';

@LazySingleton(as: RobotActivityLocalDataSource)
class AssetRobotActivityDataSource implements RobotActivityLocalDataSource {
  const AssetRobotActivityDataSource();

  static const _assetPath = 'assets/data/sample_data.json';

  @override
  Future<List<RobotActivityDto>> loadActivities() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    final collectorData = json['Collector'] as List<dynamic>;

    return collectorData
        .map((item) => RobotActivityDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
