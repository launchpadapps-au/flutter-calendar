// To parse this JSON data, do
//
//     final getEvents = getEventsFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///get events from json encoded string
GetEvents getEventsFromJson(String str) => GetEvents.fromJson(json.decode(str));

///convert to json encoded string
String getEventsToJson(GetEvents data) => json.encode(data.toJson());

///get events from native apps
class GetEvents {
  ///
  GetEvents({
    required this.events,
  });

  ///create object from the json
  factory GetEvents.fromJson(Map<String, dynamic> json) => GetEvents(
        events: List<PlannerEvent>.from(json['events']
            .map((Map<String, dynamic> x) => PlannerEvent.fromJson(x))),
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

  ///create event object from the json
  factory PlannerEvent.fromJson(Map<String, dynamic> json) => PlannerEvent(
        id: json['id'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        eventData: EventData.fromJson(json['eventData']),
      );

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
        'startTime': "${startTime.year.toString().padLeft(4, '0')}-"
            "${startTime.month.toString().padLeft(2, '0')}-"
            "${startTime.day.toString().padLeft(2, '0')}",
        'endTime': "${endTime.year.toString().padLeft(4, '0')}-"
            "${endTime.month.toString().padLeft(2, '0')}-"
            "${endTime.day.toString().padLeft(2, '0')}",
        'eventData': eventData!.toJson(),
      };

  @override
  String toString() => toJson().toString();
}

///event data for the events
class EventData {
  ///initialize event data
  EventData(
      {required this.title,
      required this.description,
      required this.period,
      required this.color,
      required this.documents,
      this.freeTime = false});

  ///initialized event data from the json
  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
        title: json['title'],
        description: json['description'],
        period: Period.fromJson(json['period']),
        color: Color(int.parse("0xFF{$json['color']}")),
        freeTime: json['freeTime'],
        documents: List<Document>.from(json['documents']
            .map((Map<String, dynamic> x) => Document.fromJson(x))),
      );

  ///string title
  String title;

  ///string description
  String description;

  ///  periods of the table
  Period period;

  ///color of the events
  Color color;

  ///true if freeTime
  bool freeTime;

  ///list of the documents
  List<Document> documents;

  ///convert to json object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'description': description,
        'period': period.toJson(),
        'color': color.toHex(),
        'documents': List<dynamic>.from(
            documents.map<dynamic>((Document x) => x.toJson())),
        'freeTime': freeTime
      };

  @override
  String toString() => toJson().toString();
}

///document class
class Document {
  ///initialize documents
  Document({
    required this.documentName,
  });

  ///initialize document object from json
  factory Document.fromJson(Map<String, dynamic> json) => Document(
        documentName: json['documentName'],
      );

  ///String docName
  String documentName;

  ///return json object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'documentName': documentName,
      };
}

///convert color to hex value

extension ColorExtension on Color {
  ///convert color to hex

  String toHex() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
