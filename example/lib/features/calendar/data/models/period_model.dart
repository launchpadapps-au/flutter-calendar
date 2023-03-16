// To parse this JSON data, do
//
//     final periodModel = periodModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///create lsit of object from the json encoded string

List<PeriodModel> periodModelFromJson(String str) => List<PeriodModel>.from(
    json.decode(str).map((dynamic x) => PeriodModel.fromJson(x)));

///create json encoded string from the list of the object
String periodModelToJson(List<PeriodModel> data) =>
    json.encode(List<Map<String, dynamic>>.from(
        data.map<Map<String, dynamic>>((PeriodModel x) => x.toJson())));

///PeriodModel class
class PeriodModel implements Period {
  ///initilize the period model
  PeriodModel(
      {required this.id,
      required this.slotName,
      required this.type,
      required this.stringStartTime,
      required this.stringEndTime,
      required this.userId,
      required this.calendarId,
      required this.endTime,
      required this.startTime,
      required this.isCustomeSlot}) {
    title = slotName;
    isCustomeSlot = type != 'period';

    switch (type) {
      case 'before_school':
        title = 'Before School';
        break;
      case 'after_school':
        title = 'After School';
        break;
      case 'break_1':
        title = 'Recess';
        break;
      case 'break_2':
        title = 'Lunch';
        break;

      default:
        final List<String> t = title!.split('_');

        if (t.length == 2) {
          title = '${t[0]} ${t[1]}';
        }
    }
  }

  ///create model from the json
  factory PeriodModel.fromJson(Map<String, dynamic> json) => PeriodModel(
      id: json['id'].toString(),
      slotName: json['slot_name'],
      type: json['type'],
      stringStartTime: json['start_time'],
      stringEndTime: json['end_time'],
      userId: json['user_id'],
      calendarId: json['calendar_id'],
      isCustomeSlot: json['type'] == 'period',
      startTime: parseTimeOfDay(json['start_time']),
      endTime: parseTimeOfDay(json['end_time']));

  ///int id of the period
  @override
  String id;

  ///name of the slot
  String slotName;

  ///type of the slot
  String type;

  ///start time of the slot
  String stringStartTime;

  ///endtime of the slot
  String stringEndTime;

  ///userid od usrt
  String userId;

  ///calendar id for the slot
  dynamic calendarId;

  ///convert json from the object
  @override
  bool isCustomeSlot;

  @override
  String? title;

  @override
  TimeOfDay endTime;

  @override
  TimeOfDay startTime;

  ///return true if break type is before school
  bool get isBeforeSchool => type == 'before_school';

  ///return true if break type is after school
  bool get isAfterSchool => type == 'after_school';

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'slot_name': slotName,
        'type': type,
        'start_time': stringStartTime,
        'end_time': stringEndTime,
        'user_id': userId,
        'calendar_id': calendarId,
        'startTime': startTime.toString(),
        'endTime': endTime.toString(),
        'isCustomeSlot': isCustomeSlot,
        'title': title
      };

  ///create json object from the
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'slot_name': slotName,
        'type': type,
        'start_time': stringStartTime,
        'end_time': stringEndTime,
        'user_id': userId,
        'calendar_id': calendarId,
        'startTime': startTime.toString(),
        'endTime': endTime.toString()
      };
}
