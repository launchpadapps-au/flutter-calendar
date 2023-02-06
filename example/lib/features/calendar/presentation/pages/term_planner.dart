import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/day_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/dead_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/termview/term_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';

///TermPlaner which show continues date for view
class TermPlanner extends StatefulWidget {
  /// initialized term planner by passing passing controller
  const TermPlanner({
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
  final Function(DateTime dateTime, List<CalendarEvent<Note>> events) onTap;

  ///return current month when user swipe and month changed
  final Function(Month) onMonthChanged;

  @override
  State<TermPlanner> createState() => _TermPlannerState();
}

///current date time
DateTime now = DateTime.now();

class _TermPlannerState extends State<TermPlanner> {
  static DateTime dateTime = DateTime.now();

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);
  bool isDragEnable = false;

  @override
  Widget build(BuildContext context) => SlTermView<Note>(
        timelines: customStaticPeriods,
        isSwipeEnable: true,
        isDraggable: isDragEnable,
        deadCellBuilder: (DateTime current, Size cellSize) => const Expanded(
          child: DeadCell(),
        ),
        dateBuilder: (DateTime current) => Stack(
          children: <Widget>[
            Positioned(
                right: mainMarginHalf,
                top: mainMarginHalf,
                left: mainMarginHalf,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      current.day == 1 ? DateFormat('MMM').format(current) : '',
                      style: context.termPlannerTitle,
                    ),
                    Text(
                      current.day.toString(),
                      style: context.termPlannerTitle2,
                    ),
                  ],
                ))
          ],
        ),
        onMonthChanged: (Month month) {
          widget.onMonthChanged(month);
        },
        onEventDragged:
            (CalendarEvent<Note> old, CalendarEvent<Note> newEvent) {
          // BlocProvider.of<TimeTableCubit>(context)
          //     .updateEvent(old, newEvent, null);
        },
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
              logInfo('Slot available: ${event.toMap}');
              return true;
            } else {
              logInfo('Slot Not available-> Start Time: '
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
        headerHeight: headerHeight - 10,
        headerCellBuilder: (int index) => SizedBox(
          height: widget.timetableController.headerHeight,
          child: DayName(index: index),
        ),
        controller: widget.timetableController,
        onTap: (CalendarDay date) {
          if (!date.deadCell) {
            widget.onTap(date.dateTime, <CalendarEvent<Note>>[]);
          }
        },
        itemBuilder:
            (List<CalendarEvent<Note>> item, Size size, CalendarDay dateTime) =>
                TermNote(
          item: item,
          calendarDay: dateTime,
          cellHeight: widget.timetableController.cellHeight,
          breakHeight: widget.timetableController.breakHeight,
          size: size,
          isDraggable: false,
          onTap: (CalendarDay dateTime, List<CalendarEvent<Note>> p1) {
            widget.onTap(dateTime.dateTime, p1);
          },
        ),
        cellBuilder: (Period period) => Container(
          height: period.isCustomeSlot
              ? widget.timetableController.breakHeight
              : widget.timetableController.cellHeight,
          decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
              color: period.isCustomeSlot
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.transparent),
        ),
      );
}
