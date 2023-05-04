// To parse this JSON data, do
//
//     final getNotes = getNotesFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_calendar/flutter_calendar.dart';

///This class will convert list of[Note] from the given json
class GetNotes {
  ///initialize the note
  GetNotes({
    required this.note,
  });

  ///create object from the json
  factory GetNotes.fromJson(Map<String, dynamic> json) => GetNotes(
        note: json['note'] == null
            ? <CalendarEvent<Note>>[]
            : List<CalendarEvent<Note>>.from(
                json['note']!.map<CalendarEvent<Note>>((dynamic x) {
                final Note note = Note.fromJson(x);
                return CalendarEvent<Note>(
                    startTime: note.startDate,
                    endTime: note.endDate,
                    eventData: note);
              })),
      );

  ///create object from json encoded string

  factory GetNotes.fromRawJson(String str) =>
      GetNotes.fromJson(json.decode(str));

  ///List of the [Note]
  final List<CalendarEvent<Note>> note;

  ///create json from the  object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'note': List<dynamic>.from(note
            .map<dynamic>((CalendarEvent<Note>? x) => x!.eventData!.toJson())),
      };
}

///This model contain data of the Note
class Note {
  ///initilize the note
  Note({
    required this.id,
    required this.slots,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.endDate,
    required this.type,
    required this.title,
    required this.description,
  });

////create object from the json
  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'].toString(),
        slots: json['slots'],
        startDate: DateTime.parse(json['start_date']),
        startTime: json['start_time'],
        endTime: json['end_time'],
        endDate: DateTime.parse(json['end_date']),
        type: typeValues.map[json['type']] ?? NoteType.month,
        title: json['title'],
        description: json['description'],
      );

  ///crate note from the json encoded string
  factory Note.fromRawJson(String str) => Note.fromJson(json.decode(str));

  ///id of the note
  final String id;

  ///slot of the note
  final dynamic slots;

  ///start date of the note
  final DateTime startDate;

  ///start time of not
  final String startTime;

  ///end time of the note
  final String endTime;

  ///end date of the note
  final DateTime endDate;

  ///type of the note
  final NoteType type;

  ///title of note
  final String title;

  ///description of note
  final String description;

  ///create new object from existing
  Note copyWith({
    String? id,
    dynamic slots,
    DateTime? startDate,
    String? startTime,
    String? endTime,
    DateTime? endDate,
    NoteType? type,
    String? title,
    String? description,
  }) =>
      Note(
        id: id ?? this.id,
        slots: slots ?? this.slots,
        startDate: startDate ?? this.startDate,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        endDate: endDate ?? this.endDate,
        type: type ?? this.type,
        title: title ?? this.title,
        description: description ?? this.description,
      );

  ///create json encoded string from the object
  String toRawJson() => json.encode(toJson());

  ///create json fro the object

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'slots': slots,
        'start_date': startDate.toString().substring(0, 12),
        'start_time': startTime,
        'end_time': endTime,
        'end_date': endDate.toString().substring(0, 12),
        'type': typeValues.reverse![type],
        'title': title,
        'description': description,
      };
}

///type of the note
enum NoteType {
  ///This type will only display note in the month and term view
  month
}

///retunr enum based oon map
final EnumValues<NoteType> typeValues =
    EnumValues<NoteType>(<String, NoteType>{'month': NoteType.month});

///hold enum value
class EnumValues<NoteType> {
  ///initilize enum value
  EnumValues(this.map);

  ///map of the note
  Map<String, NoteType> map;

  ///reverse map of the note
  Map<NoteType, String>? reverseMap;

  ///return revers map
  Map<NoteType, String>? get reverse => reverseMap ??=
      map.map((String k, NoteType v) => MapEntry<NoteType, String>(v, k));
}
