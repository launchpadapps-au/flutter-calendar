///event classs
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///event class
class Event {
  /// initialized event model
  Event({
    required this.title,
    required this.description,
    required this.documents,
    required this.period,
    required this.color,
    this.freeTime = false,
  });

  ///title of the event
  String title;

  ///description of the events
  String description;

  ///documents for the events
  List<String> documents;

  ///color of the event
  Color color;

  ///true if its free time
  final bool freeTime;

  /// Period od the the timetable item to determine if its breack

  Period period;
}
