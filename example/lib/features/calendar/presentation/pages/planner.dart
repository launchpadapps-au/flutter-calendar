import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/day_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/gl_schedule_view.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/month_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/new_day_view.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/preview.dart'; 
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/schedule_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/setting_dialog.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/term_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/week_planner.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/left_strip.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/right_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; 
import 'package:screenshot/screenshot.dart';
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

///screenshot controller
ScreenshotController screenshotController = ScreenshotController();

class _PlannerState extends State<Planner> {
  static DateTime startDate = DateTime(2022, 9);
  static DateTime endDate = DateTime(2022, 12, 31);
  TimetableController timeTableController = TimetableController(
      start: startDate,
      end: endDate,
      timelineWidth: 60,
      breakHeight: 35,
      cellHeight: 110);

  /// Used to display the current month in the app bar.
  DateTime dateTime = DateTime.now();

  static bool isMobile = true;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ScreenshotController screenshotController = ScreenshotController();

  static DateTime dateForHeader = DateTime.now();
  ValueNotifier<DateTime> headerDateNotifier =
      ValueNotifier<DateTime>(dateForHeader);
  int index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        title: ValueListenableBuilder<DateTime>(
            valueListenable: headerDateNotifier,
            builder: (BuildContext context, DateTime value, Widget? child) =>
                GestureDetector(
                  onTap: () {
                    // DatePicker.showPicker(context,
                    //         pickerModel: CustomMonthPicker(
                    //             minTime: DateTime(
                    //               2020,
                    //             ),
                    //             maxTime: DateTime.now(),
                    //             currentTime: dateTime))
                    //     .then((DateTime? value) {
                    //   if (value != null) {
                    //     log(dateTime.toString());
                    //     dateTime = value;

                    //     setState(() {});
                    //     simpleController.changeDate(
                    //         DateTime(dateTime.year, dateTime.month),
                    //         dateTime.lastDayOfMonth);
                    //   }
                    // });
                  },
                  child: Text(
                    DateFormat('dd-MMMM-y').format(dateTime),
                    style: context.termPlannerTitle,
                  ),
                )),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            // BlocProvider.of<TimeTableCubit>(context).jumpToCurrentDate();
            timeTableController.jumpTo(DateTime.now());
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.download,
              color: Colors.black,
            ),
            onPressed: () async {
              final TimeTableCubit cubit =
                  BlocProvider.of<TimeTableCubit>(context);

              await Preview.exportWeekView(DateTime(2022, 9),
                 DateTime(2022, 10, 3), cubit.periods, cubit.events, context,
                  saveImage: false);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () async {
              setState(() {
                if (index < 5) {
                  index++;
                } else {
                  index = 0;
                }
              });
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
      ),
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
      body: Screenshot<Widget>(
        controller: screenshotController,
        child: SafeArea(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints value) {
            isMobile = value.maxWidth < mobileThreshold;
            return Row(
              children: <Widget>[
                isMobile ? const SizedBox.shrink() : const LeftStrip(),
                Expanded(
                    child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child: BlocConsumer<TimeTableCubit, TimeTableState>(
                      listener: (BuildContext context, TimeTableState state) {
                    if (state is DateUpdated) {
                      timeTableController.changeDate(
                          state.startDate, state.endDate);
                    } else if (state is ViewUpdated) {
                    } else if (state is ChangeToCurrentDate) {
                      if (state.isDateChanged) {
                        final TimeTableCubit cubit =
                            BlocProvider.of<TimeTableCubit>(context);
                        timeTableController.changeDate(
                            cubit.startDate, cubit.endDate);
                      } else if (state.isViewChanged) {
                        timeTableController.changeView(state.viewType);
                      }
                      timeTableController.jumpTo(DateTime.now());
                    }
                  }, buildWhen:
                          (TimeTableState previous, TimeTableState current) {
                    if (current is LoadedState) {
                      log('Reloading timetable');
                      return true;
                    } else {
                      return false;
                    }
                  }, builder: (BuildContext context, TimeTableState state) {
                    if (state is ErrorState) {
                      return const Center(
                        child: Icon(Icons.close),
                      );
                    } else {
                      final List<PlannerEvent> events = state is LoadedState
                          ? state.events
                          : <PlannerEvent>[];
                      return Column(
                        children: <Widget>[
                          state is LoadingState ||
                                  state is LoadingUpdated && state.isLoading
                              ? const LinearProgressIndicator()
                              : const SizedBox.shrink(),
                          Expanded(
                            child: IndexedStack(
                              index: state is LoadedState
                                  ? getIndex(state.viewType)
                                  : 2,
                              children: <Widget>[
                                SchedulePlanner(
                                  isMobile: isMobile,
                                  onImageCapture: (Uint8List p0) {
                                    log('Schedule View image received '
                                        'from planner');
                                    BlocProvider.of<TimeTableCubit>(context)
                                        .saveTomImage(p0);
                                  },
                                  events: events,
                                  customPeriods: state is LoadedState
                                      ? state.periods
                                      : customStaticPeriods,
                                  timetableController: timeTableController,
                                ),
                                DayPlanner(
                                    onImageCapture: (Uint8List p0) {
                                      log('Day view image received '
                                          'from planner');
                                      BlocProvider.of<TimeTableCubit>(context)
                                          .saveTomImage(p0);
                                    },
                                    customPeriods: state is LoadedState
                                        ? state.periods
                                        : customStaticPeriods,
                                    events: events,
                                    timetableController: timeTableController,
                                    onDateChanged: (DateTime dateTime) {
                                      log('Date for dayview:$dateTime');
                                      this.dateTime = dateTime;
                                      headerDateNotifier.value = dateTime;
                                    }),
                                WeekPlanner(
                                  onImageCapture: (Uint8List p0) {
                                    log(' Week view image received '
                                        'from planner');
                                    BlocProvider.of<TimeTableCubit>(context)
                                        .saveTomImage(p0);
                                  },
                                  events: events,
                                  customPeriods: state is LoadedState
                                      ? state.periods
                                      : customStaticPeriods,
                                  timetableController: timeTableController,
                                ),
                                MonthPlanner(
                                  timetableController: timeTableController,
                                  events: events,
                                  onMonthChanged: (Month month) {
                                    log('month changed$month');
                                    setState(() {
                                      dateTime =
                                          DateTime(month.year, month.month, 15);
                                    });
                                  },
                                ),
                                TermPlanner(
                                  timetableController: timeTableController,
                                  events: events,
                                  onMonthChanged: (Month month) {
                                    log('month changed$month');
                                    setState(() {
                                      dateTime =
                                          DateTime(month.year, month.month, 15);
                                    });
                                  },
                                ),

                                // MainWidget(),
                                NewDayPlanner(
                                  customPeriods: state is LoadedState
                                      ? state.periods
                                      : customStaticPeriods,
                                  timetableController: timeTableController,
                                ),

                                GlSchedulePlanner(
                                  isMobile: isMobile,
                                  customPeriods: state is LoadedState
                                      ? state.periods
                                      : customStaticPeriods,
                                  timetableController: timeTableController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }),
                )),
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
      ));
}

///get index of the index stack
int getIndex(CalendarViewType viewType) {
  switch (viewType) {
    case CalendarViewType.scheduleView:
      return 0;
    case CalendarViewType.dayView:
      return 1;
    case CalendarViewType.weekView:
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
