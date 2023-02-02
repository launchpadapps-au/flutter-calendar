// To parse this JSON data, do
//
//     final exportSetting = exportSettingFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_calendar/flutter_calendar.dart';
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
    required this.startDate,
    required this.endDate,
    required this.view,
    required this.fullWeek,
    required this.pageFormat,
    required this.path,
    required this.subjectId,
    required this.subjectName,
    this.allSubject = true,
    this.saveImg = false,
  });

  ///create object from the json
  factory ExportSetting.fromJson(Map<String, dynamic> json) => ExportSetting(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      view: viewTypeFromString(json['view']),
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      fullWeek: json['fullWeek'],
      allSubject: json['allSubject'],
      pageFormat: PdfPageFormat.a4.landscape.copyWith(
          marginLeft: 10, marginRight: 10, marginTop: 0, marginBottom: 10),
      path: json['path']);

  ///starting date
  DateTime startDate;

  ///end date
  DateTime endDate;

  ///list of calendar view that need to export
  CalendarViewType view;

  ///id of subject that need to export
  String subjectId;

  ///name of subject that need to export
  String subjectName;

  ///true if want to export week end
  bool fullWeek;

  ///true if want to export all subject
  bool allSubject;

  ///true if want to save img
  bool saveImg;

  ///page formart
  PdfPageFormat pageFormat = PdfPageFormat.a4.landscape;

  ///String path of the local storage
  String path;

  ///create json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'startFrom': startDate.toIso8601String(),
        'endTo': endDate.toIso8601String(),
        'view': view.toString(),
        'subjects': subjectId,
        'subjectName': subjectName,
        'fullWeek': fullWeek,
        'allSubject': allSubject,
        'path': path
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
