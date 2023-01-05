import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/day_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dead_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_event.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_hour_lable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class MonthPlanner extends StatefulWidget {
  /// initialled  monthly planner
  const MonthPlanner({
    required this.timetableController,
    required this.onMonthChanged,
    required this.onTap,
    Key? key,
    this.id,
  }) : super(key: key);

  ///id that we will received from native ios
  final String? id;

  ///timetable controller
  final TimetableController<EventData> timetableController;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, List<CalendarEvent<EventData>>) onTap;

  ///return current month when user swipe and month changed
  final Function(Month) onMonthChanged;

  @override
  State<MonthPlanner> createState() => _MonthPlannerState();
}

///current date time
DateTime now = DateTime.now();

class _MonthPlannerState extends State<MonthPlanner> {
  static DateTime dateTime = DateTime.now();

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);

  bool isDraggable = false;

  @override
  Widget build(BuildContext context) => Scaffold(body:
          LayoutBuilder(builder: (BuildContext context, BoxConstraints value) {
        final bool isMobile = value.maxWidth < mobileThreshold;

        return SlMonthView<EventData>(
            timelines: customStaticPeriods,
            isDraggable: isDraggable,
            onMonthChanged: (Month month) {
              widget.onMonthChanged(month);
            },
            onEventDragged: (CalendarEvent<EventData> old,
                CalendarEvent<EventData> newEvent) {},
            onWillAccept: (CalendarEvent<EventData>? event, DateTime dateTime,
                Period period) {
              if (event != null) {
                final List<CalendarEvent<dynamic>> overleapingEvents =
                    BlocProvider.of<TimeTableCubit>(context)
                        .events
                        .where((CalendarEvent<dynamic> element) =>
                            !isTimeIsEqualOrLess(
                                element.startTime, event.startTime) &&
                            isTimeIsEqualOrLess(element.endTime, event.endTime))
                        .toList();
                if (overleapingEvents.isEmpty) {
                  log('Slot available: ${event.toMap}');
                  return true;
                } else {
                  log('Slot Not available-> Start Time: '
                      '${overleapingEvents.first.startTime}'
                      'End Time: ${overleapingEvents.first.endTime}');

                  return false;
                }
              } else {
                return false;
              }
            },
            nowIndicatorColor: Colors.red,
            fullWeek: true,
            deadCellBuilder: (DateTime current) => const Expanded(
                  child: DeadCell(),
                ),
            onTap: (DateTime date) {
              widget.onTap(date, <CalendarEvent<EventData>>[]);
            },
            headerHeight: isMobile ? 38 : 40,
            headerCellBuilder: (int index) => SizedBox(
                  height: widget.timetableController.headerHeight,
                  child: DayName(index: index),
                ),
            hourLabelBuilder: (Period period) =>
                MonthHourLable(periodModel: period as PeriodModel),
            controller: widget.timetableController,
            itemBuilder: (List<CalendarEvent<EventData>> item, Size size) =>
                MonthEventCell(
                    item: item,
                    cellHeight: widget.timetableController.cellHeight,
                    breakHeight: widget.timetableController.breakHeight,
                    size: size,
                    isDraggable: isDraggable,
                    onTap: widget.onTap),
            cellBuilder: (Period period) => MonthCell(
                periodModel: period as PeriodModel,
                breakHeight: widget.timetableController.breakHeight,
                cellHeight: widget.timetableController.cellHeight));
      }));
}
