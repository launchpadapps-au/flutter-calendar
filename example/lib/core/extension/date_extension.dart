import 'package:flutter/material.dart';

///dateTime extension
extension DateTimeExtension on DateTime {
  ///firstDay of week
  DateTime get firstDayOfWeek => subtract(Duration(days: weekday - 1));

  ///last day of week
  DateTime get lastDayOfWeek =>
      add(Duration(days: DateTime.daysPerWeek - weekday));

  ///last day of month
  DateTime get lastDayOfMonth =>
      DateTime(year, month + 1).subtract(const Duration(days: 1));

  ///dateTime from the timeOfDat
  static DateTime fromTimeOfDay(TimeOfDay time) {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  ///return true if date is same or after
  bool isAferORSame(DateTime dateTime) =>
      isAtSameMomentAs(dateTime) || isAfter(dateTime);

  ///return true if date is same or before
  bool isBeforeORSame(DateTime dateTime) =>
      isAtSameMomentAs(dateTime) || isBefore(dateTime);
}

///return TimeOfDay from string
TimeOfDay getFromString(String data) {
  final List<String> temp = data.split(':');
  final int hour = int.parse(temp.first);
  final int minute = int.parse(temp[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

////extension on dateTime range
extension DateTimeRangeExtension on DateTimeRange {
  ///return true if given date is between range
  bool isInBetWeen(DateTime dateTime) =>
      dateTime.isAferORSame(start) && dateTime.isBeforeORSame(end);
}
