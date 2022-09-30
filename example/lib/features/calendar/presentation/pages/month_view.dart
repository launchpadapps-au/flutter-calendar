import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/date_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/day_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dead_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/small_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class MonthPlanner extends StatefulWidget {
  /// initialled  monthly planner
  const MonthPlanner({
    required this.timetableController,
    required this.onMonthChanged,
    Key? key,
    this.id,
  }) : super(key: key);

  ///id that we will received from native ios
  final String? id;

  ///timetable controller
  final TimetableController timetableController;

  ///return current month when user swipe and month changed
  final Function(Month) onMonthChanged;

  @override
  State<MonthPlanner> createState() => _MonthPlannerState();
}

///current date time
DateTime now = DateTime.now();

class _MonthPlannerState extends State<MonthPlanner> {
  TimetableController simpleController = TimetableController(
      start:
          DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 1)),
      end: dateTime.lastDayOfMonth,
      timelineWidth: 60,
      breakHeight: 35,
      cellHeight: 120);
  static DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    simpleController = widget.timetableController;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentMonth = simpleController.visibleDateStart;
      setState(() {});
      Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
        simpleController.jumpTo(now);
      });
    });
  }

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);

  bool isDraggable = true;

  @override
  Widget build(BuildContext context) => Scaffold(body:
          LayoutBuilder(builder: (BuildContext context, BoxConstraints value) {
        final bool isMobile = value.maxWidth < mobileThreshold;
        return BlocBuilder<TimeTableCubit, TimeTableState>(
            builder: (BuildContext context, TimeTableState state) {
          if (state is ErrorState) {
            return const Center(
              child: Icon(Icons.close),
            );
          } else {
            return Column(
              children: <Widget>[
                state is LoadingState
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink(),
                Expanded(
                  child: SlMonthView<EventData>(
                    timelines: customStaticPeriods,
                    isDraggable: true,
                    onMonthChanged: (Month month) {
                      widget.onMonthChanged(month);
                    },
                    onEventDragged: (CalendarEvent<EventData> old,
                        CalendarEvent<EventData> newEvent) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .updateEvent(old, newEvent, null);
                    },
                    onWillAccept: (CalendarEvent<EventData>? event,
                        DateTime dateTime, Period period) {
                      if (event != null) {
                        if (state is LoadingState) {
                          final List<CalendarEvent<dynamic>> overleapingEvents =
                              BlocProvider.of<TimeTableCubit>(context)
                                  .events
                                  .where((CalendarEvent<dynamic> element) =>
                                      !isTimeIsEqualOrLess(
                                          element.startTime, event.startTime) &&
                                      isTimeIsEqualOrLess(
                                          element.endTime, event.endTime))
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
                      } else {
                        return false;
                      }
                    },
                    nowIndicatorColor: Colors.red,
                    fullWeek: true,
                    deadCellBuilder: (DateTime current) => const Expanded(
                      child: DeadCell(),
                    ),
                    items: state is LoadedState
                        ? state.events
                        : <CalendarEvent<EventData>>[],
                    onTap: (DateTime date) {
                      final TimeTableCubit provider =
                          BlocProvider.of<TimeTableCubit>(context);
                      provider.nativeCallBack.sendAddEventToNativeApp(
                          dateTime, provider.viewType, null);
                    },
                    headerHeight: isMobile ? 38 : 40,
                    headerCellBuilder: (int index) => SizedBox(
                      height: simpleController.headerHeight,
                      child: DayName(index: index),
                    ),
                    hourLabelBuilder: (Period period) {
                      final TimeOfDay start = period.startTime;

                      final TimeOfDay end = period.endTime;
                      return Container(
                        child: period.isBreak
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(period.title ?? '',
                                      style: context.subtitle),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(start.format(context).substring(0, 5),
                                      style: context.subtitle),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(end.format(context).substring(0, 5),
                                      style: context.subtitle),
                                ],
                              ),
                      );
                    },
                    controller: simpleController,
                    itemBuilder: (List<CalendarEvent<EventData>> item,
                            Size size) =>
                        item.isEmpty
                            ? const SizedBox.shrink()
                            : SizedBox(
                                width: size.width,
                                height: size.height,
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    if (item.length == 1)
                                      SmallEventTile(
                                        event: item.first,
                                        width: size.width,
                                        isDraggable: isDraggable,
                                      ),
                                    if (item.length == 2)
                                      Column(
                                        children: <Widget>[
                                          SmallEventTile(
                                            event: item.first,
                                            isDraggable: isDraggable,
                                            width: size.width,
                                          ),
                                          SmallEventTile(
                                            event: item[1],
                                            isDraggable: isDraggable,
                                            width: size.width,
                                          )
                                        ],
                                      ),
                                    if (item.length > 2)
                                      SizedBox(
                                        width: size.width,
                                        child: Column(
                                          children: <Widget>[
                                            SmallEventTile(
                                              event: item.first,
                                              width: size.width,
                                              isDraggable: isDraggable,
                                            ),
                                            SmallEventTile(
                                              event: item[1],
                                              width: size.width,
                                              isDraggable: isDraggable,
                                            ),
                                            Row(children: <Widget>[
                                              SizedBox(
                                                width: size.width - 90,
                                                child: SmallEventTile(
                                                    isDraggable: isDraggable,
                                                    event: item[2],
                                                    width: size.width - 60),
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text('+${item.skip(3).length}'),
                                              const Spacer()
                                            ])
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                    cellBuilder: (Period period) => Container(
                      height: period.isBreak
                          ? simpleController.breakHeight
                          : simpleController.cellHeight,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 0.5),
                          color: period.isBreak
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.transparent),
                    ),
                  ),
                ),
              ],
            );
          }
        });
      }));
}
