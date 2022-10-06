 

import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/month_planner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';

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
              isCustomeSlot: true,
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
              isCustomeSlot: true,
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
List<PeriodModel> customStaticPeriods = <PeriodModel>[
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period1',
    stringEndTime: '09:45',
    type: 'period',
    stringStartTime: '09:30',
    startTime: const TimeOfDay(hour: 9, minute: 30),
    endTime: const TimeOfDay(hour: 9, minute: 45),
    isCustomeSlot: false,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period2',
    type: 'period',
    stringStartTime: '09:45',
    stringEndTime: '10:30',
    isCustomeSlot: false,
    startTime: const TimeOfDay(hour: 9, minute: 45),
    endTime: const TimeOfDay(hour: 10, minute: 30),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'Recess',
    type: 'period',
    stringStartTime: '10:30',
    stringEndTime: '11:00',
    startTime: const TimeOfDay(hour: 10, minute: 30),
    endTime: const TimeOfDay(hour: 11, minute: 0),
    isCustomeSlot: true,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period3',
    type: 'period',
    isCustomeSlot: false,
    stringStartTime: '11:00',
    stringEndTime: '11:45',
    startTime: const TimeOfDay(hour: 11, minute: 0),
    endTime: const TimeOfDay(hour: 11, minute: 45),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period4',
    type: 'period',
    isCustomeSlot: false,
    stringStartTime: '11:45',
    stringEndTime: '12:30',
    startTime: const TimeOfDay(hour: 11, minute: 45),
    endTime: const TimeOfDay(hour: 12, minute: 30),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'Lunch',
    type: 'period',
    stringStartTime: '12:30',
    stringEndTime: '13:30',
    startTime: const TimeOfDay(hour: 12, minute: 30),
    endTime: const TimeOfDay(hour: 13, minute: 30),
    isCustomeSlot: true,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period5',
    type: 'period',
    isCustomeSlot: false,
    stringStartTime: '13:30',
    stringEndTime: '14:15',
    startTime: const TimeOfDay(hour: 13, minute: 30),
    endTime: const TimeOfDay(hour: 14, minute: 15),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period6',
    stringStartTime: '14:15',
    type: 'period',
    isCustomeSlot: false,
    stringEndTime: '15:00',
    startTime: const TimeOfDay(hour: 14, minute: 15),
    endTime: const TimeOfDay(hour: 15, minute: 0),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period6',
    stringStartTime: '15:00',
    type: 'period',
    isCustomeSlot: false,
    stringEndTime: '16:00',
    startTime: const TimeOfDay(hour: 15, minute: 00),
    endTime: const TimeOfDay(hour: 16, minute: 0),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period6',
    stringStartTime: '16:00',
    type: 'period',
    isCustomeSlot: false,
    stringEndTime: '16:30',
    startTime: const TimeOfDay(hour: 16, minute: 00),
    endTime: const TimeOfDay(hour: 16, minute: 30),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period6',
    stringStartTime: '16:30',
    type: 'period',
    isCustomeSlot: false,
    stringEndTime: '17:30',
    startTime: const TimeOfDay(hour: 16, minute: 30),
    endTime: const TimeOfDay(hour: 17, minute: 30),
  ),
];

///defualt terms for the term planner

TermModel defaultTermModel = TermModel(
    terms: Terms(
        id: 0,
        term1: '01-01|31-03',
        term2: '01-04|30-06',
        term3: '01-07|30-09',
        term4: '01-10|31-12',
        territory: 'default'),
    id: '0');

///dummy list with non uniform slpts
List<Map<String, String>> list = <Map<String, String>>[
  <String, String>{
    'id': '41',
    'start_time': '09:00:00',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'slot_name': 'period_1',
    'calendar_id': '19',
    'end_time': '09:45:00',
    '__typename': 'calendar_slots',
    'type': 'period'
  },
  <String, String>{
    '__typename': 'calendar_slots',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'end_time': '10:30:00',
    'calendar_id': '19',
    'type': 'period',
    'id': '42',
    'slot_name': 'period_2',
    'start_time': '09:45:00'
  },
  <String, String>{
    'end_time': '11:15:00',
    'id': '44',
    'slot_name': 'break_1',
    'start_time': '11:00:00',
    '__typename': 'calendar_slots',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'calendar_id': '19',
    'type': 'break'
  },
  <String, String>{
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'end_time': '12:00:00',
    '__typename': 'calendar_slots',
    'calendar_id': '19',
    'slot_name': 'period_3',
    'start_time': '11:15:00',
    'type': 'period',
    'id': '46'
  },
  <String, String>{
    'type': 'break',
    '__typename': 'calendar_slots',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'id': '48',
    'calendar_id': '19',
    'end_time': '13:00:00',
    'start_time': '12:00:00',
    'slot_name': 'break_2'
  },
  <String, String>{
    'calendar_id': '19',
    '__typename': 'calendar_slots',
    'slot_name': 'period_4',
    'type': 'period',
    'start_time': '13:00:00',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'id': '47',
    'end_time': '13:45:00'
  },
  <String, String>{
    'end_time': '14:30:00',
    'id': '45',
    'start_time': '13:45:00',
    'type': 'period',
    'calendar_id': '19',
    'slot_name': 'period_5',
    '__typename': 'calendar_slots',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45'
  },
  <String, String>{
    'end_time': '15:30:00',
    'type': 'break',
    'calendar_id': '19',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'id': '49',
    'start_time': '15:00:00',
    '__typename': 'calendar_slots',
  },
  <String, String>{
    'end_time': '16:15:00',
    'slot_name': 'period_6',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    '__typename': 'calendar_slots',
    'id': '51',
    'start_time': '15:30:00',
    'type': 'period',
    'calendar_id': '19'
  },
  <String, String>{
    'id': '50',
    'end_time': '17:00:00',
    '__typename': 'calendar_slots',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45',
    'type': 'period',
    'calendar_id': '19',
    'slot_name': 'period_7',
    'start_time': '16:15:00'
  },
  <String, String>{
    'end_time': '17:45:00',
    'type': 'period',
    'start_time': '17:00:00',
    'calendar_id': '19',
    '__typename': 'calendar_slots',
    'id': '43',
    'slot_name': 'period_8',
    'user_id': 'e5e54542-921e-4327-8058-eb16794bcb45'
  }
];

///dummmy period from non uni form slots
List<PeriodModel> dummyPeriods = <PeriodModel>[
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period1',
    type: 'period',
    stringStartTime: '09:00',
    stringEndTime: '09:45',
    startTime: const TimeOfDay(hour: 9, minute: 00),
    endTime: const TimeOfDay(hour: 9, minute: 45),
    isCustomeSlot: false,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period2',
    type: 'period',
    stringStartTime: '09:45',
    stringEndTime: '10:30',
    isCustomeSlot: false,
    startTime: const TimeOfDay(hour: 9, minute: 45),
    endTime: const TimeOfDay(hour: 10, minute: 30),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'Recess',
    type: 'break',
    stringStartTime: '11:00',
    stringEndTime: '11:15',
    startTime: const TimeOfDay(hour: 11, minute: 00),
    endTime: const TimeOfDay(hour: 11, minute: 15),
    isCustomeSlot: true,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period3',
    type: 'period',
    isCustomeSlot: false,
    stringStartTime: '11:15',
    stringEndTime: '12:00',
    startTime: const TimeOfDay(hour: 11, minute: 15),
    endTime: const TimeOfDay(hour: 12, minute: 00),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'Lunch',
    
    type: 'break',
    isCustomeSlot: true,
    stringStartTime: '12:00',
    stringEndTime: '13:00',
    startTime: const TimeOfDay(hour: 12, minute: 00),
    endTime: const TimeOfDay(hour: 13, minute: 00),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'Period 4',
    type: 'period',
    stringStartTime: '13:00',
    stringEndTime: '13:45',
    startTime: const TimeOfDay(hour: 13, minute: 00),
    endTime: const TimeOfDay(hour: 13, minute: 45),
    isCustomeSlot: false,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period5',
    type: 'period',
    isCustomeSlot: false,
    stringStartTime: '13:45',
    stringEndTime: '14:30',
    startTime: const TimeOfDay(hour: 13, minute: 45),
    endTime: const TimeOfDay(hour: 14, minute: 30),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'break3',
    stringStartTime: '15:00',
    type: 'break',
    isCustomeSlot: true,
    stringEndTime: '15:30',
    startTime: const TimeOfDay(hour: 15, minute: 00),
    endTime: const TimeOfDay(hour: 15, minute: 30),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'perio6',
    stringStartTime: '15:30',
    type: 'period',
    isCustomeSlot: false,
    stringEndTime: '16:15',
    startTime: const TimeOfDay(hour: 15, minute: 30),
    endTime: const TimeOfDay(hour: 16, minute: 15),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period7',
    stringStartTime: '16:15',
    type: 'period',
    isCustomeSlot: false,
    stringEndTime: '17:00',
    startTime: const TimeOfDay(hour: 16, minute: 15),
    endTime: const TimeOfDay(hour: 17, minute: 00),
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: 0,
    slotName: 'period8',
    stringStartTime: '17:00',
    type: 'period',
    isCustomeSlot: false,
    stringEndTime: '17:45',
    startTime: const TimeOfDay(hour: 17, minute: 00),
    endTime: const TimeOfDay(hour: 17, minute: 45),
  ),
];
