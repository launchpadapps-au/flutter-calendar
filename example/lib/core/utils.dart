import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///return formatted tine
String getFormattedTime(Period period, BuildContext context) =>
    '${period.startTime.format(context)}'
    ' - ${period.endTime.format(context)}';

///return true if date is same
bool isSameDate(DateTime date) {
  final DateTime now = DateTime.now();
  if (now.year == date.year && now.month == date.month && now.day == date.day) {
    return true;
  } else {
    return false;
  }
}

///return dayName for the index

String getWeekDay(int index) {
  switch (index) {
    case 0:
      return 'Monday';
    case 1:
      return 'Tuesday';
    case 2:
      return 'Wednesday';
    case 3:
      return 'Thursday';
    case 4:
      return 'Friday';
    case 5:
      return 'Saturday';
    case 6:
      return 'Sunday';
    default:
      return 'Day';
  }
}

/// bool true if side Strip is available

bool isSideStripsAvailable(CalendarViewType viewType) {
  if (viewType == CalendarViewType.dayView ||
      viewType == CalendarViewType.weekView ||
      viewType == CalendarViewType.monthView ||
      viewType == CalendarViewType.termView) {
    return true;
  } else {
    return false;
  }
}

///get the month list for current year
List<DateTime> getMonth() {
  final DateTime now = DateTime.now();
  return <DateTime>[
    DateTime(
      now.year,
    ),
    DateTime(now.year, 2),
    DateTime(now.year, 3),
    DateTime(now.year, 4),
    DateTime(now.year, 5),
    DateTime(now.year, 6),
    DateTime(now.year, 7),
    DateTime(now.year, 8),
    DateTime(now.year, 9),
    DateTime(now.year, 10),
    DateTime(now.year, 11),
    DateTime(now.year, 12)
  ];
}
