enum ActivityRange { oneWeek, oneMonth, threeMonths }

extension ActivityRangeLabel on ActivityRange {
  String get label => switch (this) {
    ActivityRange.oneWeek => '1W',
    ActivityRange.oneMonth => '1M',
    ActivityRange.threeMonths => '3M',
  };
}
