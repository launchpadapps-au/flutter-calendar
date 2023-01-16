import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/day_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/dead_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_hour_lable.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_note.dart';
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
  final TimetableController<Note> timetableController;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, List<CalendarEvent<Note>>) onTap;

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
  Widget build(BuildContext context) => SlMonthView<Note>(
        timelines: customStaticPeriods,
        isDraggable: isDraggable,
        onMonthChanged: (Month month) {
          widget.onMonthChanged(month);
        },
        onEventDragged:
            (CalendarEvent<Note> old, CalendarEvent<Note> newEvent) {},
        onWillAccept:
            (CalendarEvent<Note>? event, DateTime dateTime, Period period) {
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
        deadCellBuilder: (DateTime current, Size cellSize) => const Expanded(
          child: DeadCell(),
        ),
        onTap: (DateTime date) {
          widget.onTap(date, <CalendarEvent<Note>>[]);
        },
        itemBuilder: (List<CalendarEvent<Note>> item, Size size) => MonthNote(
            item: item,
            cellHeight: widget.timetableController.cellHeight,
            breakHeight: widget.timetableController.breakHeight,
            size: size,
            isDraggable: isDraggable,
            onTap: widget.onTap),
        cellBuilder: (Period period) => MonthCell(
            periodModel: period as PeriodModel,
            breakHeight: widget.timetableController.breakHeight,
            cellHeight: widget.timetableController.cellHeight),
        headerHeight: headerHeight - 10,
        headerCellBuilder: (int index) => SizedBox(
          height: widget.timetableController.headerHeight,
          child: DayName(index: index),
        ),
        hourLabelBuilder: (Period period) =>
            MonthHourLable(periodModel: period as PeriodModel),
        controller: widget.timetableController,
      );
}
