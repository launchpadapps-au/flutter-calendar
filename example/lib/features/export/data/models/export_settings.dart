// To parse this JSON data, do
//
//     final exportSetting = exportSettingFromJson(jsonString);

import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

import 'dart:convert';

import 'package:pdf/pdf.dart';

///create export setting from json encoded from string
ExportSetting exportSettingFromJson(String str) =>
    ExportSetting.fromJson(json.decode(str));

///create json encoded string from object
String exportSettingToJson(ExportSetting data) => json.encode(data.toJson());

////export setting class
class ExportSetting {
  ///initilize the setting
  ExportSetting({
    required this.startFrom,
    required this.endTo,
    required this.view,
    required this.subjects,
    required this.fullWeek,
    required this.pageFormat,
    this.saveImg = false,
  });

  ///create object from the json
  factory ExportSetting.fromJson(Map<String, dynamic> json) => ExportSetting(
      startFrom: DateTime.parse(json['startFrom']),
      endTo: DateTime.parse(json['endTo']),
      view: List<CalendarViewType>.from(
          json['view'].map((String x) => viewTypeFromString(x))),
      subjects: List<Subject>.from(json['subjects']
          .map((Map<String, dynamic> x) => Subject.fromJson(x))),
      fullWeek: json['fullWeek'],
      pageFormat: PdfPageFormat.a4.landscape,
      saveImg: json['saveImg']);

  ///starting date
  DateTime startFrom;

  ///end date
  DateTime endTo;

  ///list of calendar view that need to export
  List<CalendarViewType> view;

  ///list of subject that need to export
  List<Subject> subjects;

  ///true if want to export week end
  bool fullWeek;

  ///true if want to save img
  bool saveImg;

  ///page formart
  PdfPageFormat pageFormat = PdfPageFormat.a4.landscape;

  ///create json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'startFrom': startFrom.toIso8601String(),
        'endTo': endTo.toIso8601String(),
        'view': List<String>.from(
            view.map<String>((CalendarViewType x) => x.toString())),
        'subjects': List<Map<String, dynamic>>.from(
            subjects.map<Map<String, dynamic>>((Subject x) => x.toJson())),
        'fullWeek': fullWeek,
        'saveImg': saveImg
      };
}

///return view based on string
CalendarViewType viewTypeFromString(String type) {
  switch (type) {
    case 'CalendarViewType.weekView':
      return CalendarViewType.weekView;
    case 'CalendarViewType.dayView':
      return CalendarViewType.dayView;
    case 'CalendarViewType.monthView':
      return CalendarViewType.monthView;
    default:
      return CalendarViewType.dayView;
  }
}
