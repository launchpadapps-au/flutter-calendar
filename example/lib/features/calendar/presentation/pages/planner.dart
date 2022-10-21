import 'dart:developer';

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
  static DateTime startDate = DateTime(2022, 10);
  static DateTime endDate = startDate.add(const Duration(days: 30));
  TimetableController<EventData> timeTableController =
      TimetableController<EventData>(
          start: startDate,
          end: endDate,
          timelineWidth: 60,
          breakHeight: 35,
          infiniteScrolling: false,
          cellHeight: 110);
  TimetableController<EventData> monthController =
      TimetableController<EventData>(
          start: startDate,
          end: endDate,
          timelineWidth: 60,
          breakHeight: 35,
          cellHeight: 110);
  TimetableController<EventData> termController =
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

  void onDateChange(DateTime dateTime) {
    log(dateTime.toString());
    BlocProvider.of<TimeTableCubit>(context).setDate(dateTime);
  }

  @override
  void initState() {
    periods = customStaticPeriods;
    setState(() {});
    BlocProvider.of<TimeTableCubit>(context)
        .stream
        .listen((TimeTableState event) {
      if (event is DateUpdated) {
        debugPrint('Date is updating in calendar');
        dateForHeader = event.startDate;
        timeTableController
          ..changeDate(event.startDate, event.endDate)
          ..jumpTo(dateForHeader);
      } else if (event is ViewUpdated) {
        debugPrint('view updated in calendar');

        timeTableController.jumpTo(dateForHeader);

        viewTypeNotifer.value = event.viewType;
      } else if (event is JumpToDateState) {
        debugPrint('jumping to date in calendar');
        final bool isToday = isSameDate(event.dateTime);
        if (isToday) {
          if (viewTypeNotifer.value == CalendarViewType.monthView ||
              viewTypeNotifer.value == CalendarViewType.termView) {
            viewTypeNotifer.value = CalendarViewType.weekView;
            dateForHeader = event.dateTime;
            BlocProvider.of<TimeTableCubit>(context)
                .changeViewType(CalendarViewType.weekView);
          }
        } else {}
      } else if (event is LoadedState) {
        debugPrint('Setting event in calendar');

        if (event.events.isNotEmpty) {
          timeTableController.addEvent(event.events, replace: true);
          monthController.addEvent(event.events, replace: true);
          termController.addEvent(event.events, replace: true);
        }
      } else if (event is EventUpdatedState) {
        debugPrint('updating events in calendar');
        timeTableController.updateEvent(event.oldEvent, event.newEvent);
      } else if (event is EventsAdded) {
        debugPrint('adding events in calendar');
        timeTableController.addEvent(event.events, replace: true);
        monthController.addEvent(event.events, replace: true);
        termController.addEvent(event.events, replace: true);
      } else if (event is PeriodsUpdated) {
        periods = event.periods;
        setState(() {
          debugPrint('Setting periods in calendar');
        });
      } else if (event is DeletedEvents) {
        timeTableController.removeEvent(event.deletedEvents);
        monthController.removeEvent(event.deletedEvents);
        termController.removeEvent(event.deletedEvents);
        debugPrint('removing events from calendar');
      } else if (event is TermsUpdated) {
      } else if (event is MonthUpdated) {
        dateForHeader = event.startDate;
        monthController.changeDate(event.startDate, event.endDate);

        timeTableController.jumpTo(event.startDate);
        headerDateNotifier.value = dateForHeader;
      }
    });
    super.initState();
  }

  List<Period> periods = <PeriodModel>[];

  ValueNotifier<CalendarViewType> viewTypeNotifer =
      ValueNotifier<CalendarViewType>(CalendarViewType.weekView);

  bool sendJsonEcnoded = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final DateTime now = DateTime.now();
            final DateTime date = DateTime(2022, 10, 19, now.hour, now.minute);
            log(date.toUtc().toIso8601String());
          },
          child: const Icon(Icons.monetization_on),
        ),
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
                                dateForHeader.toString().substring(0, 10),
                                style: context.termPlannerTitle,
                              ),
                            )),
                leading: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    scaffoldKey.currentState!.openEndDrawer();
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
                      final DateTime startDate = DateTime(2022, 9);
                      final DateTime endDate =
                          startDate.add(const Duration(days: 30));
                      timeTableController..changeDate(startDate, endDate)
                      ..jumpTo(startDate);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      timeTableController.jumpTo(DateTime.now());
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
              timeTableController..changeDate(startDate, endDate)
              ..jumpTo(startDate);
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
                                    onDateChanged: (DateTime dateTime) {
                                      dateForHeader = dateTime;
                                      headerDateNotifier.value = dateForHeader;
                                      onDateChange(dateTime);
                                    },
                                    onEventDragged:
                                        (CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent,
                                            Period? period) {
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .onEventDragged(
                                              old, newEvent, period);
                                    },
                                    onEventToEventDragged:
                                        (CalendarEvent<EventData> existing,
                                            CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent,
                                            Period? periodModel) {
                                      final Period period =
                                          existing.eventData!.period;
                                      final CalendarEvent<EventData>
                                          eventToUpdate = newEvent
                                            ..eventData!.period;
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .onEventDragged(
                                              old, eventToUpdate, period);
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
                                    onDateChanged: (DateTime dateTime) {
                                      dateForHeader = dateTime;
                                      headerDateNotifier.value = dateForHeader;
                                      onDateChange(dateTime);
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
                                    onEventDragged:
                                        (CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent,
                                            Period? period) {
                                      log(old.toMap.toString());
                                      log(newEvent.toMap.toString());

                                      BlocProvider.of<TimeTableCubit>(context)
                                          .onEventDragged(
                                              old, newEvent, period);
                                    },
                                    onEventToEventDragged:
                                        (CalendarEvent<EventData> existing,
                                            CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent,
                                            Period? periodModel) {
                                      final Period period =
                                          existing.eventData!.period;
                                      final CalendarEvent<EventData>
                                          eventToUpdate = newEvent
                                            ..eventData!.period;
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .onEventDragged(
                                              old, eventToUpdate, period);
                                    },
                                  ),
                                  SchedulePlanner<EventData>(
                                    customPeriods: periods,
                                    timetableController: timeTableController,
                                    isMobile: isMobile,
                                    onDateChanged: (DateTime dateTime) {
                                      dateForHeader = dateTime;
                                      headerDateNotifier.value = dateForHeader;
                                      onDateChange(dateTime);
                                    },
                                    onEventDragged:
                                        (CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent) {
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .onEventDragged(old, newEvent,
                                              old.eventData!.period);
                                    },
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
                                    onEventToEventDragged:
                                        (CalendarEvent<EventData> existing,
                                            CalendarEvent<EventData> old,
                                            CalendarEvent<EventData> newEvent,
                                            Period? periodModel) {
                                      final Period period =
                                          existing.eventData!.period;
                                      final CalendarEvent<EventData>
                                          eventToUpdate = newEvent
                                            ..eventData!.period;
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .onEventDragged(
                                              old, eventToUpdate, period);
                                    },
                                  ),
                                  MonthPlanner(
                                    timetableController: monthController,
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
                                    timetableController: termController,
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
