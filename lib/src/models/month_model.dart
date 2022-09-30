/// CalendarDay datatype it contain date and and deadCell info
class CalendarDay {
  ///initialized calendar day
  CalendarDay({required this.dateTime, this.deadCell = false});

  ///bool is deadCell
  bool deadCell;

  ///
  /// DateTime
  DateTime dateTime;

  @override
  String toString() => 'DeadCell $deadCell' ' DateTime: $dateTime';
}
