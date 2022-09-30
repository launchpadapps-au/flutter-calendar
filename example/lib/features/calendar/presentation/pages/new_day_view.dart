import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/date_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/cell_border.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/single_day_event_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class NewDayPlanner extends StatefulWidget {
  /// initialized day planner
  const NewDayPlanner(
      {required this.timetableController,
      required this.customPeriods,
      Key? key,
      this.id})
      : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///id that we will received from native ios
  final String? id;

  ///timetable controller for the calendar
  final TimetableController timetableController;

  @override
  State<NewDayPlanner> createState() => _NewDayPlannerState();
}

class _NewDayPlannerState extends State<NewDayPlanner> {
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
        return BlocConsumer<TimeTableCubit, TimeTableState>(
            listener: (BuildContext context, TimeTableState state) {
          if (state is LoadedState) {
            simpleController.reloadTable();
          }
        }, builder: (BuildContext context, TimeTableState state) {
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
                  child: NewSlDayView<EventData>(
                    timelines: widget.customPeriods,
                    onEventDragged: (CalendarEvent<EventData> old,
                        CalendarEvent<EventData> newEvent) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .updateEvent(old, newEvent, null);
                    },
                    onWillAccept: (CalendarEvent<EventData>? event,
                        DateTime date, Period period) {
                      final List<CalendarEvent<EventData>> events =
                          BlocProvider.of<TimeTableCubit>(context).events;
                      return isSlotAvlForSingleDay(
                          events, event!, date, period);
                    },
                    nowIndicatorColor: timeIndicatorColor,
                    fullWeek: true,
                    cornerBuilder: (DateTime current) =>
                        const SizedBox.shrink(),
                    items: state is LoadedState
                        ? state.events
                        : <CalendarEvent<EventData>>[],
                    onTap: (DateTime date, Period period,
                        CalendarEvent<EventData>? event) {
                      final TimeTableCubit provider =
                          BlocProvider.of<TimeTableCubit>(context);
                      provider.nativeCallBack.sendAddEventToNativeApp(
                          dateTime, provider.viewType, period);
                    },
                    headerHeight: isMobile ? headerHeight : 40,
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
                                        DateFormat('E')
                                            .format(date)
                                            .toUpperCase(),
                                        style: context.hourLabelMobile.copyWith(
                                          color: isSameDate(date)
                                              ? primaryPink
                                              : null,
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
                                              style: context
                                                  .headline1WithNotoSans
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
                                            width:
                                                simpleController.timelineWidth,
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
                    hourLabelBuilder: (Period period) {
                      final TimeOfDay start = period.startTime;

                      final TimeOfDay end = period.endTime;
                      return Container(
                        child: period.isBreak
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
                      if (event.eventData!.period.isBreak) {
                        return false;
                      } else {
                        return true;
                      }
                    },
                    initialHeight: (CalendarEvent<EventData> event) =>
                        event.eventData!.period.isBreak
                            ? simpleController.breakHeight
                            : simpleController.cellHeight,
                    itemBuilder: (CalendarEvent<EventData> item) =>
                        SingleDayEventTile(
                            cellWidth:
                                size.width - simpleController.timelineWidth,
                            item: item,
                            isDraggable: false,
                            period: item.eventData!.period,
                            breakHeight: simpleController.breakHeight,
                            cellHeight: simpleController.cellHeight),
                    cellBuilder: (Period period) => CellBorder(
                        borderWidth: 1,
                        borderRadius: 0,
                        color: period.isBreak
                            ? isMobile
                                ? lightGrey
                                : grey
                            : Colors.transparent,
                        borderColor: grey,
                        border: !period.isBreak
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
                        cellHeight: period.isBreak
                            ? simpleController.breakHeight
                            : simpleController.cellHeight),
                  ),
                ),
              ],
            );
          }
        });
      }));
}
