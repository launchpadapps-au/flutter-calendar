import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/day_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/month_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/schedule_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/setting.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/term_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/week_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/appbar.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/left_strip.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/linear_indicator.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/right_strip.dart';
import 'package:flutter/material.dart';
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
  TimetableController<Note> monthController = TimetableController<Note>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.breakHeighth,
    cellHeight: CalendarParams.cellHeighth,
  );
  TimetableController<Note> termController = TimetableController<Note>(
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
    logInfo('date changed $dateTime');
    BlocProvider.of<TimeTableCubit>(context)
      ..setDate(dateTime)
      ..nativeCallBack.sendVisibleDateChnged(dateTime);
  }

  @override
  void initState() {
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
        logInfo('Date is updating in calendar: date updaed');
        dateForHeader = event.startDate;
        headerDateNotifier.value = dateForHeader;

        // timeTableController.jumpTo(dateForHeader);
      }
      if (event is CurrrentDateUpdated) {
        dateForHeader = event.currentDate;
        headerDateNotifier.value = dateForHeader;
      } else if (event is ViewUpdated) {
        logInfo('view updated in calendar');

        final CalendarViewType requstedView = event.viewType;

        viewTypeNotifer.value = requstedView;
        timeTableController.jumpTo(cubit.date);
        dayController.jumpTo(cubit.date);
        scheduleController.jumpTo(cubit.date);
        monthController.jumpTo(cubit.date);
        termController.jumpTo(cubit.date);
      } else if (event is JumpToDateState) {
        logInfo('jumping to date in calendar ${event.dateTime}');
        timeTableController.jumpTo(event.dateTime);
        dayController.jumpTo(event.dateTime);
        scheduleController.jumpTo(event.dateTime);
        dateForHeader = event.dateTime;
        headerDateNotifier.value = dateForHeader;
        monthController.jumpTo(event.dateTime);
        termController.jumpTo(event.dateTime);
      } else if (event is LoadedState) {
        logInfo('Setting event in calendar');

        if (event.events.isNotEmpty) {
          timeTableController.addEvent(event.events, replace: true);
          dayController.addEvent(event.events, replace: true);
          final List<PlannerEvent> e = event.events;
          scheduleController.addEvent(
              e
                  .where((PlannerEvent element) => element.eventData!.isLesson)
                  .toList(),
              replace: true);
          monthController.addEvent(event.notes, replace: true);
          termController.addEvent(event.notes, replace: true);
        }
      } else if (event is EventUpdatedState) {
        logInfo('updating events in calendar');
        timeTableController.updateEvent(event.oldEvent, event.newEvent);
        dayController.updateEvent(event.oldEvent, event.newEvent);
        scheduleController.updateEvent(event.oldEvent, event.newEvent);
      } else if (event is EventsAdded) {
        logInfo('adding events in calendar');
        timeTableController.addEvent(event.events, replace: true);
        dayController.addEvent(event.events, replace: true);
        final List<PlannerEvent> e = event.events;
        scheduleController.addEvent(
            e
                .where((PlannerEvent element) => element.eventData!.isLesson)
                .toList(),
            replace: true);
      } else if (event is NotesAdded) {
        logInfo('adding notes in calendar');

        monthController.addEvent(event.notes, replace: true);
        termController.addEvent(event.notes, replace: true);
      } else if (event is PeriodsUpdated) {
        periods = event.periods;
        setState(() {
          logInfo('Setting periods in calendar');
        });
      } else if (event is DeletedEvents) {
        timeTableController.removeEvent(event.deletedEvents);
        dayController.removeEvent(event.deletedEvents);
        scheduleController.removeEvent(event.deletedEvents);

        logInfo('removing events from calendar');
      } else if (event is TermsUpdated) {
        final Term term = BlocProvider.of<TimeTableCubit>(context).term;
        logInfo('Current Term:$term');
        termController.changeDate(term.startDate, term.endDate);
        monthController.changeDate(term.startDate, term.endDate);
        // timeTableController.jumpTo(term.startDate);
      } else if (event is MonthUpdated) {
        logInfo('Month Updated');
        dateForHeader = event.startDate;
        monthController.changeDate(event.startDate, event.endDate);
        timeTableController.jumpTo(event.startDate);
        dayController.jumpTo(event.startDate);
        scheduleController.jumpTo(event.startDate);
        headerDateNotifier.value = dateForHeader;
      } else if (event is GeneratePreview) {}
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

  bool showAppbar = true;
  bool enableTapForExtraSlot = false;

  ///page storage bucket for the view
  final PageStorageBucket pageStorageBucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: white,
        appBar: showAppbar
            ? CalendarAppBar(
                viewTypeNotifer: viewTypeNotifer,
                headerDateNotifier: headerDateNotifier,
                scaffoldKey: scaffoldKey)
            : null,
        endDrawer: SettingDrawer(
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
        ),
        body: SafeArea(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints value) {
            isMobile = value.maxWidth < mobileThreshold;

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
            log
              ..info(old.toMap.toString())
              ..info(newEvent.toMap.toString());

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
          onTap: (DateTime dateTime, List<CalendarEvent<Note>> event) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            if (event.isEmpty) {
              cubit.nativeCallBack.sendAddNote(dateTime, cubit.viewType);
            } else if (event.length == 1) {
              cubit.nativeCallBack
                  .sendShowNote(event.first.eventData!, cubit.viewType);
            } else {
              logInfo('No method for multiple note tap');
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
          onTap: (DateTime dateTime, List<CalendarEvent<Note>> event) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            if (event.isEmpty) {
              cubit.nativeCallBack.sendAddNote(dateTime, cubit.viewType);
            } else if (event.length == 1) {
              cubit.nativeCallBack
                  .sendShowNote(event.first.eventData!, cubit.viewType);
            } else {
              logInfo('No method for multiple note tap');
            }
          },
        ),
      ].skip(0).toList();
}
