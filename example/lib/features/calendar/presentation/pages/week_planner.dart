import 'package:edgar_planner_calendar_flutter/core/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';

///planner
class WeekPlanner<T> extends StatefulWidget {
  /// initialize week planner
  const WeekPlanner({
    required this.timetableController,
    required this.customPeriods,
    required this.onEventDragged,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///timetable controller
  final TimetableController<EventData> timetableController;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, Period?, CalendarEvent<T>?)? onTap;

  ///return new and okd event

  final Function(
          CalendarEvent<T> old, CalendarEvent<T> newEvent, Period? period)
      onEventDragged;

  @override
  State<WeekPlanner<EventData>> createState() => _WeekPlannerState();
}

///current date time
DateTime now = DateTime.now().subtract(const Duration(days: 30));

class _WeekPlannerState extends State<WeekPlanner<EventData>> {
  static DateTime dateTime = DateTime.now();

  @override
  void initState() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
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
            timelines: widget.customPeriods,
            onEventDragged: (CalendarEvent<EventData> old,
                CalendarEvent<EventData> newEvent, Period? period) {
              widget.onEventDragged(old, newEvent, period);
            },
            onTap: (DateTime date, Period period,
                CalendarEvent<EventData>? event) {
              widget.onTap!(date, period, event);
            },
            onWillAccept: (CalendarEvent<EventData>? event, Period period) =>
                true,
            nowIndicatorColor: Colors.red,
            cornerBuilder: (DateTime current) => Container(
              color: white,
            ),
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
            isCellDraggable: (CalendarEvent<EventData> event) =>
                isCelldraggable(event),
            controller: widget.timetableController,
            itemBuilder: (CalendarEvent<EventData> item, double width) =>
                InkWell(
              onTap: () {
                widget.onTap!(dateTime, null, item);
              },
              child: Container(
                margin: EdgeInsets.all(item.eventData!.isDutyTime ? 0 : 4),
                child: Container(
                    padding: EdgeInsets.all(item.eventData!.isDutyTime ? 0 : 6),
                    height: item.eventData!.period.isCustomeSlot
                        ? widget.timetableController.breakHeight
                        : widget.timetableController.cellHeight,
                    decoration: item.eventData!.isDutyTime
                        ? BoxDecoration(
                            border: const Border(
                                left: BorderSide(color: textGrey, width: 8)),
                            color: item.eventData!.color)
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                item.eventData!.isDutyTime ? 0 : 6),
                            color: item.eventData!.color),
                    child: item.eventData!.period.isCustomeSlot
                        ? SizedBox(
                            height: widget.timetableController.breakHeight,
                            child: Center(
                                child: Text(
                              item.eventData!.title,
                              style: context.subtitle,
                            )),
                          )
                        : EventTile(
                            item: item,
                            height: item.eventData!.period.isCustomeSlot
                                ? widget.timetableController.breakHeight
                                : widget.timetableController.cellHeight,
                            width: width,
                          )),
              ),
            ),
            cellBuilder: (Period period) => Container(
              height: period.isCustomeSlot
                  ? widget.timetableController.breakHeight
                  : widget.timetableController.cellHeight,
              decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  color: period.isCustomeSlot ? lightGrey : Colors.transparent),
            ),
          ),
        );
      }));
}
