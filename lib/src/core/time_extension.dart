import 'package:flutter/material.dart';

///dateTime from the timeOfDat
bool isSame(TimeOfDay time, TimeOfDay time2) =>
    time.hour == time2.hour && time.minute == time2.minute;

///dateTime from the timeOfDat
bool isNotSame(TimeOfDay time, TimeOfDay time2) {
  if (time.hour != time2.hour) {
    return true;
  } else if (time.minute != time2.minute) {
    return true;
  } else {
    return false;
  }
}

///extension on datetinme
extension DateTimeExtension on DateTime {
  ///get TimeOfDay

  TimeOfDay get getTime => TimeOfDay(hour: hour, minute: minute);
}

///extension on timeoftheday
extension TimeExtension on TimeOfDay {
  /// return true if time is same
  bool isSame(TimeOfDay time) => hour == time.hour && minute == time.minute;

  ///dateTime from the timeOfDat
  bool isNotSame(TimeOfDay time) {
    if (time.hour != hour) {
      return true;
    } else if (time.minute != minute) {
      return true;
    } else {
      return false;
    }
  }
}
