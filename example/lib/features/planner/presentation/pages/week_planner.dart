// ignore_for_file: lines_longer_than_80_chars

import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart' as utils;
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/weekview/week_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/weekview/week_event.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/weekview/week_header.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/weekview/week_hour_lable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class WeekPlanner<T> extends StatefulWidget {
  /// initialize week planner
  const WeekPlanner({
    required this.timetableController,
    required this.customPeriods,
    required this.onEventDragged,
    required this.onDateChanged,
    required this.onTap,
    required this.isMobile,
    required this.onWillAccept,
    required this.onWillAcceptForEvent,
    this.onEventToEventDragged,
    Key? key,
  }) : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///timetable controller
  final TimetableController<EventData> timetableController;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, Period?, CalendarEvent<T>?)? onTap;

  ///return new and okd event

  final Function(
          CalendarEvent<T> old, CalendarEvent<T> newEvent, Period? period)
      onEventDragged;

  ///give new day when day is scrolled
  final Function(DateTime dateTime) onDateChanged;

  ///return existing ,old and new event when used drag and drop
  ///the event on the existing event
  ///
  ///
  final Function(
      CalendarEvent<EventData> existing,
      CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent,
      Period? periodModel)? onEventToEventDragged;

  ///it will use to determine wether event will accept event or not
  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final bool Function(CalendarEvent<T> draggeed, CalendarEvent<T> existing,
      DateTime dateTime) onWillAcceptForEvent;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final bool Function(CalendarEvent<T>? event, Period period, DateTime dateTime)
      onWillAccept;

  ///pass true if device is mobile
  final bool isMobile;

  @override
  State<WeekPlanner<EventData>> createState() => _WeekPlannerState();
}

///current date time
DateTime now = DateTime.now().subtract(const Duration(days: 30));

class _WeekPlannerState extends State<WeekPlanner<EventData>> {
  static DateTime dateTime = DateTime.now();

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);
  final bool showSameHeader = true;

  @override
  Widget build(BuildContext context) => SlWeekView<EventData>(
      backgroundColor: white,
      timelines: widget.customPeriods,
      onEventDragged: (CalendarEvent<EventData> old,
          CalendarEvent<EventData> newEvent, Period? period) {
        widget.onEventDragged(old, newEvent, period);
      },
      onTap: (DateTime date, Period period, CalendarEvent<EventData>? event) {
        widget.onTap!(date, period, event);
      },
      autoScrollDate: utils
          .getMonday(DateTime.now())
          .add(Duration(days: widget.isMobile ? 1 : 2)),
      onDateChanged: widget.onDateChanged,
      onEventToEventDragged: (CalendarEvent<EventData> existing,
          CalendarEvent<EventData> old,
          CalendarEvent<EventData> newEvent,
          Period? periodModel,
          DateTime dateTime) {
        if (widget.onEventToEventDragged != null) {
          widget.onEventToEventDragged!(existing, old, newEvent, periodModel);
        }
      },
      onWillAcceptForEvent: (CalendarEvent<EventData> draggeed, CalendarEvent<EventData> existing, DateTime dateTime) =>
          widget.onWillAcceptForEvent(draggeed, existing, dateTime),
      onWillAccept: (CalendarEvent<EventData>? event, Period period, DateTime dateTime) =>
          widget.onWillAccept(event, period, dateTime),
      showNowIndicator: false,
      nowIndicatorColor: timeIndicatorColor,
      cornerBuilder: (DateTime current) => Container(
            color: white,
          ),
      headerHeight: showSameHeader || widget.isMobile ? headerHeight : 40,
      headerCellBuilder: (DateTime date) => WeekHeader(
            date: date,
            isMobile: widget.isMobile,
          ),
      hourLabelBuilder: (Period period) => WeekHourLable(
          periodModel: period as PeriodModel, isMobile: widget.isMobile),
      isCellDraggable: (CalendarEvent<EventData> event) =>
          CalendarUtils.isCelldraggable(event),
      controller: widget.timetableController,
      itemBuilder: (CalendarEvent<EventData> item, double width) => WeekEvent(
          item: item,
          isMobile: widget.isMobile,
          periods: widget.customPeriods,
          cellHeight: widget.timetableController.cellHeight,
          breakHeight: widget.timetableController.breakHeight,
          onTap: widget.onTap,
          width: width),
      cellBuilder: (Period period, DateTime date) =>
          WeekCell(periodModel: period as PeriodModel, breakHeight: widget.timetableController.breakHeight, cellHeight: widget.timetableController.cellHeight));
}
