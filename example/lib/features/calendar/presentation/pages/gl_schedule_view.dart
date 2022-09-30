import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/date_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/schedule_view_event_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class GlSchedulePlanner extends StatefulWidget {
  /// initialize schedule planner
  const GlSchedulePlanner({
    required this.timetableController,
    required this.customPeriods,
    Key? key,
    this.id,
    this.isMobile = true,
  }) : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///id that we will received from native ios
  final String? id;

  ///bool isMobile
  final bool isMobile;

  ///timetable controller for the calendar
  final TimetableController timetableController;

  @override
  State<GlSchedulePlanner> createState() => _GlSchedulePlannerState();
}

class _GlSchedulePlannerState extends State<GlSchedulePlanner> {
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
    simpleController = widget.timetableController;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentMonth = simpleController.visibleDateStart;
      setState(() {});
      Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
        simpleController.jumpTo(dateTime);
      });
    });
    super.initState();
  }

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);

  static double cellHeight = 51;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TimeTableCubit, TimeTableState>(
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
                child: GlScheduleView<EventData>(
                  timelines: widget.customPeriods,
                  cellHeight: cellHeight,
                  onEventDragged: (CalendarEvent<EventData> old,
                      CalendarEvent<EventData> newEvent) {
                    BlocProvider.of<TimeTableCubit>(context)
                        .updateEvent(old, newEvent, null);
                  },
                  onWillAccept: (CalendarEvent<EventData>? event) => true,
                  nowIndicatorColor: Colors.red,
                  fullWeek: true,
                  cornerBuilder: (DateTime current) => const SizedBox.shrink(),
                  items: state is LoadedState
                      ? state.events
                      : <CalendarEvent<EventData>>[],
                  onTap:
                      (DateTime dateTime, List<CalendarEvent<EventData>>? p1) {
                    final TimeTableCubit provider =
                        BlocProvider.of<TimeTableCubit>(context);
                    provider.nativeCallBack.sendAddEventToNativeApp(
                        dateTime, provider.viewType, null);
                  },
                  headerHeight: widget.isMobile ? 38 : 40,
                  headerCellBuilder: (DateTime date) =>
                      //  widget.isMobile
                      //     ?
                      SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          DateFormat('E').format(date),
                          style: context.subtitle,
                        ),
                        Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.5),
                                color: isSameDate(date)
                                    ? primaryPink
                                    : Colors.transparent),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: context.subtitle.copyWith(
                                    color: isSameDate(date)
                                        ? Colors.white
                                        : textBlack),
                              ),
                            ))
                      ],
                    ),
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
                  isCellDraggable: (CalendarEvent<EventData> event) {
                    if (event.eventData!.period.isBreak) {
                      return false;
                    } else {
                      return true;
                    }
                  },
                  controller: simpleController,
                  itemBuilder: (CalendarEvent<EventData> item) =>
                      ScheduleViewEventTile(
                    item: item,
                    cellHeight: cellHeight,
                  ),
                  cellBuilder: (DateTime period) => Container(
                    height: 0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 0.5),
                        color: lightGrey),
                  ),
                ),
              ),
            ],
          );
        }
      });
}
