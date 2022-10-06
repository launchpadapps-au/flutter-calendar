// To parse this JSON data, do
//
//     final calendarModel = calendarModelFromJson(jsonString);

import 'dart:convert';

import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';

///create calendar model from the json encoded string
CalendarModel calendarModelFromJson(String str) =>
    CalendarModel.fromJson(json.decode(str));

///create json encoded string from the  object
String calendarModelToJson(CalendarModel data) => json.encode(data.toJson());

///CalendarModel
class CalendarModel {
  ///initilize the calendar model
  CalendarModel({
    required this.name,
    required this.id,
    required this.scheduleSettings,
    required this.calendarSlots,
  });

  ///create object from the json
  factory CalendarModel.fromJson(Map<String, dynamic> json) => CalendarModel(
        name: json['name'],
        id: json['id'],
        scheduleSettings: List<ScheduleSetting>.from(json['schedule_settings']
          ..map<Map<String, dynamic>>(
              (Map<String, dynamic> x) => ScheduleSetting.fromJson(x))),
        calendarSlots: List<PeriodModel>.from(json['calendar_slots']
          ..map<Map<String, dynamic>>(
              (Map<String, dynamic> x) => PeriodModel.fromJson(x))),
      );

  ///school name
  String name;

  ///school id
  int id;

  ///school schedule setting
  List<ScheduleSetting> scheduleSettings;

  ///list of period
  List<PeriodModel> calendarSlots;

  ///create json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        'schedule_settings': List<dynamic>.from(scheduleSettings
            .map<Map<String, dynamic>>((ScheduleSetting x) => x.toJson())),
        'calendar_slots': List<dynamic>.from(calendarSlots
          ..map<Map<String, dynamic>>((PeriodModel x) => x.toJson())),
      };
}

///schdule setting model

class ScheduleSetting {
  ///initilize the model
  ScheduleSetting({
    this.dayStartTime,
    this.dayEndTime,
    this.id,
    this.durationOfEachSession,
  });

  ///create object from the json
  factory ScheduleSetting.fromJson(Map<String, dynamic> json) =>
      ScheduleSetting(
        dayStartTime: json['day_start_time'],
        dayEndTime: json['day_end_time'],
        id: json['id'],
        durationOfEachSession: json['duration_of_each_session'],
      );

  ///day start time
  String? dayStartTime;

  ///day end time
  dynamic dayEndTime;

  ///id of the setting
  String? id;

  ///duration of the each sessiomn
  int? durationOfEachSession;

  ///create json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'day_start_time': dayStartTime,
        'day_end_time': dayEndTime,
        'id': id,
        'duration_of_each_session': durationOfEachSession,
      };
}
