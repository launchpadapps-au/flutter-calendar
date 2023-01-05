import 'package:edgar_planner_calendar_flutter/core/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/weekview/week_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/weekview/week_event.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/weekview/week_header.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/weekview/week_hour_lable.dart';
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
  final Function(
      CalendarEvent<EventData> existing,
      CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent,
      Period? periodModel)? onEventToEventDragged;

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
  Widget build(BuildContext context) => Scaffold(body:
          LayoutBuilder(builder: (BuildContext context, BoxConstraints value) {
        final bool isMobile = value.maxWidth < mobileThreshold;

        return Container(
          color: white,
          child: SlWeekView<EventData>(
              backgroundColor: white,
              timelines: widget.customPeriods,
              onEventDragged: (CalendarEvent<EventData> old,
                  CalendarEvent<EventData> newEvent, Period? period) {
                widget.onEventDragged(old, newEvent, period);
              },
              onTap: (DateTime date, Period period,
                  CalendarEvent<EventData>? event) {
                widget.onTap!(date, period, event);
              },
              onDateChanged: widget.onDateChanged,
              onEventToEventDragged: (CalendarEvent<EventData> existing,
                  CalendarEvent<EventData> old,
                  CalendarEvent<EventData> newEvent,
                  Period? periodModel) {
                if (widget.onEventToEventDragged != null) {
                  widget.onEventToEventDragged!(
                      existing, old, newEvent, periodModel);
                }
              },
              onWillAccept: (CalendarEvent<EventData>? event, Period period) =>
                  true,
              nowIndicatorColor: timeIndicatorColor,
              cornerBuilder: (DateTime current) => Container(
                    color: white,
                  ),
              headerHeight: showSameHeader || isMobile ? headerHeight : 40,
              headerCellBuilder: (DateTime date) => WeekHeader(
                    date: date,
                    isMobile: isMobile,
                  ),
              hourLabelBuilder: (Period period) => WeekHourLable(
                  periodModel: period as PeriodModel, isMobile: isMobile),
              isCellDraggable: (CalendarEvent<EventData> event) =>
                  isCelldraggable(event),
              controller: widget.timetableController,
              itemBuilder: (CalendarEvent<EventData> item, double width) =>
                  WeekEvent(
                      item: item,
                      periods: widget.customPeriods,
                      cellHeight: widget.timetableController.cellHeight,
                      breakHeight: widget.timetableController.breakHeight,
                      width: width),
              cellBuilder: (Period period, DateTime dateTime) => WeekCell(
                  periodModel: period as PeriodModel,
                  breakHeight: widget.timetableController.breakHeight,
                  cellHeight: widget.timetableController.cellHeight)),
        );
      }));
}
