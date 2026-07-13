class RobotActivityDto {
  const RobotActivityDto({required this.date, required this.duration});

  final String date;
  final String duration;

  factory RobotActivityDto.fromJson(Map<String, dynamic> json) {
    return RobotActivityDto(
      date: json['date'] as String,
      duration: json['duration'] as String,
    );
  }
}
