import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:flutter/material.dart';

///custom timePeriods for the timetable
List<PeriodModel> customStaticPeriods = <PeriodModel>[
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: '0',
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
    id: '0',
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
    id: '0',
    slotName: 'Recess',
    type: 'break',
    stringStartTime: '10:30',
    stringEndTime: '11:00',
    startTime: const TimeOfDay(hour: 10, minute: 30),
    endTime: const TimeOfDay(hour: 11, minute: 0),
    isCustomeSlot: true,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: '0',
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
    id: '0',
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
    id: '0',
    slotName: 'Lunch',
    type: 'break',
    stringStartTime: '12:30',
    stringEndTime: '13:30',
    startTime: const TimeOfDay(hour: 12, minute: 30),
    endTime: const TimeOfDay(hour: 13, minute: 30),
    isCustomeSlot: true,
  ),
  PeriodModel(
    userId: '5a26b415-467b-468f-a30a-e657222a7ea6',
    calendarId: 18,
    id: '0',
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
    id: '0',
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
    id: '0',
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
    id: '0',
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
    id: '0',
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

///static json for the terms
Map<String, dynamic>

    /// A map of string to dynamic.
    staticJsonForTheTerm = <String, dynamic>{
  'term': <String, dynamic>{
    'id': 6,
    'territory': 'New South Wales',
    'term1': '02-01|23-01',
    'term2': '26-01|07-07',
    'term3': '10-07|29-09',
    'term4': '02-10|29-12'
  },
  'id': '681ab18e-0ddd-4dda-94e8-0026f1d4c46f'
};

///static term that derived from [staticJsonForTheTerm]
TermModel termFromJson = TermModel.fromJson(staticJsonForTheTerm);

///contaons default dates for the calendar
class DefaultDates {
  ///start date of the calendar

  static DateTime get startDate => DateTime(1970);

  ///stendart date of the calendar

  static DateTime get endDate => DateTime(2050);

  ///start date of the  month view in the calendar

  static DateTime get monthStartDate {
    var now = DateTime.now();
    return now.copyWith(year: now.year - 5);
  }

  ///start date of the  month view in the calendar

  static DateTime get monthEndate {
    var now = DateTime.now();
    return now.copyWith(year: now.year + 5);
  }
}

///Default parameter for the calendar
class CalendarParams {
  ///default timeline width
  static double get timelineWidth => 60;

  ///default breack height
  static double get breakHeighth => 35;

  ///default cell height
  static double get cellHeighth => 110;

  ///default infinite scrooling
  static bool get infiniteScrolling => false;

  ///brack height for mobile
  static double mobileBreakHeight = 22;

  ///breack hright for the tab
  static double tabBreakHeight = 33;

  ///cell height for the mobile
  static double mobileCellHeight = 83;

  ///cell height fpr the tab
  static double tabCellHeight = 100;
}
