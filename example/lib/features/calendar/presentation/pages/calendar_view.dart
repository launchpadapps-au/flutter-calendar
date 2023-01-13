import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_settings.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/month_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/day_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/schedule_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/setting.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/term_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/week_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/left_strip.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/linear_indicator.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/right_strip.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/export_setting_view.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/export_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///Calendar view for the app
class CalendarView extends StatefulWidget {
  ///
  const CalendarView({Key? key, this.id}) : super(key: key);

  ///id that we will received from native ios
  final String? id;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  TimetableController<EventData> timeTableController =
      TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.breakHeighth,
    cellHeight: CalendarParams.cellHeighth,
  );
  TimetableController<EventData> dayController = TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.breakHeighth,
    cellHeight: CalendarParams.cellHeighth,
  );
  TimetableController<EventData> scheduleController =
      TimetableController<EventData>(
          start: DefaultDates.startDate,
          infiniteScrolling: CalendarParams.infiniteScrolling,
          end: DefaultDates.endDate,
          timelineWidth: CalendarParams.timelineWidth,
          breakHeight: CalendarParams.breakHeighth,
          cellHeight: CalendarParams.cellHeighth);
  TimetableController<EventData> monthController =
      TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.breakHeighth,
    cellHeight: CalendarParams.cellHeighth,
  );
  TimetableController<EventData> termController =
      TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.breakHeighth,
    cellHeight: CalendarParams.cellHeighth,
  );

  /// Used to display the current month in the app bar.
  DateTime dateTime = DateTime.now();

  static bool isMobile = true;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static DateTime dateForHeader = DateTime.now();
  ValueNotifier<DateTime> headerDateNotifier =
      ValueNotifier<DateTime>(dateForHeader);
  int index = 0;

  void onDateChange(DateTime dateTime) {
    log('date changed $dateTime');
    BlocProvider.of<TimeTableCubit>(context)
      ..setDate(dateTime)
      ..nativeCallBack.sendVisibleDateChnged(dateTime);
  }

  @override
  void initState() {
    log('\nFlutter Module is reloading\n');
    Future<void>.delayed(const Duration(milliseconds: 350))
        .then((dynamic value) {
      final DateTime date = DateTime.now();

      timeTableController.jumpTo(date);
      dayController.jumpTo(date);
      scheduleController.jumpTo(date);
      monthController.jumpTo(date);
      termController.jumpTo(date);
    });
    final TimeTableCubit cubit = BlocProvider.of<TimeTableCubit>(context);
    cubit.stream.listen((TimeTableState event) {
      if (event is DateUpdated) {
        debugPrint('Date is updating in calendar: date updaed');
        dateForHeader = event.startDate;
        headerDateNotifier.value = dateForHeader;

        // timeTableController.jumpTo(dateForHeader);
      }
      if (event is CurrrentDateUpdated) {
        dateForHeader = event.currentDate;
        headerDateNotifier.value = dateForHeader;
      } else if (event is ViewUpdated) {
        debugPrint('view updated in calendar');

        final CalendarViewType requstedView = event.viewType;

        viewTypeNotifer.value = requstedView;
        timeTableController.jumpTo(cubit.date);
        dayController.jumpTo(cubit.date);
        scheduleController.jumpTo(cubit.date);
        monthController.jumpTo(cubit.date);
        termController.jumpTo(cubit.date);
      } else if (event is JumpToDateState) {
        debugPrint('jumping to date in calendar ${event.dateTime}');
        timeTableController.jumpTo(event.dateTime);
        dayController.jumpTo(event.dateTime);
        scheduleController.jumpTo(event.dateTime);
        dateForHeader = event.dateTime;
        headerDateNotifier.value = dateForHeader;
        monthController.jumpTo(event.dateTime);
        termController.jumpTo(event.dateTime);
      } else if (event is LoadedState) {
        debugPrint('Setting event in calendar');

        if (event.events.isNotEmpty) {
          timeTableController.addEvent(event.events, replace: true);
          dayController.addEvent(event.events, replace: true);
          final List<PlannerEvent> e = event.events;
          scheduleController.addEvent(
              e
                  .where((PlannerEvent element) => element.eventData!.isLesson)
                  .toList(),
              replace: true);
          monthController.addEvent(event.events, replace: true);
          termController.addEvent(event.events, replace: true);
        }
      } else if (event is EventUpdatedState) {
        debugPrint('updating events in calendar');
        timeTableController.updateEvent(event.oldEvent, event.newEvent);
        dayController.updateEvent(event.oldEvent, event.newEvent);
        scheduleController.updateEvent(event.oldEvent, event.newEvent);
      } else if (event is EventsAdded) {
        debugPrint('adding events in calendar');
        timeTableController.addEvent(event.events, replace: true);
        dayController.addEvent(event.events, replace: true);
        final List<PlannerEvent> e = event.events;
        scheduleController.addEvent(
            e
                .where((PlannerEvent element) => element.eventData!.isLesson)
                .toList(),
            replace: true);

        monthController.addEvent(event.events, replace: true);
        termController.addEvent(event.events, replace: true);
      } else if (event is PeriodsUpdated) {
        periods = event.periods;
        setState(() {
          debugPrint('Setting periods in calendar');
        });
      } else if (event is DeletedEvents) {
        timeTableController.removeEvent(event.deletedEvents);
        dayController.removeEvent(event.deletedEvents);
        scheduleController.removeEvent(event.deletedEvents);
        monthController.removeEvent(event.deletedEvents);
        termController.removeEvent(event.deletedEvents);
        debugPrint('removing events from calendar');
      } else if (event is TermsUpdated) {
        final Term term = BlocProvider.of<TimeTableCubit>(context).term;
        debugPrint('Current Term:$term');
        termController.changeDate(term.startDate, term.endDate);
        monthController.changeDate(term.startDate, term.endDate);
        // timeTableController.jumpTo(term.startDate);
      } else if (event is MonthUpdated) {
        debugPrint('Month Updated');
        dateForHeader = event.startDate;
        monthController.changeDate(event.startDate, event.endDate);
        timeTableController.jumpTo(event.startDate);
        dayController.jumpTo(event.startDate);
        scheduleController.jumpTo(event.startDate);
        headerDateNotifier.value = dateForHeader;
      } else if (event is ExportPreview) {
        final ExportSetting exportSetting = event.exportSetting;
        // Preview.exportWeekView(exportSetting.startFrom, exportSetting.endTo,
        //     cubit.periods, cubit.events, context);

        if (event.exportSetting.view.contains(CalendarViewType.dayView)) {
          ExportView.exportDayView(
              startDate: exportSetting.startFrom,
              endDate: exportSetting.endTo,
              timelines: cubit.periods,
              event: cubit.events,
              saveImage: exportSetting.saveImg,
              fullWeek: exportSetting.fullWeek,
              subjects: exportSetting.subjects,
              pageFormat: exportSetting.pageFormat,
              context: context);
        } else if (event.exportSetting.view
            .contains(CalendarViewType.weekView)) {
          ExportView.exportWeekView(
              startDate: exportSetting.startFrom,
              endDate: exportSetting.endTo,
              timelines: cubit.periods,
              event: cubit.events,
              saveImage: exportSetting.saveImg,
              fullWeek: exportSetting.fullWeek,
              subjects: exportSetting.subjects,
              pageFormat: exportSetting.pageFormat,
              context: context);
        } else if (event.exportSetting.view
            .contains(CalendarViewType.monthView)) {
          ExportView.exportMonthView(
              startDate: exportSetting.startFrom,
              endDate: exportSetting.endTo,
              timelines: cubit.periods,
              event: cubit.events,
              saveImage: exportSetting.saveImg,
              context: context);
        }
      }
    });
    super.initState();
  }

  List<Period> periods = customStaticPeriods;

  ValueNotifier<CalendarViewType> viewTypeNotifer =
      ValueNotifier<CalendarViewType>(CalendarViewType.weekView);

  bool sendJsonEcnoded = false;

  @override
  void dispose() {
    super.dispose();
  }

  bool showAppbar = false;
  bool enableTapForExtraSlot = false;

  ///page storage bucket for the view
  final PageStorageBucket pageStorageBucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: white,
        appBar: showAppbar
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        final CalendarViewType view = viewTypeNotifer.value;
                        final TimeTableCubit cubit =
                            BlocProvider.of<TimeTableCubit>(context);
                        if (view == CalendarViewType.dayView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.previousDay, null);
                        } else if (view == CalendarViewType.weekView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.previousWeek, null);
                        } else if (view == CalendarViewType.monthView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.previousMonth, null);
                        } else if (view == CalendarViewType.termView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.previousTerm, null);
                        }
                      },
                    ),
                    ValueListenableBuilder<DateTime>(
                        valueListenable: headerDateNotifier,
                        builder: (BuildContext context, DateTime value,
                                Widget? child) =>
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                BlocProvider.of<TimeTableCubit>(context)
                                    .date
                                    .toString()
                                    .substring(0, 10),
                                style: context.termPlannerTitle,
                              ),
                            )),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        final CalendarViewType view = viewTypeNotifer.value;
                        final TimeTableCubit cubit =
                            BlocProvider.of<TimeTableCubit>(context);
                        if (view == CalendarViewType.dayView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.nextDay, null);
                        } else if (view == CalendarViewType.weekView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.nextWeek, null);
                        } else if (view == CalendarViewType.monthView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.nextMonth, null);
                        } else if (view == CalendarViewType.termView) {
                          cubit.mockObject
                              .invokeMethod(ReceiveMethods.nextTerm, null);
                        }
                      },
                    ),
                  ],
                ),
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
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        BlocProvider.of<TimeTableCubit>(context)
                            .mockObject
                            .invokeMethod(
                                ReceiveMethods.jumpToCurrentDate, null);
                      }),
                  IconButton(
                      icon: const Icon(
                        Icons.image,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  const ExportSettingView(),
                            ));
                      }),
                ],
              )
            : null,
        endDrawer: showAppbar
            ? SettingDrawer(
                startDate: DefaultDates.startDate,
                isMobile: isMobile,
                endDate: DefaultDates.startDate,
                onDateChange: (DateTime start, DateTime end) {
                  setState(() {
                    timeTableController.changeDate(start, end);
                    dayController.changeDate(start, end);
                    scheduleController.changeDate(start, end);
                  });
                },
              )
            : null,
        body: SafeArea(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints value) {
            isMobile = value.maxWidth < mobileThreshold;
            debugPrint('building calenda rgain');
            return Row(
              children: <Widget>[
                isMobile ? const SizedBox.shrink() : const LeftStrip(),
                Expanded(
                    child: Column(
                  children: <Widget>[
                    const LinearIndicator(),
                    Expanded(
                      child: ValueListenableBuilder<CalendarViewType>(
                          valueListenable: viewTypeNotifer,
                          builder: (BuildContext context,
                                  CalendarViewType viewType, Widget? child) =>
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child,
                                        Animation<double> animation) =>
                                    FadeTransition(
                                        opacity: animation, child: child),
                                child: PageStorage(
                                  bucket: pageStorageBucket,
                                  child: getViewList()[getIndex(viewType)],
                                ),
                              )),
                    ),
                  ],
                )),
                isMobile ? const SizedBox.shrink() : const RightStrip(),
              ],
            );
          }),
        ),
      );

  List<Widget> getViewList() => <Widget>[
        DayPlanner(
          customPeriods: periods,
          isMobile: isMobile,
          timetableController: dayController,
          onDateChanged: (DateTime dateTime) {
            dateForHeader = dateTime;
            headerDateNotifier.value = dateForHeader;
            onDateChange(dateTime);
          },
          onEventDragged: (CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent, Period? period) {
            BlocProvider.of<TimeTableCubit>(context)
                .onEventDragged(old, newEvent, period);
          },
          onEventToEventDragged: (CalendarEvent<EventData> existing,
              CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent,
              Period? periodModel) {
            final CalendarEvent<EventData> eventToUpdate = newEvent
              ..eventData!.slots = existing.eventData!.slots;
            BlocProvider.of<TimeTableCubit>(context)
                .onEventDragged(old, eventToUpdate, periodModel);
          },
          onTap: (DateTime dateTime, Period? period,
              CalendarEvent<EventData>? event) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            if (event == null && period != null) {
              final PeriodModel periodModel = period as PeriodModel;
              if (enableTapForExtraSlot &&
                  (periodModel.isBeforeSchool || period.isAfterSchool)) {
                cubit.nativeCallBack.sendAddEventToNativeApp(
                    dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              } else if (!period.isCustomeSlot) {
                cubit.nativeCallBack.sendAddEventToNativeApp(
                    dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              }
            } else if (event != null) {
              PeriodModel? periodModel;

              try {
                periodModel = BlocProvider.of<TimeTableCubit>(context)
                    .periods
                    .firstWhere((PeriodModel element) =>
                        element.id == event.eventData!.slots);
              } on Exception {
                periodModel = null;
              }

              if (periodModel != null &&
                  (periodModel.isAfterSchool || periodModel.isBeforeSchool)) {
                cubit.nativeCallBack.sendShowDutyToNativeApp(dateTime,
                    <CalendarEvent<EventData>>[event], cubit.viewType);
              } else {
                cubit.nativeCallBack.sendShowEventToNativeApp(dateTime,
                    <CalendarEvent<EventData>>[event], cubit.viewType);
              }
            }
          },
        ),
        WeekPlanner<EventData>(
          customPeriods: periods,
          isMobile: isMobile,
          timetableController: timeTableController,
          onDateChanged: (DateTime dateTime) {
            dateForHeader = dateTime;
            headerDateNotifier.value = dateForHeader;
            onDateChange(dateTime);
          },
          onTap: (DateTime dateTime, Period? period,
              CalendarEvent<EventData>? event) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            if (event == null && period != null) {
              final PeriodModel periodModel = period as PeriodModel;
              if (enableTapForExtraSlot &&
                  (periodModel.isBeforeSchool || period.isAfterSchool)) {
                cubit.nativeCallBack.sendAddEventToNativeApp(
                    dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              } else if (!period.isCustomeSlot) {
                cubit.nativeCallBack.sendAddEventToNativeApp(
                    dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              }
            } else if (event != null) {
              PeriodModel? periodModel;

              try {
                periodModel = BlocProvider.of<TimeTableCubit>(context)
                    .periods
                    .firstWhere((PeriodModel element) =>
                        element.id == event.eventData!.slots);
              } on Exception {
                periodModel = null;
              }

              if (periodModel != null &&
                  (periodModel.isAfterSchool || periodModel.isBeforeSchool)) {
                cubit.nativeCallBack.sendShowDutyToNativeApp(dateTime,
                    <CalendarEvent<EventData>>[event], cubit.viewType);
              } else {
                cubit.nativeCallBack.sendShowEventToNativeApp(dateTime,
                    <CalendarEvent<EventData>>[event], cubit.viewType);
              }
            }
          },
          onEventDragged: (CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent, Period? period) {
            log(old.toMap.toString());
            log(newEvent.toMap.toString());

            BlocProvider.of<TimeTableCubit>(context)
                .onEventDragged(old, newEvent, period);
          },
          onEventToEventDragged: (CalendarEvent<EventData> existing,
              CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent,
              Period? periodModel) {
            final CalendarEvent<EventData> eventToUpdate = newEvent
              ..eventData!.slots = existing.eventData!.slots;
            BlocProvider.of<TimeTableCubit>(context)
                .onEventDragged(old, eventToUpdate, periodModel);
          },
        ),
        SchedulePlanner<EventData>(
          customPeriods: periods,
          timetableController: scheduleController,
          isMobile: isMobile,
          onDateChanged: (DateTime dateTime) {
            dateForHeader = dateTime;
            headerDateNotifier.value = dateForHeader;
            onDateChange(dateTime);
          },
          onEventDragged: (CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent) {
            BlocProvider.of<TimeTableCubit>(context)
                .onEventDragged(old, newEvent, null);
          },
          onTap: (DateTime dateTime, Period? period,
              List<CalendarEvent<EventData>>? events) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            if (events == null && period == null) {
              cubit.nativeCallBack.sendAddEventToNativeApp(
                  dateTime, cubit.viewType, period,
                  jsonEcoded: sendJsonEcnoded);
            } else if (events != null) {
              cubit.nativeCallBack
                  .sendShowEventToNativeApp(dateTime, events, cubit.viewType);

              // cubit.nativeCallBack
              //     .sendShowEventToNativeApp(
              //         dateTime,
              //        ,events,
              //         cubit.viewType);
            }
          },
          onEventToEventDragged: (CalendarEvent<EventData> existing,
              CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent,
              Period? periodModel) {
            final CalendarEvent<EventData> eventToUpdate = newEvent
              ..eventData!.slots = existing.eventData!.slots;
            BlocProvider.of<TimeTableCubit>(context)
                .onEventDragged(old, eventToUpdate, periodModel);
          },
        ),
        MonthPlanner(
          timetableController: monthController,
          onMonthChanged: (Month month) {
            setState(() {
              dateTime = DateTime(month.year, month.month, 15);
            });
          },
          onTap: (DateTime dateTime, List<CalendarEvent<EventData>> event) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            if (event.isEmpty) {
              cubit.nativeCallBack.sendAddEventToNativeApp(
                  dateTime, cubit.viewType, null,
                  jsonEcoded: sendJsonEcnoded);
            } else {
              cubit.nativeCallBack
                  .sendShowEventToNativeApp(dateTime, event, cubit.viewType);
            }
          },
        ),
        TermPlanner(
          timetableController: termController,
          onMonthChanged: (Month month) {
            setState(() {
              dateTime = DateTime(month.year, month.month, 15);
            });
          },
          onTap: (DateTime dateTime, List<CalendarEvent<EventData>> event) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            if (event.isEmpty) {
              cubit.nativeCallBack
                  .sendAddEventToNativeApp(dateTime, cubit.viewType, null);
            } else {
              cubit.nativeCallBack
                  .sendShowEventToNativeApp(dateTime, event, cubit.viewType);
            }
          },
        ),
      ].skip(0).toList();
}
