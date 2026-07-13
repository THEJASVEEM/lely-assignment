import 'package:flutter_test/flutter_test.dart';
import 'package:lely_assignment/feature/activity/data/datasources/activity_datasources.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetRobotActivityDataSource', () {
    test('loads Collector records from bundled JSON asset', () async {
      const dataSource = AssetRobotActivityDataSource();

      final result = await dataSource.loadActivities();

      expect(result, isNotEmpty);
      expect(result.first.date, '08/10/2025');
      expect(result.first.duration, '742 min');
    });
  });
}
