import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

/// period class for the calendar, it can be use for define custom timeslot in
/// the calendar.period class must be impliment this class to user functionality
class Period {
  /// Period for the timetable
  Period(
      {required this.startTime,
      required this.endTime,
      this.title,
      this.id = 'None',
      this.isCustomeSlot = false}) {
    if (id == 'None') {
      id = startTime.toString();
    }
  }

  ///   objet from the from the json
  factory Period.fromJson(Map<String, dynamic> json) => Period(
        startTime: parseTimeOfDay(json['startTime']),
        endTime: parseTimeOfDay(json['endTime']),
        title: json['title'],
        isCustomeSlot: json['isBreak'],
      );

  ///Start Time
  TimeOfDay startTime;

  ///End Time
  TimeOfDay endTime;

  /// String title
  String? title;

  /// if this period is break then make this variable true
  /// and pass title of the break
  bool isCustomeSlot = false;

  ///id of the period,in cas eof customization
  String id;

  ///to map functionality

  Map<String, dynamic> get toMap => <String, dynamic>{
        'startTime': startTime,
        'endTime': endTime,
        'title': title,
        'isBreak': isCustomeSlot
      };

  /// return json object

  Map<String, dynamic> toJson() => <String, dynamic>{
        'startTime': startTime.toString(),
        'endTime': endTime.toString(),
        'title': title,
        'isBreak': isCustomeSlot
      };

// DateTime get nowDate{
//   DateTime now=DateTime.now();
//  return DateTime(now.year, now.month, now.day, time.hour, time.minute);
// }
}
