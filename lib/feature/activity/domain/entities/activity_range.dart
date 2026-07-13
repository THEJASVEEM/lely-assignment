enum ActivityRange { oneWeek, oneMonth, threeMonths, sixMonths, oneYear }

extension ActivityRangeLabel on ActivityRange {
  String get label => switch (this) {
    ActivityRange.oneWeek => '1W',
    ActivityRange.oneMonth => '1M',
    ActivityRange.threeMonths => '3M',
    ActivityRange.sixMonths => '6M',
    ActivityRange.oneYear => '1Y',
  };
}
