///model for the date change methods,it will convert data that we received
///from native app when they wan to change start date and end date
import 'dart:convert';

///return JumpToDateModel object from string
JumpToDateModel jumpToDateFromJson(String str) =>
    JumpToDateModel.fromJson(json.decode(str));

///
String changeDateToJson(JumpToDateModel data) => json.encode(data.toJson());

///JumpToDateModel class
class JumpToDateModel {
  ///initialized date change class
  JumpToDateModel({
    required this.date,
  });

  ///return DateChange object from json
  factory JumpToDateModel.fromJson(Map<String, dynamic> json) =>
      JumpToDateModel(
        date:
        json['date'] == '' ? DateTime.now() : DateTime.parse(json['date']),
      );

  ///start date
  DateTime date;

  ///convert dateChange object to json
  Map<String, dynamic> toJson() =>
      <String, dynamic>{
        'date': date.toIso8601String(),
      };
}
