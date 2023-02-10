import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart';
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

class NewCalendarView extends StatefulWidget {
  const NewCalendarView({super.key});
  static bool isMobile = true;

  static DateTime dateForHeader = DateTime.now();

  @override
  State<NewCalendarView> createState() => _NewCalendarViewState();
}

class _NewCalendarViewState extends State<NewCalendarView>
    with AutomaticKeepAliveClientMixin {
  final TimetableController<EventData> timeTableController =
      TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.mobileBreakHeight,
    cellHeight: CalendarParams.mobileCellHeight,
  );

  final TimetableController<EventData> dayController =
      TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.mobileBreakHeight,
    cellHeight: CalendarParams.mobileCellHeight,
  );

  final TimetableController<EventData> scheduleController =
      TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: !CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.mobileBreakHeight,
    cellHeight: CalendarParams.mobileCellHeight,
  );

  final TimetableController<Note> monthController = TimetableController<Note>(
    start: DefaultDates.monthStartDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.monthEndate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.tabBreakHeight,
    cellHeight: CalendarParams.tabCellHeight,
  );

  final TimetableController<Note> termController = TimetableController<Note>(
    start: DefaultDates.monthStartDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.monthEndate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.tabBreakHeight,
    cellHeight: CalendarParams.tabCellHeight,
  );

  /// Used to display the current month in the app bar.
  DateTime dateTime = DateTime.now();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<DateTime> headerDateNotifier =
      ValueNotifier<DateTime>(NewCalendarView.dateForHeader);

  PageController pageController = PageController(initialPage: 1);

  ValueNotifier<CalendarViewType> viewTypeNotifer =
      ValueNotifier<CalendarViewType>(CalendarViewType.weekView);

  int index = 0;
  bool showAppbar = true;
  bool isMobile = true;

  bool enableTapForExtraSlot = false;
  bool sendJsonEcnoded = false;
  List<Period> periods = customStaticPeriods;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      listenCubit(context);
    });
    super.initState();
  }

  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  void onResize() {
    final RenderBox? box =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    if (box.hasSize) {
      final Size size = box.size;

      if (size.width < mobileThreshold) {
        dayController.chageCellHeight(
            CalendarParams.mobileCellHeight, CalendarParams.mobileBreakHeight);
        timeTableController.chageCellHeight(
            CalendarParams.mobileCellHeight, CalendarParams.mobileBreakHeight);
        scheduleController.chageCellHeight(
            CalendarParams.mobileCellHeight, CalendarParams.mobileBreakHeight);
      } else {
        dayController.chageCellHeight(
            CalendarParams.tabCellHeight, CalendarParams.tabBreakHeight);
        timeTableController.chageCellHeight(
            CalendarParams.tabCellHeight, CalendarParams.tabBreakHeight);
        scheduleController.chageCellHeight(
            CalendarParams.tabCellHeight, CalendarParams.tabBreakHeight);
      }
    }
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      backgroundColor: white,
      appBar: showAppbar
          ? CalendarAppBar(
              headerDateNotifier: headerDateNotifier, scaffoldKey: scaffoldKey)
          : null,
      endDrawer: SettingDrawer(
        startDate: DefaultDates.startDate,
        isMobile: NewCalendarView.isMobile,
        endDate: DefaultDates.startDate,
        onDateChange: (DateTime start, DateTime end) {
          timeTableController.changeDate(start, end);
          dayController.changeDate(start, end);
          scheduleController.changeDate(start, end);
        },
      ),
      floatingActionButton: BlocBuilder<TimeTableCubit, TimeTableState>(
        builder: (BuildContext context, TimeTableState state) =>
            BlocProvider.of<TimeTableCubit>(context).standAlone
                ? FloatingActionButton(
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              firstDate: DefaultDates.startDate,
                              lastDate: DefaultDates.endDate,
                              initialDate: DateTime.now())
                          .then((DateTime? value) {
                        if (value != null) {
                          timeTableController.jumpTo(value);
                          dayController.jumpTo(value);
                          scheduleController.jumpTo(value);
                          monthController.jumpTo(value);
                          termController.jumpTo(value);
                        }
                      });
                    },
                    child: const Icon(Icons.calendar_month),
                  )
                : const SizedBox.shrink(),
      ),
      body: LayoutBuilder(
          key: _key,
          builder: (context, constrains) {
            isMobile = constrains.maxWidth < mobileThreshold;
            logPrety('Building Flutter Calendar UI');
            return Row(
              children: <Widget>[
                isMobile ? const SizedBox.shrink() : const LeftStrip(),
                Expanded(
                    child: Column(
                  children: <Widget>[
                    const LinearIndicator(),
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: getViewList(),
                      ),
                    ),
                  ],
                )),
                isMobile ? const SizedBox.shrink() : const RightStrip(),
              ],
            );
          }),
    );
  }

  void listenCubit(BuildContext context) {
    final TimeTableCubit cubit = BlocProvider.of<TimeTableCubit>(context);
    cubit.stream.listen((TimeTableState event) {
      if (event is DateUpdated) {
        logInfo('Date is updating in calendar: date updaed');

        headerDateNotifier.value = event.startDate;
      } else if (event is CurrrentDateUpdated) {
        headerDateNotifier.value = event.currentDate;
      } else if (event is ViewUpdated) {
        logPrety('view updated in calendar:${event.viewType}');

        final CalendarViewType requstedView = event.viewType;
        pageController.jumpToPage(CalendarUtils.getIndex(requstedView));

        viewTypeNotifer.value = requstedView;
        timeTableController.jumpTo(cubit.date);
        dayController.jumpTo(cubit.date);
        scheduleController.jumpTo(cubit.date);
        monthController.jumpTo(cubit.date);
        termController.jumpTo(cubit.date);
      } else if (event is JumpToDateState) {
        logInfo('jumping to date in calendar ${event.dateTime}');

        if (cubit.viewType == CalendarViewType.weekView) {
          if (DateUtils.isSameDay(event.dateTime, DateTime.now())) {
            final DateTime date =
                getMonday(DateTime.now()).add(Duration(days: isMobile ? 1 : 2));
            timeTableController.jumpTo(date);
          } else {
            timeTableController.jumpTo(event.dateTime);
          }
        }

        dayController.jumpTo(event.dateTime);
        scheduleController.jumpTo(event.dateTime);
        headerDateNotifier.value = event.dateTime;

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

        logInfo(e.take(2).toList().toString());
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
        headerDateNotifier.value = event.startDate;
        monthController.changeDate(event.startDate, event.endDate);
        timeTableController.jumpTo(event.startDate);
        dayController.jumpTo(event.startDate);
        scheduleController.jumpTo(event.startDate);
      } else if (event is GeneratePreview) {}
    });
  }

  void onDateChange(DateTime dateTime) {
    logInfo('date changed $dateTime');
    BlocProvider.of<TimeTableCubit>(context)
      ..setDate(dateTime)
      ..nativeCallBack.sendVisibleDateChnged(dateTime);
  }

  List<Widget> getViewList() => <Widget>[
        DayPlanner(
          customPeriods: periods,
          isMobile: isMobile,
          timetableController: dayController,
          onDateChanged: (DateTime dateTime) {
            headerDateNotifier.value = dateTime;
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
            headerDateNotifier.value = dateTime;
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
            headerDateNotifier.value = dateTime;
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
