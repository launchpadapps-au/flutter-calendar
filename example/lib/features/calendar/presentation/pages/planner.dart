 

import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/month_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/day_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/schedule_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/setting_dialog.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/term_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/week_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/left_strip.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/right_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class Planner extends StatefulWidget {
  ///
  const Planner({Key? key, this.id}) : super(key: key);

  ///id that we will received from native ios
  final String? id;

  @override
  State<Planner> createState() => _PlannerState();
}

///current date time
DateTime now = DateTime.now().subtract(const Duration(days: 1));

class _PlannerState extends State<Planner> {
  static DateTime startDate = DateTime.now();
  static DateTime endDate = DateTime(2022, 12, 31);
  TimetableController<EventData> timeTableController =
      TimetableController<EventData>(
          start: startDate,
          end: endDate,
          timelineWidth: 60,
          breakHeight: 35,
          cellHeight: 110);

  /// Used to display the current month in the app bar.
  DateTime dateTime = DateTime.now();

  static bool isMobile = true;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static DateTime dateForHeader = DateTime.now();
  ValueNotifier<DateTime> headerDateNotifier =
      ValueNotifier<DateTime>(dateForHeader);
  int index = 0;
  bool showAppbar = true;
  @override
  void initState() {
    periods = customStaticPeriods;
    setState(() {});
    BlocProvider.of<TimeTableCubit>(context)
        .stream
        .listen((TimeTableState event) {
      if (event is DateUpdated) {
        debugPrint('Date is updating in calendar');
        timeTableController.changeDate(event.startDate, event.endDate);
      } else if (event is ViewUpdated) {
        debugPrint('view updated in calendar');
        viewTypeNotifer.value = event.viewType;
      } else if (event is JumpToDateState) {
        debugPrint('jumping to date in calendar');
        timeTableController.jumpTo(event.dateTime);
      } else if (event is LoadedState) {
        debugPrint('Setting event in calendar');

        if (event.events.isNotEmpty) {
          timeTableController.addEvent(event.events, replace: true);
        }
      } else if (event is EventUpdatedState) {
        debugPrint('updating events in calendar');
        timeTableController.updateEvent(event.oldEvent, event.newEvent);
      } else if (event is EventsAdded) {
        debugPrint('adding events in calendar');
        timeTableController.addEvent(event.events, replace: true);
      } else if (event is PeriodsUpdated) {
        periods = event.periods;
        setState(() {
          debugPrint('Setting periods in calendar');
        });
      } else if (event is DeletedEvents) {
        timeTableController.removeEvent(event.deletedEvents);
        debugPrint('removing events from calendar');
      }
    });
    super.initState();
  }

  List<Period> periods = <PeriodModel>[];

  ValueNotifier<CalendarViewType> viewTypeNotifer =
      ValueNotifier<CalendarViewType>(CalendarViewType.scheduleView);

  bool sendJsonEcnoded = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        key: scaffoldKey,
        appBar: showAppbar
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                centerTitle: true,
                title: ValueListenableBuilder<DateTime>(
                    valueListenable: headerDateNotifier,
                    builder:
                        (BuildContext context, DateTime value, Widget? child) =>
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                timeTableController.events.length.toString(),
                                style: context.termPlannerTitle,
                              ),
                            )),
                leading: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    final DateTime now = DateTime.now();

                    timeTableController.jumpTo(DateTime(
                        now.year, now.month, now.day, now.hour, now.minute));
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.black,
                    ),
                    onPressed: () async {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.update,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      // final PlannerEvent oldEvent = dummyEventData.first;
                      // final PlannerEvent newEvent = oldEvent;
                      // newEvent.eventData!.color = Colors.red;
                      // timeTableController.updateEvent(oldEvent, newEvent);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      // final List<PlannerEvent> events =
                      //dummyEventData.sublist(0, 1);
                      // timeTableController.removeEvent(events);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      //   final List<PlannerEvent> events = dummyEventData;
                      //   timeTableController.addEvent(
                      //     events,
                      //   );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      scaffoldKey.currentState!.openEndDrawer();
                      return;
                    },
                  ),
                ],
              )
            : null,
        endDrawer: SettingDrawer(
          startDate: startDate,
          isMobile: isMobile,
          endDate: endDate,
          onDateChange: (DateTime start, DateTime end) {
            setState(() {
              startDate = start;
              endDate = end;
              timeTableController.changeDate(startDate, endDate);
            });
          },
        ),
        body: SafeArea(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints value) {
            isMobile = value.maxWidth < mobileThreshold;
            debugPrint('building calenda rgain');
            return Row(
              children: <Widget>[
                isMobile ? const SizedBox.shrink() : const LeftStrip(),
                Expanded(
                    child: ValueListenableBuilder<CalendarViewType>(
                        valueListenable: viewTypeNotifer,
                        builder: (BuildContext context,
                                CalendarViewType viewType, Widget? child) =>
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) =>
                                      ScaleTransition(
                                          scale: animation, child: child),
                              child: IndexedStack(
                                index: getIndex(viewType),
                                children: <Widget>[
                                  DayPlanner(
                                    customPeriods: periods,
                                    timetableController: timeTableController,
                                    onEventDragged:
                                        (CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent,
                                            Period? period) {
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .updateEvent(old, newEvent, period);
                                    },
                                    onTap: (DateTime dateTime, Period? period,
                                        CalendarEvent<EventData>? event) {
                                      final TimeTableCubit cubit =
                                          BlocProvider.of<TimeTableCubit>(
                                              context);
                                      if (event == null && period != null) {
                                        cubit.nativeCallBack
                                            .sendAddEventToNativeApp(dateTime,
                                                cubit.viewType, period,
                                                jsonEcoded: sendJsonEcnoded);
                                      } else if (event != null) {
                                        cubit.nativeCallBack
                                            .sendShowEventToNativeApp(
                                                dateTime,
                                                <CalendarEvent<EventData>>[
                                                  event
                                                ],
                                                cubit.viewType);
                                      }
                                    },
                                  ),
                                  WeekPlanner<EventData>(
                                    customPeriods: periods,
                                    timetableController: timeTableController,
                                    onTap: (DateTime dateTime, Period? period,
                                        CalendarEvent<EventData>? event) {
                                      final TimeTableCubit cubit =
                                          BlocProvider.of<TimeTableCubit>(
                                              context);
                                      if (event == null && period != null) {
                                        cubit.nativeCallBack
                                            .sendAddEventToNativeApp(dateTime,
                                                cubit.viewType, period,
                                                jsonEcoded: sendJsonEcnoded);
                                      } else if (event != null) {
                                        cubit.nativeCallBack
                                            .sendShowEventToNativeApp(
                                                dateTime,
                                                <CalendarEvent<EventData>>[
                                                  event
                                                ],
                                                cubit.viewType);
                                      }
                                    },
                                    onEventDragged:
                                        (CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent,
                                            Period? period) {
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .updateEvent(old, newEvent, period);
                                    },
                                  ),
                                  SchedulePlanner(
                                    customPeriods: periods,
                                    timetableController: timeTableController,
                                    isMobile: isMobile,
                                    onTap: (DateTime dateTime,
                                        Period? period,
                                        List<CalendarEvent<EventData>>?
                                            events) {
                                      final TimeTableCubit cubit =
                                          BlocProvider.of<TimeTableCubit>(
                                              context);
                                      if (events == null && period == null) {
                                        cubit.nativeCallBack
                                            .sendAddEventToNativeApp(dateTime,
                                                cubit.viewType, period,
                                                jsonEcoded: sendJsonEcnoded);
                                      } else if (events != null) {
                                        cubit.nativeCallBack
                                            .sendShowEventToNativeApp(
                                                dateTime, events, viewType);
                                        // cubit.nativeCallBack
                                        //     .sendShowEventToNativeApp(
                                        //         dateTime,
                                        //        ,events,
                                        //         cubit.viewType);
                                      }
                                    },
                                  ),
                                  MonthPlanner(
                                    timetableController: timeTableController,
                                    onMonthChanged: (Month month) {
                                      setState(() {
                                        dateTime = DateTime(
                                            month.year, month.month, 15);
                                      });
                                    },
                                    onTap: (DateTime dateTime,
                                        List<CalendarEvent<EventData>> event) {
                                      final TimeTableCubit cubit =
                                          BlocProvider.of<TimeTableCubit>(
                                              context);
                                      if (event.isEmpty) {
                                        cubit.nativeCallBack
                                            .sendAddEventToNativeApp(
                                                dateTime, cubit.viewType, null,
                                                jsonEcoded: sendJsonEcnoded);
                                      } else {
                                        cubit.nativeCallBack
                                            .sendShowEventToNativeApp(dateTime,
                                                event, cubit.viewType);
                                      }
                                    },
                                  ),
                                  TermPlanner(
                                    timetableController: timeTableController,
                                    onMonthChanged: (Month month) {
                                      setState(() {
                                        dateTime = DateTime(
                                            month.year, month.month, 15);
                                      });
                                    },
                                    onTap: (DateTime dateTime,
                                        List<CalendarEvent<EventData>> event) {
                                      final TimeTableCubit cubit =
                                          BlocProvider.of<TimeTableCubit>(
                                              context);
                                      if (event.isEmpty) {
                                        cubit.nativeCallBack
                                            .sendAddEventToNativeApp(
                                                dateTime, cubit.viewType, null);
                                      } else {
                                        cubit.nativeCallBack
                                            .sendShowEventToNativeApp(dateTime,
                                                event, cubit.viewType);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ))),
                isMobile
                    ? const SizedBox.shrink()
                    : BlocConsumer<TimeTableCubit, TimeTableState>(
                        listener:
                            (BuildContext context, TimeTableState state) {},
                        builder: (BuildContext context, TimeTableState state) {
                          final TermModel termModel =
                              BlocProvider.of<TimeTableCubit>(context)
                                  .termModel;
                          return RightStrip(
                            termModel: termModel,
                          );
                        }),
              ],
            );
          }),
        ),
      );
}

///get index of the index stack
int getIndex(CalendarViewType viewType) {
  switch (viewType) {
    case CalendarViewType.dayView:
      return 0;
    case CalendarViewType.weekView:
      return 1;
    case CalendarViewType.scheduleView:
      return 2;
    case CalendarViewType.monthView:
      return 3;
    case CalendarViewType.termView:
      return 4;
    case CalendarViewType.glScheduleView:
      return 5;
    default:
      return 2;
  }
}
