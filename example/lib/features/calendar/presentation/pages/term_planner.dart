import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/day_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/dead_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/small_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

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
  final TimetableController<EventData> timetableController;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, List<CalendarEvent<EventData>> events)
      onTap;

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
  Widget build(BuildContext context) => SlTermView<EventData>(
        timelines: customStaticPeriods,
        isSwipeEnable: true,
        isDraggable: isDragEnable,
        deadCellBuilder: (DateTime current  ) => const Expanded(
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
            (CalendarEvent<EventData> old, CalendarEvent<EventData> newEvent) {
          BlocProvider.of<TimeTableCubit>(context)
              .updateEvent(old, newEvent, null);
        },
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
        onTap: (DateTime date) {
          widget.onTap(date, <CalendarEvent<EventData>>[]);
        },
        headerHeight: headerHeight - 10,
        headerCellBuilder: (int index) => SizedBox(
          height: widget.timetableController.headerHeight,
          child: DayName(index: index),
        ),
        controller: widget.timetableController,
        itemBuilder: (List<CalendarEvent<EventData>> item, Size size,
                DateTime dateTime) =>
            item.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          height: 35,
                        ),
                        SizedBox(
                          width: size.width,
                          height: 19,
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  widget.onTap(item.first.eventData!.startDate,
                                      <CalendarEvent<EventData>>[item.first]);
                                },
                                child: ExtraSmallEventTile(
                                  event: item.first,
                                  isDraggable: isDragEnable,
                                  width: (size.width - 6) / 2,
                                ),
                              ),
                              item.length >= 2
                                  ? GestureDetector(
                                      onTap: () {
                                        widget.onTap(
                                            item[1].eventData!.startDate,
                                            <CalendarEvent<EventData>>[
                                              item[1]
                                            ]);
                                      },
                                      child: ExtraSmallEventTile(
                                        event: item[1],
                                        isDraggable: isDragEnable,
                                        width: (size.width - 6) / 2,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width,
                          height: 19,
                          child: Row(
                            children: <Widget>[
                              item.length >= 3
                                  ? GestureDetector(
                                      onTap: () {
                                        widget.onTap(
                                            item.first.eventData!.startDate,
                                            <CalendarEvent<EventData>>[
                                              item.first
                                            ]);
                                      },
                                      child: ExtraSmallEventTile(
                                        event: item.first,
                                        isDraggable: isDragEnable,
                                        width: (size.width - 6) / 2,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              item.skip(3).isEmpty
                                  ? const SizedBox.shrink()
                                  : Text('+${item.skip(3).length}'
                                      ''),
                            ],
                          ),
                        )
                      ],
                    )),
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
