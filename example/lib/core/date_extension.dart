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
}

///return TimeOfDay from string
TimeOfDay getFromString(String data) {
  final List<String> temp = data.split(':');
  final int hour = int.parse(temp.first);
  final int minute = int.parse(temp[1]);
  return TimeOfDay(hour: hour, minute: minute);
}
