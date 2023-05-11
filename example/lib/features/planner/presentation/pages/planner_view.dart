import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/pages/day_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/pages/month_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/pages/schedule_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/pages/setting.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/pages/term_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/pages/week_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/appbar.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/left_strip.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/linear_indicator.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/right_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///calendar view for the module
class PlannerView extends StatefulWidget {
  ///
  const PlannerView({super.key});

  @override
  State<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  final TimetableController<EventData> weekController =
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

  ValueNotifier<bool> rebuild = ValueNotifier(true);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<DateTime> headerDateNotifier =
      ValueNotifier<DateTime>(DateTime.now());

  ValueNotifier<CalendarViewType> viewTypeNotifer =
      ValueNotifier<CalendarViewType>(CalendarViewType.weekView);

  bool showAppbar = false;
  bool isMobile = true;

  ///make this variable true if you want to show pink popup for the
  ///month and term viee. if true then it will show popup and it dispach onTap
  ///event after tapping on that

  bool showAddNotePupup = true;

  bool enableTapForExtraSlot = false;
  bool sendJsonEcnoded = false;
  List<Period> periods = customStaticPeriods;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
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
        weekController.chageCellHeight(
            CalendarParams.mobileCellHeight, CalendarParams.mobileBreakHeight);
        scheduleController.chageCellHeight(
            CalendarParams.mobileCellHeight, CalendarParams.mobileBreakHeight);
      } else {
        dayController.chageCellHeight(
            CalendarParams.tabCellHeight, CalendarParams.tabBreakHeight);
        weekController.chageCellHeight(
            CalendarParams.tabCellHeight, CalendarParams.tabBreakHeight);
        scheduleController.chageCellHeight(
            CalendarParams.tabCellHeight, CalendarParams.tabBreakHeight);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        key: scaffoldKey,
        backgroundColor: white,
        appBar: showAppbar
            ? CalendarAppBar(
                headerDateNotifier: headerDateNotifier,
                scaffoldKey: scaffoldKey)
            : null,
        endDrawer: SettingDrawer(
          startDate: DefaultDates.startDate,
          isMobile: isMobile,
          endDate: DefaultDates.startDate,
          onDateChange: (DateTime start, DateTime end) {
            weekController.changeDate(start, end);
            dayController.changeDate(start, end);
            scheduleController.changeDate(start, end);
          },
        ),
        floatingActionButton: BlocBuilder<PlannerCubit, PlannerState>(
          builder: (BuildContext context, PlannerState state) =>
              BlocProvider.of<PlannerCubit>(context).standAlone
                  ? FloatingActionButton(
                      onPressed: () {
                        showDatePicker(
                                context: context,
                                firstDate: DefaultDates.startDate,
                                lastDate: DefaultDates.endDate,
                                initialDate: DateTime.now())
                            .then((DateTime? value) {
                          if (value != null) {
                            weekController.jumpTo(value);
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
        body: SafeArea(
          child: LayoutBuilder(
              key: _key,
              builder: (BuildContext context, BoxConstraints constrains) {
                onResize();
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
                          child: ValueListenableBuilder<bool>(
                              valueListenable: rebuild,
                              builder: (BuildContext context, bool value,
                                  Widget? child) {
                                return ValueListenableBuilder<CalendarViewType>(
                                    valueListenable: viewTypeNotifer,
                                    builder: (BuildContext context,
                                            CalendarViewType viewType,
                                            Widget? child) =>
                                        IndexedStack(
                                          index:
                                              CalendarUtils.getIndex(viewType),
                                          children: getViewList(),
                                        ));
                              }),
                        ),
                      ],
                    )),
                    isMobile ? const SizedBox.shrink() : const RightStrip(),
                  ],
                );
              }),
        ),
      );

  void listenCubit(BuildContext context) {
    final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
    cubit.stream.listen((PlannerState event) {
      if (event is DateUpdated) {
        logInfo('Date is updating in calendar: date updaed');

        headerDateNotifier.value = event.startDate;
      } else if (event is CurrrentDateUpdated) {
        headerDateNotifier.value = event.currentDate;
      } else if (event is ViewUpdated) {
        logPrety('view updated in calendar:${event.viewType}');

        final CalendarViewType requstedView = event.viewType;

        viewTypeNotifer.value = requstedView;
        if (event.jump) {
          weekController.jumpTo(cubit.date);
          dayController.jumpTo(cubit.date);
          scheduleController.jumpTo(cubit.date);
          monthController.jumpTo(cubit.date);
          termController.jumpTo(cubit.date);
        }
      } else if (event is JumpToDateState) {
        logInfo('jumping to date in calendar ${event.dateTime}');

        if (cubit.viewType == CalendarViewType.weekView) {
          if (DateUtils.isSameDay(event.dateTime, DateTime.now())) {
            final DateTime date =
                getMonday(DateTime.now()).add(Duration(days: isMobile ? 1 : 2));
            weekController.jumpTo(date);
          } else {
            final DateTime date =
                getMonday(event.dateTime).add(Duration(days: isMobile ? 1 : 2));
            weekController.jumpTo(date);
          }
        }

        dayController.jumpTo(event.dateTime);
        scheduleController.jumpTo(event.dateTime);
        headerDateNotifier.value = event.dateTime;

        monthController.jumpTo(event.dateTime);
        termController.jumpTo(event.dateTime);
      } else if (event is LoadedState) {
        logInfo('Loading event in calendar');

        if (event.events.isNotEmpty) {
          weekController.addEvent(event.events, replace: true);
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
        weekController.updateEvent(event.oldEvent, event.newEvent);
        dayController.updateEvent(event.oldEvent, event.newEvent);
        scheduleController.updateEvent(event.oldEvent, event.newEvent);
      } else if (event is EventsAdded) {
        logInfo('Setting events in calendar: ${event.events.length}');
        weekController.addEvent(event.events, replace: true);
        dayController.addEvent(event.events, replace: true);
        final List<PlannerEvent> e = event.events;

        scheduleController.addEvent(
            e
                .where((PlannerEvent element) => element.eventData!.isLesson)
                .toList(),
            replace: true);
      } else if (event is NotesAdded) {
        logInfo('Setting notes in calendar');

        monthController.addEvent(event.notes, replace: true);
        termController.addEvent(event.notes, replace: true);
      } else if (event is PeriodsUpdated) {
        periods = event.periods;
        rebuild.value = !rebuild.value;
        setState(() {
          logInfo(periods);
        });
      } else if (event is DeletedEvents) {
        weekController.removeEvent(event.deletedEvents);
        dayController.removeEvent(event.deletedEvents);
        scheduleController.removeEvent(event.deletedEvents);

        logInfo('removing events from calendar');
      } else if (event is TermsUpdated) {
        final Term term = BlocProvider.of<PlannerCubit>(context).term!;
        if (term != null) {
          logInfo('Current Term:$term');
          termController.changeDate(term.startDate, term.endDate);
          monthController.changeDate(term.startDate, term.endDate);
        }
      } else if (event is MonthUpdated) {
        logInfo('Month Updated');
        headerDateNotifier.value = event.startDate;
        monthController.changeDate(event.startDate, event.endDate);
        // weekController.jumpTo(event.startDate);
        // dayController.jumpTo(event.startDate);
        // scheduleController.jumpTo(event.startDate);
      } else if (event is GeneratePreview) {}
    });
  }

  void onDateChange(DateTime dateTime, CalendarViewType type) {
    if (type == viewTypeNotifer.value) {
      BlocProvider.of<PlannerCubit>(context).onDateChange(dateTime);
    } else {
      BlocProvider.of<PlannerCubit>(context).onDateChange(dateTime);
    }
  }

  void sendAddEventToNativeApp(
      DateTime dateTime, CalendarViewType viewType, Period? period,
      {bool jsonEcoded = false}) {
    final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
    if (cubit.globalTermModel.terms.isInBufferTime(dateTime)) {
      logInfo('Given date is in Buffer Time: Skipping Callback');
    } else {
      cubit.nativeCallBack.addEvent(dateTime, cubit.viewType, period,
          jsonEcoded: sendJsonEcnoded);
    }
  }

  bool onWillAccept(
      CalendarEvent<EventData>? event, Period period, DateTime dateTime) {
    final PeriodModel periodModel = period as PeriodModel;
    if (periodModel.isCustomeSlot) {
      return false;
    } else {
      logPrety(dateTime);
      final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
      if (cubit.globalTermModel.terms.isInBufferTime(dateTime)) {
        logInfo('New date is in Buffer Time: Skipping Dragging');
        return false;
      } else {
        return true;
      }
    }
  }

  bool onWillAcceptForEvent(CalendarEvent<EventData> draggeed,
      CalendarEvent<EventData> existing, DateTime dateTime) {
    if (existing.eventData!.isDuty) {
      return false;
    } else {
      logPrety(dateTime);
      final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
      if (cubit.globalTermModel.terms.isInBufferTime(dateTime)) {
        logInfo('New date is in Buffer Time: Skipping Dragging');
        return false;
      } else {
        return true;
      }
    }
  }

  List<Widget> getViewList() => <Widget>[
        DayPlanner(
          customPeriods: periods,
          isMobile: isMobile,
          timetableController: dayController,
          onDateChanged: (DateTime dateTime) {
            headerDateNotifier.value = dateTime;
            onDateChange(dateTime, CalendarViewType.dayView);
          },
          onEventDragged: (CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent, Period? period) {
            BlocProvider.of<PlannerCubit>(context)
                .onEventDragged(old, newEvent, period);
          },
          onEventToEventDragged: (CalendarEvent<EventData> existing,
              CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent,
              Period? periodModel) {
            final CalendarEvent<EventData> eventToUpdate = newEvent
              ..eventData!.slots = existing.eventData!.slots;
            BlocProvider.of<PlannerCubit>(context)
                .onEventDragged(old, eventToUpdate, periodModel);
          },
          onTap: (DateTime dateTime, Period? period,
              CalendarEvent<EventData>? event) {
            final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
            if (event == null && period != null) {
              final PeriodModel periodModel = period as PeriodModel;
              if (enableTapForExtraSlot &&
                  (periodModel.isBeforeSchool || period.isAfterSchool)) {
                sendAddEventToNativeApp(dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              } else if (!period.isCustomeSlot) {
                sendAddEventToNativeApp(dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              }
            } else if (event != null) {
              PeriodModel? periodModel;

              try {
                periodModel = BlocProvider.of<PlannerCubit>(context)
                    .periods
                    .firstWhere((PeriodModel element) =>
                        element.id == event.eventData!.slots);
              } on Exception {
                periodModel = null;
              }

              if (periodModel != null && periodModel.isCustomeSlot) {
                cubit.nativeCallBack.showDuty(
                    dateTime,
                    <CalendarEvent<EventData>>[event],
                    cubit.viewType,
                    periodModel);
              } else {
                if (event.eventData!.isFreeTime) {
                  cubit.nativeCallBack
                      .showdNonTeaching(event, dateTime, cubit.viewType);
                } else {
                  cubit.nativeCallBack.showEvent(dateTime,
                      <CalendarEvent<EventData>>[event], cubit.viewType);
                }
              }
            }
          },
          onWillAccept: (CalendarEvent<EventData>? event, Period period,
                  DateTime dateTime) =>
              onWillAccept(event, period, dateTime),
          onWillAcceptForEvent: (CalendarEvent<EventData> draggeed,
                  CalendarEvent<EventData> existing, DateTime dateTime) =>
              onWillAcceptForEvent(draggeed, existing, dateTime),
        ),
        WeekPlanner<EventData>(
          customPeriods: periods,
          isMobile: isMobile,
          timetableController: weekController,
          onDateChanged: (DateTime dateTime) {
            headerDateNotifier.value = dateTime;
            onDateChange(dateTime, CalendarViewType.monthView);
          },
          onTap: (DateTime dateTime, Period? period,
              CalendarEvent<EventData>? event) {
            final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
            if (event == null && period != null) {
              final PeriodModel periodModel = period as PeriodModel;
              if (enableTapForExtraSlot &&
                  (periodModel.isBeforeSchool || period.isAfterSchool)) {
                sendAddEventToNativeApp(dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              } else if (!period.isCustomeSlot) {
                sendAddEventToNativeApp(dateTime, cubit.viewType, period,
                    jsonEcoded: sendJsonEcnoded);
              }
            } else if (event != null) {
              PeriodModel? periodModel;

              try {
                periodModel = BlocProvider.of<PlannerCubit>(context)
                    .periods
                    .firstWhere((PeriodModel element) =>
                        element.id == event.eventData!.slots);
              } on Exception {
                periodModel = null;
              }

              if (periodModel != null && (periodModel.isCustomeSlot)) {
                cubit.nativeCallBack.showDuty(
                    dateTime,
                    <CalendarEvent<EventData>>[event],
                    cubit.viewType,
                    periodModel);
              } else {
                if (event.eventData!.isFreeTime) {
                  cubit.nativeCallBack
                      .showdNonTeaching(event, dateTime, cubit.viewType);
                } else {
                  cubit.nativeCallBack.showEvent(dateTime,
                      <CalendarEvent<EventData>>[event], cubit.viewType);
                }
              }
            }
          },
          onWillAccept: (CalendarEvent<EventData>? event, Period period,
                  DateTime dateTime) =>
              onWillAccept(event, period, dateTime),
          onWillAcceptForEvent: (CalendarEvent<EventData> draggeed,
                  CalendarEvent<EventData> existing, DateTime dateTime) =>
              onWillAcceptForEvent(draggeed, existing, dateTime),
          onEventDragged: (CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent, Period? period) {
            log
              ..info(old.toMap.toString())
              ..info(newEvent.toMap.toString());

            BlocProvider.of<PlannerCubit>(context)
                .onEventDragged(old, newEvent, period);
          },
          onEventToEventDragged: (CalendarEvent<EventData> existing,
              CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent,
              Period? periodModel) {
            final CalendarEvent<EventData> eventToUpdate = newEvent
              ..eventData!.slots = existing.eventData!.slots;
            BlocProvider.of<PlannerCubit>(context)
                .onEventDragged(old, eventToUpdate, periodModel);
          },
        ),
        SchedulePlanner<EventData>(
          customPeriods: periods,
          timetableController: scheduleController,
          isMobile: isMobile,
          onDateChanged: (DateTime dateTime) {
            headerDateNotifier.value = dateTime;
            onDateChange(dateTime, CalendarViewType.scheduleView);
          },
          onWillAccept: (CalendarEvent<EventData>? event, DateTime dateTime) {
            final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
            if (cubit.globalTermModel.terms.isInBufferTime(dateTime)) {
              logInfo('New date is in Buffer Time: Skipping Dragging');
              return false;
            } else {
              return true;
            }
          },
          onEventDragged: (CalendarEvent<EventData> old,
              CalendarEvent<EventData> newEvent) {
            BlocProvider.of<PlannerCubit>(context)
                .onEventDragged(old, newEvent, null);
          },
          onTap: (DateTime dateTime, Period? period,
              List<CalendarEvent<EventData>>? events) {
            final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
            if (events == null && period == null) {
              sendAddEventToNativeApp(dateTime, cubit.viewType, period,
                  jsonEcoded: sendJsonEcnoded);
            } else if (events != null) {
              cubit.nativeCallBack.showEvent(dateTime, events, cubit.viewType);

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
            BlocProvider.of<PlannerCubit>(context)
                .onEventDragged(old, eventToUpdate, periodModel);
          },
        ),
        MonthPlanner(
          timetableController: monthController,
          showAddNotePupup: showAddNotePupup,
          onMonthChanged: (Month month) {
            setState(() {
              dateTime = DateTime(month.year, month.month, 15);
            });
          },
          onTap: (DateTime dateTime, List<CalendarEvent<Note>> event) {
            final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
            if (event.isEmpty) {
              cubit.nativeCallBack.addNote(dateTime, cubit.viewType);
            } else if (event.length == 1) {
              cubit.nativeCallBack
                  .showNote(event.first.eventData!, cubit.viewType);
            } else {
              logInfo('No method for multiple note tap');
            }
          },
        ),
        TermPlanner(
          timetableController: termController,
          showAddNotePupup: showAddNotePupup,
          onMonthChanged: (Month month) {
            setState(() {
              dateTime = DateTime(month.year, month.month, 15);
            });
          },
          onTap: (DateTime dateTime, List<CalendarEvent<Note>> event) {
            final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
            if (event.isEmpty) {
              cubit.nativeCallBack.addNote(dateTime, cubit.viewType);
            } else if (event.length == 1) {
              cubit.nativeCallBack
                  .showNote(event.first.eventData!, cubit.viewType);
            } else {
              logInfo('No method for multiple note tap');
            }
          },
        ),
      ].skip(0).toList();
}
