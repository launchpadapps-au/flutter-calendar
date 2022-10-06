import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/date_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart'; 
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/event_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class WeekPlanner extends StatefulWidget {
  /// initialize week planner
  const WeekPlanner({
    required this.timetableController,
    required this.customPeriods,
    required this.onImageCapture,
    this.events = const <PlannerEvent>[],
    Key? key,
    this.id,
  }) : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///id that we will received from native ios
  final String? id;

  ///list of the events for the planner
  final List<PlannerEvent> events;

  ///timetable controller
  final TimetableController timetableController;

  ///function return unit8List when user ask for screenshot

  final Function(Uint8List) onImageCapture;
  @override
  State<WeekPlanner> createState() => _WeekPlannerState();
}

///current date time
DateTime now = DateTime.now().subtract(const Duration(days: 30));

class _WeekPlannerState extends State<WeekPlanner> {
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
  final bool showSameHeader = true;

  @override
  Widget build(BuildContext context) => Scaffold(body:
          LayoutBuilder(builder: (BuildContext context, BoxConstraints value) {
        final bool isMobile = value.maxWidth < mobileThreshold;

        return Container(
          color: white,
          child: SlWeekView<EventData>(
            backgroundColor: white,
            onImageCapture: (Uint8List data) {
              if (BlocProvider.of<TimeTableCubit>(context).viewType ==
                  CalendarViewType.weekView) {
                widget.onImageCapture(data);
              }
            },
            fullWeek: true,
            timelines: widget.customPeriods,
            onEventDragged: (CalendarEvent<EventData> old,
                CalendarEvent<EventData> newEvent, Period? period) {
              BlocProvider.of<TimeTableCubit>(context)
                  .updateEvent(old, newEvent, period);
            },
            onWillAccept: (CalendarEvent<EventData>? event, Period period) =>
                true,
            nowIndicatorColor: Colors.red,
            cornerBuilder: (DateTime current) => Container(
              color: white,
            ),
            items: widget.events,
            onTap: (DateTime date, Period period,
                CalendarEvent<EventData>? event) {
              final TimeTableCubit provider =
                  BlocProvider.of<TimeTableCubit>(context);
              provider.nativeCallBack
                  .sendAddEventToNativeApp(dateTime, provider.viewType, period);
            },
            headerHeight: showSameHeader || isMobile ? headerHeight : 40,
            headerCellBuilder: (DateTime date) => isMobile
                ? Container(
                    color: white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          DateFormat('E').format(date).toUpperCase(),
                          style: context.hourLabelMobile,
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
                                style: context.headline2Fw500.copyWith(
                                    fontSize: isMobile ? 16 : 24,
                                    color:
                                        isSameDate(date) ? Colors.white : null),
                              ),
                            )),
                        const SizedBox(
                          height: 2,
                        ),
                      ],
                    ),
                  )
                :

                /// Creating a container widget.
                Container(
                    color: white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          DateFormat('E').format(date).toUpperCase(),
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
                                style: context.headline1WithNotoSans.copyWith(
                                    color:
                                        isSameDate(date) ? Colors.white : null),
                              ),
                            )),
                        const SizedBox(
                          height: 2,
                        ),
                      ],
                    ),
                  ),
            hourLabelBuilder: (Period period) {
              final TimeOfDay start = period.startTime;

              final TimeOfDay end = period.endTime;
              return Container(
                color: white,
                child: period.isCustomeSlot
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(period.title ?? '',
                              style: isMobile
                                  ? context.hourLabelMobile
                                  : context.hourLabelTablet),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(start.format(context).substring(0, 5),
                              style: isMobile
                                  ? context.hourLabelMobile
                                  : context.hourLabelTablet),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(end.format(context).substring(0, 5),
                              style: isMobile
                                  ? context.hourLabelMobile
                                  : context.hourLabelTablet),
                        ],
                      ),
              );
            },
            isCellDraggable: (CalendarEvent<EventData> event) {
              if (event.eventData!.period.isCustomeSlot) {
                return false;
              } else {
                return true;
              }
            },
            controller: simpleController,
            itemBuilder: (CalendarEvent<EventData> item, double width) =>
                Container(
              margin: const EdgeInsets.all(4),
              child: Container(
                  padding: const EdgeInsets.all(6),
                  height: item.eventData!.period.isCustomeSlot
                      ? simpleController.breakHeight
                      : simpleController.cellHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: item.eventData!.color),
                  child: item.eventData!.period.isCustomeSlot
                      ? SizedBox(
                          height: simpleController.breakHeight,
                          child: Center(
                              child: Text(
                            item.eventData!.title,
                            style: context.subtitle,
                          )),
                        )
                      : EventTile(
                          item: item,
                          height: item.eventData!.period.isCustomeSlot
                              ? simpleController.breakHeight
                              : simpleController.cellHeight,
                          width: width,
                        )),
            ),
            cellBuilder: (Period period) => Container(
              height: period.isCustomeSlot
                  ? simpleController.breakHeight
                  : simpleController.cellHeight,
              decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  color: period.isCustomeSlot ? lightGrey : Colors.transparent),
            ),
          ),
        );
      }));
}
