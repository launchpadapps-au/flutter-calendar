import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/month_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///period of the EventData
List<Period> periodsForEventData = <Period>[
  Period(
      startTime: const TimeOfDay(hour: 9, minute: 30),
      endTime: const TimeOfDay(hour: 9, minute: 45)),
  Period(
      startTime: const TimeOfDay(hour: 9, minute: 45),
      endTime: const TimeOfDay(hour: 10, minute: 30)),
  Period(
      startTime: const TimeOfDay(hour: 9, minute: 45),
      endTime: const TimeOfDay(hour: 10, minute: 30)),
  Period(
      startTime: const TimeOfDay(hour: 13, minute: 30),
      endTime: const TimeOfDay(hour: 14, minute: 45)),
  Period(
      startTime: const TimeOfDay(hour: 9, minute: 30),
      endTime: const TimeOfDay(hour: 1, minute: 30)),
  Period(
      startTime: const TimeOfDay(hour: 11, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 45)),
  Period(
      startTime: const TimeOfDay(hour: 13, minute: 30),
      endTime: const TimeOfDay(hour: 15, minute: 00)),
  Period(
      startTime: const TimeOfDay(hour: 13, minute: 30),
      endTime: const TimeOfDay(hour: 15, minute: 00)),
  Period(
      startTime: const TimeOfDay(hour: 11, minute: 30),
      endTime: const TimeOfDay(hour: 12, minute: 30)),
  Period(
      startTime: const TimeOfDay(hour: 13, minute: 30),
      endTime: const TimeOfDay(hour: 14, minute: 15)),
];

///timetable EventDatas
List<PlannerEvent> dummyEventData = <PlannerEvent>[
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 9, 30),
      endTime: DateTime(now.year, now.month, now.day, 9, 45),
      eventData: EventData(
          title:
              'Lesson 1, This is testing for longer title,if long text is ther'
              ' ethen we can display longer text and check the ui',
          period: Period(
              startTime: const TimeOfDay(hour: 9, minute: 30),
              endTime: const TimeOfDay(hour: 9, minute: 45)),
          description:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed'
              ' do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
              ' Ut enim ad minim veniam, quis nostrud exercitation ullamco '
              'laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure'
              ' dolor in reprehenderit in voluptate velit esse cillum dolore eu'
              ' fugiat nulla pariatur. Excepteur sint occaecat cupidatat non'
              ' proident, sunt in culpa qui officia deserunt mollit anim id'
              ' est laborum.',
          color: const Color(0xFFB7C4EA),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 9, 30),
      endTime: DateTime(now.year, now.month, now.day, 9, 45),
      eventData: EventData(
          title: 'Lesson 2',
          period: Period(
              startTime: const TimeOfDay(hour: 9, minute: 30),
              endTime: const TimeOfDay(hour: 9, minute: 45)),
          description: 'Description 2',
          color: const Color(0xFFF7CB89),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 9, 30),
      endTime: DateTime(now.year, now.month, now.day, 9, 45),
      eventData: EventData(
          title: 'Lesson 3',
          period: Period(
              startTime: const TimeOfDay(hour: 9, minute: 30),
              endTime: const TimeOfDay(hour: 9, minute: 45)),
          description: 'Description 3',
          color: const Color(0xFF8CC1DA),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 9, 30),
      endTime: DateTime(now.year, now.month, now.day, 9, 45),
      eventData: EventData(
          title: 'Lesson 4',
          period: Period(
              startTime: const TimeOfDay(hour: 9, minute: 30),
              endTime: const TimeOfDay(hour: 9, minute: 45)),
          description: 'Description 4',
          color: const Color(0xFFE697A9),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 9, 45),
      endTime: DateTime(now.year, now.month, now.day, 10, 30),
      eventData: EventData(
          title: 'Lesson 2',
          period: Period(
              startTime: const TimeOfDay(hour: 9, minute: 45),
              endTime: const TimeOfDay(hour: 10, minute: 30)),
          description: 'Description 2',
          color: const Color(0xFFF7CB89),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 10, 30),
      endTime: DateTime(now.year, now.month, now.day, 11),
      eventData: EventData(
          title: 'Duty - Basketball Court',
          period: Period(
              isBreak: true,
              startTime: const TimeOfDay(hour: 9, minute: 45),
              endTime: const TimeOfDay(hour: 10, minute: 30)),
          description: 'Description 2',
          color: grey,
          documents: <Document>[])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 11),
      endTime: DateTime(now.year, now.month, now.day, 11, 45),
      eventData: EventData(
          title: 'Lesson 3',
          period: Period(
              startTime: const TimeOfDay(hour: 9, minute: 45),
              endTime: const TimeOfDay(hour: 10, minute: 30)),
          description: 'Description 3',
          color: const Color(0xFF8CC1DA),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 13, 30),
      endTime: DateTime(now.year, now.month, now.day, 14, 15),
      eventData: EventData(
          title: 'Lesson 4',
          period: Period(
              startTime: const TimeOfDay(hour: 13, minute: 30),
              endTime: const TimeOfDay(hour: 14, minute: 45)),
          description: 'Description 4',
          color: const Color(0xFFE697A9),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day, 12, 30),
      endTime: DateTime(now.year, now.month, now.day, 13, 30),
      eventData: EventData(
          title: 'Duty - Canteen',
          period: Period(
              isBreak: true,
              startTime: const TimeOfDay(hour: 9, minute: 45),
              endTime: const TimeOfDay(hour: 10, minute: 30)),
          description: 'Description 2',
          color: grey,
          documents: <Document>[])),
  //second column
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day + 1, 9, 30),
      endTime: DateTime(now.year, now.month, now.day + 1, 10, 30),
      eventData: EventData(
          title: 'Lesson 5',
          period: Period(
              startTime: const TimeOfDay(hour: 9, minute: 30),
              endTime: const TimeOfDay(hour: 1, minute: 30)),
          description: 'Description 5',
          color: const Color(0xFF123CBB).withOpacity(0.30),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day + 1, 11),
      endTime: DateTime(now.year, now.month, now.day + 1, 11, 45),
      eventData: EventData(
          title: 'Lesson 6',
          period: Period(
              startTime: const TimeOfDay(hour: 11, minute: 0),
              endTime: const TimeOfDay(hour: 11, minute: 45)),
          description: 'Description 6',
          color: const Color(0xFFF7CB89),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day + 1, 13, 52),
      endTime: DateTime(now.year, now.month, now.day + 1, 15),
      eventData: EventData(
          title: 'Free Time',
          freeTime: true,
          period: Period(
              startTime: const TimeOfDay(hour: 13, minute: 52),
              endTime: const TimeOfDay(hour: 15, minute: 00)),
          description: 'Description 7',
          color: const Color(0xFFCBCE42).withOpacity(0.5),
          documents: <Document>[Document(documentName: 'documents.pdf')])),

  ///third column
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day + 2, 9, 45),
      endTime: DateTime(now.year, now.month, now.day + 2, 10, 30),
      eventData: EventData(
          title: 'Lesson 8',
          period: Period(
              startTime: const TimeOfDay(hour: 13, minute: 30),
              endTime: const TimeOfDay(hour: 15, minute: 00)),
          description: 'Description 8',
          color: const Color(0xFF52B5D7).withOpacity(0.5),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day + 2, 11),
      endTime: DateTime(now.year, now.month, now.day + 2, 12, 08),
      eventData: EventData(
          title: 'Free Time',
          freeTime: true,
          period: Period(
              startTime: const TimeOfDay(hour: 11, minute: 30),
              endTime: const TimeOfDay(hour: 12, minute: 30)),
          description: 'Description 9',
          color: const Color(0xFFCBCE42).withOpacity(0.5),
          documents: <Document>[Document(documentName: 'documents.pdf')])),
  PlannerEvent(
      startTime: DateTime(now.year, now.month, now.day + 2, 13, 30),
      endTime: DateTime(now.year, now.month, now.day + 2, 14, 15),
      eventData: EventData(
          title: 'Lesson 10',
          period: Period(
              startTime: const TimeOfDay(hour: 13, minute: 30),
              endTime: const TimeOfDay(hour: 14, minute: 15)),
          description: 'Description 10',
          color: const Color(0xFF52B5D7).withOpacity(0.5),
          documents: <Document>[Document(documentName: 'documents.pdf')]))
];

///custom timePeriods for the timetable
List<Period> customStaticPeriods = <Period>[
  Period(
    startTime: const TimeOfDay(hour: 9, minute: 30),
    endTime: const TimeOfDay(hour: 9, minute: 45),
  ),
  Period(
    startTime: const TimeOfDay(hour: 9, minute: 45),
    endTime: const TimeOfDay(hour: 10, minute: 30),
  ),
  Period(
    startTime: const TimeOfDay(hour: 10, minute: 30),
    endTime: const TimeOfDay(hour: 11, minute: 0),
    isBreak: true,
    title: 'Recess',
  ),
  Period(
    startTime: const TimeOfDay(hour: 11, minute: 0),
    endTime: const TimeOfDay(hour: 11, minute: 45),
  ),
  Period(
    startTime: const TimeOfDay(hour: 11, minute: 45),
    endTime: const TimeOfDay(hour: 12, minute: 30),
  ),
  Period(
      startTime: const TimeOfDay(hour: 12, minute: 30),
      endTime: const TimeOfDay(hour: 13, minute: 30),
      isBreak: true,
      title: 'Lunch'),
  Period(
    startTime: const TimeOfDay(hour: 13, minute: 30),
    endTime: const TimeOfDay(hour: 14, minute: 15),
  ),
  Period(
    startTime: const TimeOfDay(hour: 14, minute: 15),
    endTime: const TimeOfDay(hour: 15, minute: 0),
  ),
];
