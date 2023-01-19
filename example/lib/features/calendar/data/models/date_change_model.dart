///model for the date change methods,it will convert data that we received
///from native app when they wan to change start date and end date
import 'dart:convert';

///return DateChange object from string
DateChange changeDateFromJson(String str) =>
    DateChange.fromJson(json.decode(str));

///
String changeDateToJson(DateChange data) => json.encode(data.toJson());

///date change class
class DateChange {
  ///initialized date change class
  DateChange({
    required this.startTime,
    required this.endTime,
  });

  ///return DateChange object from json
  factory DateChange.fromJson(Map<String, dynamic> json) => DateChange(
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
      );

  ///start date
  DateTime startTime;

  ///end date
  DateTime endTime;

  ///convert dateChange object to json
  Map<String, dynamic> toJson() => <String, dynamic>{
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };
}
