// To parse this JSON data, do
//
//     final changeView = changeViewFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_calendar/flutter_calendar.dart';

///object from json string
ChangeView changeViewFromJson(String str) =>
    ChangeView.fromJson(json.decode(str));

///
String changeViewToJson(ChangeView data) => json.encode(data.toJson());

///change view
class ChangeView {
  ///initialized change view
  ChangeView({
    required this.viewType,
  });

  ///create object from the json
  factory ChangeView.fromJson(Map<String, dynamic> json) => ChangeView(
          viewType: getCalendarViewString(
        json['viewType'],
      ));

  ///calendar view type
  CalendarViewType viewType;

  ///convert to json
  Map<String, dynamic> toJson() => <String, dynamic>{
        'viewType': viewType,
      };
}
