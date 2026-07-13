class RobotActivity {
  const RobotActivity({required this.date, required this.durationMinutes});

  final DateTime date;
  final int durationMinutes;

  double get durationHours => durationMinutes / 60;
}
