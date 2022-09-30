/// month class
class Month {
  ///month constructor
  Month(
      {required this.month,
      required this.monthName,
      required this.endDay,
      required this.startDay,
      required this.year});

  /// int month
  int month;

  ///int year
  int year;

  ///int startDay
  int startDay;

  ///int endDay
  int endDay;

  /// monthName
  String monthName;

  @override
  String toString() => 'Month Name $monthName Month $month StartDay $startDay'
      ' EndDay $endDay $year';
}
