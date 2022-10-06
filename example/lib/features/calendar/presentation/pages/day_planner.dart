import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/date_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/cell_border.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/single_day_event_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class DayPlanner extends StatefulWidget {
  /// initialized day planner
  const DayPlanner(
      {required this.timetableController,
      required this.customPeriods,
      required this.onImageCapture,
      this.onDateChanged,
      this.events = const <PlannerEvent>[],
      Key? key,
      this.id})
      : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///id that we will received from native ios
  final String? id;

  ///timetable controller for the calendar
  final TimetableController timetableController;

  ///function return unit8List when user ask for screenshot

  final Function(Uint8List) onImageCapture;

  ///list of the events for the planner
  final List<PlannerEvent> events;

  ///give new day when day is scrolled
  final Function(DateTime dateTime)? onDateChanged;
  @override
  State<DayPlanner> createState() => _DayPlannerState();
}

class _DayPlannerState extends State<DayPlanner> {
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
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentMonth = simpleController.visibleDateStart;
      setState(() {});
      Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
        simpleController.jumpTo(dateTime);
      });
    });
  }

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);

  @override
  Widget build(BuildContext context) => Scaffold(body:
          LayoutBuilder(builder: (BuildContext context, BoxConstraints value) {
        final bool isMobile = value.maxWidth < mobileThreshold;
        final Size size = value.biggest;

        return Column(
          children: <Widget>[
            Expanded(
              child: SlDayView<EventData>(
                onImageCapture: (Uint8List data) {
                  if (BlocProvider.of<TimeTableCubit>(context).viewType ==
                      CalendarViewType.dayView) {
                    widget.onImageCapture(data);
                  }
                },
                backgroundColor: white,
                timelines: widget.customPeriods,
                onDateChanged: (DateTime dateTime) {
                  if (widget.onDateChanged != null) {
                    widget.onDateChanged!(dateTime);
                  }
                },
                onEventDragged: (CalendarEvent<EventData> old,
                    CalendarEvent<EventData> newEvent) {
                  BlocProvider.of<TimeTableCubit>(context)
                      .updateEvent(old, newEvent, null);
                },
                onWillAccept: (CalendarEvent<EventData>? event, DateTime date,
                    Period period) {
                  final List<CalendarEvent<EventData>> events =
                      BlocProvider.of<TimeTableCubit>(context).events;
                  return isSlotAvlForSingleDay(events, event!, date, period);
                },
                nowIndicatorColor: timeIndicatorColor,
                fullWeek: true,
                cornerBuilder: (DateTime current) => const SizedBox.shrink(),
                items: widget.events,
                onTap: (DateTime date, Period period,
                    CalendarEvent<EventData>? event) {
                  final TimeTableCubit provider =
                      BlocProvider.of<TimeTableCubit>(context);
                  provider.nativeCallBack.sendAddEventToNativeApp(
                      dateTime, provider.viewType, period);
                },
                headerHeight: isMobile ? headerHeightForDayView : 40,
                headerCellBuilder: (DateTime date) => isMobile
                    ? Row(
                        children: <Widget>[
                          SizedBox(
                            width: simpleController.timelineWidth,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    DateFormat('E').format(date).toUpperCase(),
                                    style: context.hourLabelMobile.copyWith(
                                      color:
                                          isSameDate(date) ? primaryPink : null,
                                    ),
                                  ),
                                  Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.5),
                                          color: isSameDate(date)
                                              ? primaryPink
                                              : Colors.transparent),
                                      child: Center(
                                        child: Text(
                                          date.day.toString(),
                                          style: context.headline1WithNotoSans
                                              .copyWith(
                                                  color: isSameDate(date)
                                                      ? Colors.white
                                                      : null),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                height: simpleController.headerHeight,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.5),
                                        width: 0.5),
                                    color: lightGrey),
                                child: Center(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: simpleController.timelineWidth,
                                      ),
                                      Text(
                                        DateFormat('EEEE')
                                            .format(date)
                                            .toUpperCase(),
                                        style: context.subtitle1.copyWith(
                                            color: isSameDate(date)
                                                ? textBlack
                                                : null),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        DateFormat('d ').format(date),
                                        style: context.headline1.copyWith(
                                            color: isSameDate(date)
                                                ? textBlack
                                                : null),
                                      ),
                                    ],
                                  ),
                                )),
                          )
                        ],
                      ),
                headerDecoration: (DateTime dateTime) => const BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 3,
                          offset: Offset(0, 2),
                          color: Color(0x0000001A))
                    ]),
                hourLabelBuilder: (Period period) {
                  final TimeOfDay start = period.startTime;

                  final TimeOfDay end = period.endTime;
                  return Container(
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
                controller: simpleController,
                isCellDraggable: (CalendarEvent<EventData> event) {
                  if (event.eventData!.period.isCustomeSlot) {
                    return false;
                  } else {
                    return true;
                  }
                },
                itemBuilder: (CalendarEvent<EventData> item, int index,
                        int length, double width) =>
                    SingleDayEventTile(
                        border: item.eventData!.period.isCustomeSlot
                            ? null
                            : Border.all(color: white, width: 2),
                        cellWidth: size.width - simpleController.timelineWidth,
                        item: item,
                        isDraggable: false,
                        period: item.eventData!.period,
                        breakHeight: simpleController.breakHeight,
                        cellHeight: simpleController.cellHeight),
                cellBuilder: (Period period) => CellBorder(
                    borderWidth: 1,
                    borderRadius: 0,
                    color: period.isCustomeSlot
                        ? isMobile
                            ? lightGrey
                            : grey
                        : Colors.transparent,
                    borderColor: grey,
                    border: !period.isCustomeSlot
                        ? null
                        : Border(
                            left: isMobile
                                ? const BorderSide(
                                    color: grey,
                                  )
                                : const BorderSide(
                                    color: textGrey,
                                    width: 5,
                                  ),
                            top: const BorderSide(
                              color: grey,
                            ),
                            right: const BorderSide(
                              color: grey,
                            ),
                            bottom: const BorderSide(
                              color: grey,
                            )),
                    cellHeight: period.isCustomeSlot
                        ? simpleController.breakHeight
                        : simpleController.cellHeight),
              ),
            ),
          ],
        );
      }));
}
