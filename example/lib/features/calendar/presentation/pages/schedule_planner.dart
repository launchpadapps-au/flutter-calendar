import 'package:edgar_planner_calendar_flutter/core/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/schedule_view_event_tile.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///planner
class SchedulePlanner<T> extends StatefulWidget {
  /// initialize schedule planner
  const SchedulePlanner({
    required this.timetableController,
    required this.customPeriods,
    required this.onTap,
    required this.onDateChanged,
    this.onEventDragged,
    this.onEventToEventDragged,
    Key? key,
    this.id,
    this.isMobile = true,
  }) : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///provide calalback user tap on the cell
  final Function(
      DateTime dateTime, Period?, List<CalendarEvent<EventData>>? events) onTap;

  ///return new and okd event
  final Function(CalendarEvent<T> old, CalendarEvent<T> newEvent)?
      onEventDragged;

  ///return existing ,old and new event when used drag and drop
  ///the event on the existing event
  final Function(
      CalendarEvent<EventData> existing,
      CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent,
      Period? periodModel)? onEventToEventDragged;

  ///give new day when day is scrolled
  final Function(DateTime dateTime) onDateChanged;

  ///id that we will received from native ios
  final String? id;

  ///bool isMobile
  final bool isMobile;

  ///timetable controller for the calendar
  final TimetableController<EventData> timetableController;

  @override
  State<SchedulePlanner<EventData>> createState() => _SchedulePlannerState();
}

class _SchedulePlannerState extends State<SchedulePlanner<EventData>> {
  static DateTime dateTime = DateTime.now();

  @override
  void initState() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentMonth = widget.timetableController.visibleDateStart;
      setState(() {});
      Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
        widget.timetableController.jumpTo(dateTime);
      });
    });
    super.initState();
  }

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);

  static double cellHeight = 51;

  @override
  Widget build(BuildContext context) => SlScheduleView<EventData>(
        backgroundColor: white,
        timelines: widget.customPeriods,
        cellHeight: cellHeight,
        onDateChanged: widget.onDateChanged,
        onEventDragged: widget.onEventDragged,
        onWillAccept: (CalendarEvent<EventData>? event) => true,
        nowIndicatorColor: timeIndicatorColor,
        fullWeek: true,
        cornerBuilder: (DateTime current) => const SizedBox.shrink(),
        onTap: (DateTime dateTime, List<CalendarEvent<EventData>>? p1) {
          if (p1 == null) {
            widget.onTap(dateTime, null, null);
          } else {
            widget.onTap(dateTime, null, p1);
          }
        },
        onEventToEventDragged: (CalendarEvent<EventData> existing,
            CalendarEvent<EventData> old,
            CalendarEvent<EventData> newEvent,
            Period? periodModel) {
          if (widget.onEventToEventDragged != null) {
            widget.onEventToEventDragged!(existing, old, newEvent, periodModel);
          }
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
                DateFormat('E').format(date).toUpperCase(),
                style: context.subtitle
                    .copyWith(color: isSameDate(date) ? primaryPink : null),
              ),
              Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.5),
                      color:
                          isSameDate(date) ? primaryPink : Colors.transparent),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: context.subtitle.copyWith(
                          color: isSameDate(date) ? Colors.white : textBlack),
                    ),
                  ))
            ],
          ),
        ),
        hourLabelBuilder: (Period period) {
          final TimeOfDay start = period.startTime;

          final TimeOfDay end = period.endTime;
          return Container(
            child: period.isCustomeSlot
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(period.title ?? '', style: context.subtitle),
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
        emptyMonthBuilder: (DateTime dateTime) {
          final DateTime end = DateTime(dateTime.year, dateTime.month + 1)
              .subtract(const Duration(days: 1));
          return ListTile(
            contentPadding: const EdgeInsets.only(left: 27),
            title: Text(
              DateFormat('MMMM').format(
                dateTime,
              ),
              style: context.headline1.copyWith(color: textBlack),
            ),
            subtitle: Row(
              children: <Widget>[
                Text(DateFormat('d MMMM').format(dateTime),
                    style: context.headline1Fw500.copyWith(color: textGrey)),
                const SizedBox(
                  width: 8,
                ),
                Text(DateFormat(' - d MMMM').format(end),
                    style: context.headline1Fw500.copyWith(color: textGrey)),
              ],
            ),
          );
        },
        emptyTodayTitle: (DateTime date) => Text('Nothing Planned for today',
            style: context.headline1Fw500.copyWith(
                color: textGrey, fontSize: 14, fontWeight: FontWeight.w700)),
        isCellDraggable: (CalendarEvent<EventData> event) =>
            isCelldraggable(event),
        controller: widget.timetableController,
        itemBuilder: (CalendarEvent<EventData> item) => ScheduleViewEventTile(
          item: item,
          cellHeight: cellHeight,
        ),
        cellBuilder: (DateTime period) => Container(
          height: cellHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
              color: lightGrey),
        ),
      );
}
