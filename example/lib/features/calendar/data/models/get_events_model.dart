// To parse this JSON data, do
//
//     final getEvents = getEventsFromJson(jsonString);

import 'dart:convert';

import 'package:edgar_planner_calendar_flutter/core/extension/date_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/extension/string_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

// ///get events from json encoded string
// GetEvents getEventsFromJson(String str) =>
// GetEvents.fromJson(json.decode(str));

///get events from json encoded string
GetEvents getEventsFromJsonWithPEriod(String str, List<PeriodModel> periods) =>
    GetEvents.fromJsonWithPeriod(json.decode(str), periods);

///convert to json encoded string
String getEventsToJson(GetEvents data) => json.encode(data.toJson());

///get events from native apps
class GetEvents {
  ///
  GetEvents({
    required this.events,
  });

  // ///create object from the json
  // factory GetEvents.fromJson(Map<String, dynamic> json) => GetEvents(
  //       events: List<PlannerEvent>.from(json['events']
  //           .map((Map<String, dynamic> x) => PlannerEvent.fromJson(x))),
  //     );

  ///create object from the json iwth period
  factory GetEvents.fromJsonWithPeriod(
          Map<String, dynamic> json, List<PeriodModel> periods) =>
      GetEvents(
        events: List<PlannerEvent>.from(json['events']
            .map((dynamic x) => PlannerEvent.fromJsonWithPeriod(x, periods))),
      );

  ///list of the events

  List<PlannerEvent> events;

  ///convert to json object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'events': List<dynamic>.from(
            events.map<dynamic>((PlannerEvent x) => x.toJson())),
      };
}

///event data model
class PlannerEvent implements CalendarEvent<EventData> {
  ///initialize event model
  PlannerEvent({
    required this.startTime,
    required this.endTime,
    required this.eventData,
    this.id,
  });

  // ///create event object from the json
  // factory PlannerEvent.fromJson(Map<String, dynamic> json) {
  //   final start = DateTime.parse(json['start_date']);
  //   final end = DateTime.parse(json['end_date']);
  //   final DateTime a = DateFormat('h:mm a').parse(json['start_time']);

  //   final TimeOfDay startTime = TimeOfDay.fromDateTime(a);
  //   final DateTime b = DateFormat('h:mm a').parse(json['end_time']);

  //   final TimeOfDay endTime = TimeOfDay.fromDateTime(b);
  //   return PlannerEvent(
  //     id: json['id'],
  //     startTime: DateTime(
  //         start.year, start.month, start.day, startTime.hour,
  // startTime.minute),
  //     endTime:
  //         DateTime(end.year, end.month, end.day, endTime.hour,
  // endTime.minute),
  //     eventData: EventData.fromJson(json['eventData']),
  //   );
  // }

  ///create event object from the json
  factory PlannerEvent.fromJsonWithPeriod(
      Map<String, dynamic> json, List<PeriodModel> periods) {
    final DateTime start = DateTime.parse(json['start_date']);
    final DateTime end = DateTime.parse(json['end_date']);

    final TimeOfDay startTime = getFromString(json['start_time']);

    final TimeOfDay endTime = getFromString(json['end_time']);

    return PlannerEvent(
      id: json['id'].toString(),
      startTime: DateTime(
          start.year, start.month, start.day, startTime.hour, startTime.minute),
      endTime:
          DateTime(end.year, end.month, end.day, endTime.hour, endTime.minute),
      eventData: EventData.fromJsonWithPeriod(json, periods),
    );
  }

  ///id of the event
  String? id;

  ///start time of the event
  @override
  DateTime startTime;

  ///end time of the event
  @override
  DateTime endTime;

  ///event data
  @override
  EventData? eventData;

  ///convert object to json
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'startTime': "${startTime.year.toString().padLeft(4, '0')}-"
            "${startTime.month.toString().padLeft(2, '0')}-"
            "${startTime.day.toString().padLeft(2, '0')}",
        'endTime': "${endTime.year.toString().padLeft(4, '0')}-"
            "${endTime.month.toString().padLeft(2, '0')}-"
            "${endTime.day.toString().padLeft(2, '0')}",
        'eventData': eventData!.toJson(),
      };

  @override
  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'startTime': startTime,
        'endTime': endTime,
        'eventData': eventData!.toJson(),
      };

  @override
  String toString() => toJson().toString();
}

///convert color to hex value

extension ColorExtension on Color {
  ///convert color to hex

  String toHex() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

///event data class
class EventData {
  // ///create object from the json
  // factory EventData.fromJson(Map<String, dynamic> json) => EventData(
  //       id: json['id'],
  //       title: json['title'],
  //       location: json['location'],
  //       subjectId: json['subject_id'],
  //       startDate: DateTime.parse(json['start_date']),
  //       endDate: DateTime.parse(json['end_date']),
  //       startTime: json['start_time'],
  //       endTime: json['end_time'],
  //       remindBefore: json['remind_before'],
  //       reminderEnabled: json['reminder_enabled'],
  //       slots: json['slots'],
  //       recurrenceUntil: json['recurrence_until'],
  //       recurringEventId: json['recurring_event_id'],
  //       recurrenceFreq: json['recurrence_freq'],
  //       type: json['type'],
  //       updatedAt: DateTime.parse(json['updated_at']),
  //       lessonPlans: List<dynamic>.from(
  //           json['lesson_plans'].map<dynamic>((dynamic x) => x)),
  //       googleDriveFiles: List<dynamic>.from(
  //           json['google_drive_files'].map<dynamic>((dynamic x) => x)),
  //       eventLinks: json['event_links'],
  //     );
  ///initialize the event
  EventData({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.reminderEnabled,
    required this.slots,
    required this.type,
    required this.updatedAt,
    required this.lessonPlans,
    required this.googleDriveFiles,
    required this.calendarSlot,
    this.event,
    // required this.period,
    this.subject,
    this.color = darkestGrey,
    this.freeTime = false,
    this.isDutyTime = false,
    this.remindBefore,
    this.recurrenceUntil,
    this.recurringEventId,
    this.recurrenceFreq,
    this.eventLinks,
    this.extraCurricular,
    this.description,
  }) {
    if (type == 'freetime') {
      title = 'Non-Teaching Time';
      freeTime = true;
      isDutyTime = false;
      color = const Color(0xFFCBCE42).withOpacity(0.58);
    } else if (type == 'duty') {
      color = const Color(0xFFE0E0E0);
      isDutyTime = true;
      freeTime = false;
      title = 'Duty - $location';
    } else if (type == 'lesson') {
      if (subject != null) {
        color = subject!.colorCode;
      }
    }
  }

  ///create object from the json
  factory EventData.fromJsonWithPeriod(
      Map<String, dynamic> jsonData, List<PeriodModel> periods) {
    try {
      final Iterable<PeriodModel> ps = periods.where((PeriodModel element) =>
          element.id.toString() == jsonData['slots'].toString());
      if (ps.isNotEmpty) {
      } else {}
    } on Exception catch (e) {
      logInfo('Error: $e');
      final Map<String, dynamic> data = <String, dynamic>{
        'id': 62,
        'calendar_id': 32,
        'user_id': '92673d4e-c2f3-48d8-9da6-5c452f40b3fa',
        'slot_name': 'period_6',
        'type': 'period',
        'start_time': jsonData['start_time'],
        'end_time': jsonData['end_time']
      };
      PeriodModel.fromJson(data);
    }

    return EventData(
        id: jsonData['id'].toString(),
        title: jsonData['title'],
        location: jsonData['location'],
        subject: jsonData['subject'] == null
            ? null
            : Subject.fromJson(jsonData['subject']),
        event: jsonData['event'] == null
            ? null
            : EdgarEvent.fromJson(jsonData['event']),
        startDate: DateTime.parse(jsonData['start_date']),
        endDate: DateTime.parse(jsonData['end_date']),
        startTime: jsonData['start_time'],
        endTime: jsonData['end_time'],
        remindBefore: jsonData['remind_before'],
        reminderEnabled: jsonData['reminder_enabled'],
        slots: jsonData['slots'].toString(),
        // period: periodModel,
        recurrenceUntil: jsonData['recurrence_until'],
        recurringEventId: jsonData['recurring_event_id'],
        recurrenceFreq: jsonData['recurrence_freq'],
        type: jsonData['type'],
        updatedAt: DateTime.parse(jsonData['updated_at']),
        lessonPlans: List<dynamic>.from(
            jsonData['lesson_plans'].map<dynamic>((dynamic x) => x)),
        googleDriveFiles: jsonData['google_drive_files'] == null
            ? <GoogleDriveFile>[]
            : List<GoogleDriveFile>.from(json
                .decode(jsonData['google_drive_files'])
                .map((dynamic x) => GoogleDriveFile.fromJson(x))),
        eventLinks: jsonData['event_links'],
        extraCurricular: jsonData['extra_curricular'],
        description: jsonData['description'],
        calendarSlot: CalendarSlot.fromJson(jsonData['calendar_slot']));
  }

  ///if type is lesson then return true
  bool get isDraggable => type == 'lesson';

  ///if type is lesson then return true
  bool get isDuty => type == 'duty';

  ///if type is lesson then return true
  bool get isFreeTime => type == 'freetime';

  ///if type is lesson then return true
  bool get isLesson => type == 'lesson';

  ///id of the event
  dynamic id;

  ///event title
  String title;

  ///event location
  String? location;

  ///subject id
  Subject? subject;

  ///start date of the evebt
  DateTime startDate;

  ///enddate of the event
  DateTime endDate;

  ///start time of the event
  String startTime;

  ///end time of the event
  String endTime;

  //// reminder duration
  dynamic remindBefore;

  ///reminder setting
  bool reminderEnabled;

  ///slot number
  String slots;

  // ///Period model of the events
  // Period period;

  ///if event is freetime
  bool freeTime;

  ///bool is duty time
  bool isDutyTime;

  ///Event color
  Color color;

  ///reccurence untill
  dynamic recurrenceUntil;

  ///recurring event id
  dynamic recurringEventId;

  ///recuring event frequency
  dynamic recurrenceFreq;

  ///string type of the event
  String type;

  ///last updated at
  DateTime updatedAt;

  ///lesson plan of the event
  List<dynamic> lessonPlans;

  ///list of google drive url
  List<dynamic> googleDriveFiles;

  ///any external link for the event
  dynamic eventLinks;

  ///object of the edgar event
  EdgarEvent? event;

  ///icon of the extra curriculer extivity
  String? extraCurricular;

  ///description for the the freetime
  String? description;

  ///Calendar slot for the event
  CalendarSlot calendarSlot;

  ///convert json object from the model
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'location': location,
        'subject': subject,
        'start_date': "${startDate.year.toString().padLeft(4, '0')}-"
            "${startDate.month.toString().padLeft(2, '0')}-"
            "${startDate.day.toString().padLeft(2, '0')}",
        'end_date': "${endDate.year.toString().padLeft(4, '0')}-"
            "${endDate.month.toString().padLeft(2, '0')}-"
            "${endDate.day.toString().padLeft(2, '0')}",
        'start_time': startTime,
        'end_time': endTime,
        'remind_before': remindBefore,
        'reminder_enabled': reminderEnabled,
        'slots': slots,
        'event': event == null ? <String, dynamic>{} : event!.toJson(),
        'recurrence_until': recurrenceUntil,
        'recurring_event_id': recurringEventId,
        'recurrence_freq': recurrenceFreq,
        'type': type,
        'updated_at': updatedAt.toIso8601String(),
        'lesson_plans':
            List<dynamic>.from(lessonPlans.map<dynamic>((dynamic x) => x)),
        'google_drive_files': List<dynamic>.from(
            googleDriveFiles.map<dynamic>((dynamic x) => x.toJson())),
        'event_links': eventLinks,
        'extra_curricular': extraCurricular
      };
}

///google drive file model
class GoogleDriveFile {
  ///initialize the model
  GoogleDriveFile({
    required this.id,
    required this.name,
    required this.url,
  });

  ///create object from the json
  factory GoogleDriveFile.fromJson(Map<String, dynamic> json) =>
      GoogleDriveFile(
        id: json['id'].toString(),
        name: json['name'].toString(),
        url: json['url'].toString(),
      );

  ///id of the file
  String id;

  ///name eof the file
  String name;

  ///url of the file
  String url;

  ///create json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'url': url,
      };
}

///subject model
class Subject {
  ///initialize the model
  Subject({
    required this.id,
    required this.colorCode,
    required this.subjectName,
  });

  ///cretae object fron the json
  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        colorCode: HexColor(
          json['color_code'],
        ),
        subjectName: json['subject_name'],
      );

  ///id of the subject
  dynamic id;

  ///color of the subject

  Color colorCode;

  ///name of the subject
  String subjectName;

  ///create json from the

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'color_code': colorCode,
        'subject_name': subjectName,
      };
}

///crreate color from the hex

class HexColor extends Color {
  ///initialize the hex

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hex) {
    String hexColor = hex;
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

///Edgar Event model
class EdgarEvent {
  ///initialize the model
  EdgarEvent({
    required this.id,
    required this.isRecurringEvent,
    required this.recurrenceUntil,
    required this.recurrenceFreq,
  });

  ///cretae object fron the json
  factory EdgarEvent.fromJson(Map<String, dynamic> json) => EdgarEvent(
      id: json['id'].toString(),
      isRecurringEvent: json['is_recurring_event'],
      recurrenceUntil: DateTime.parse(json['recurrence_until']),
      recurrenceFreq: json['recurrence_freq']);

  ///id of the subject
  String id;

  ///color of the subject

  bool isRecurringEvent;

  ///recurring until
  DateTime recurrenceUntil;

  ///frequendy of the event
  String recurrenceFreq;

  ///create json from the

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'is_recurring_event': isRecurringEvent,
        'recurrence_until': recurrenceUntil,
        'recurrence_freq': recurrenceFreq,
      };
}

///This will store all data regarding slot

class CalendarSlot {
  ///initialize the slot06
  CalendarSlot({
    required this.id,
    required this.slotName,
    required this.type,
  });

  ///create object from the json encoded string
  factory CalendarSlot.fromRawJson(String str) =>
      CalendarSlot.fromJson(json.decode(str));

  ///create object from json
  factory CalendarSlot.fromJson(Map<String, dynamic> json) => CalendarSlot(
        id: json['id'].toString(),
        slotName: json['slot_name'],
        type: json['type'],
      );

  ///return title based on event typr

  String get getTitle {
    switch (type) {
      case 'before_school':
        return 'Before School';

      case 'after_school':
        return 'After School';
      case 'break_1':
        return 'Recess';

      case 'break_2':
        return 'Lunch';

      default:
        final List<String> t = slotName.split('_');

        return t.join(' ').capitalize;
    }
  }

  ///id of the slot
  final String id;

  ///name of the slot
  final String slotName;

  ///type of the slot
  final String type;

  ///creaye json encoded string from the map
  String toRawJson() => json.encode(toJson());

  ///crate json from the data
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'slot_name': slotName,
        'type': type,
      };
}
