import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dayview/day_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dayview/day_event.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dayview/day_header.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dayview/day_hour_lable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';

///planner
class DayPlanner extends StatefulWidget {
  /// initialized day planner
  const DayPlanner(
      {required this.timetableController,
      required this.customPeriods,
      required this.onTap,
      required this.onEventDragged,
      required this.onDateChanged,
      required this.isMobile,
      this.onEventToEventDragged,
      Key? key,
      this.id})
      : super(key: key);

  ///custom periods for the timetable
  final List<Period> customPeriods;

  ///id that we will received from native ios
  final String? id;

  ///timetable controller for the calendar
  final TimetableController<EventData> timetableController;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, Period?, CalendarEvent<EventData>?) onTap;

  ///return new and okd event
  final Function(CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent, Period periodModel)? onEventDragged;

  ///pass true if device is mobile
  final bool isMobile;

  ///return existing ,old and new event when used drag and drop
  ///the event on the existing event
  final Function(
      CalendarEvent<EventData> existing,
      CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent,
      Period? periodModel)? onEventToEventDragged;

  ///give new day when day is scrolled
  final Function(DateTime dateTime) onDateChanged;

  @override
  State<DayPlanner> createState() => _DayPlannerState();
}

class _DayPlannerState extends State<DayPlanner> {
  static DateTime dateTime = DateTime.now();

  DateTime currentMonth = DateTime.now();

  ValueNotifier<DateTime> dateTimeNotifier = ValueNotifier<DateTime>(dateTime);

  @override
  Widget build(BuildContext context) => NewSlDayView<EventData>(
      backgroundColor: white,
      timelines: widget.customPeriods,
      onDateChanged: widget.onDateChanged,
      onEventDragged: (CalendarEvent<EventData> old,
          CalendarEvent<EventData> newEvent, Period? period) {
        if (widget.onEventDragged != null) {
          widget.onEventDragged!(old, newEvent, period!);
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
      onWillAccept:
          (CalendarEvent<EventData>? event, DateTime date, Period period) {
        final PeriodModel periodModel = period as PeriodModel;

        return !periodModel.isCustomeSlot;
      },
      onWillAcceptForEvent: (CalendarEvent<EventData> draggeed,
          CalendarEvent<EventData> existing, DateTime dateTime) {
        if (existing.eventData!.isDuty) {
          return false;
        } else {
          return true;
        }
      },
      fullWeek: true,
      nowIndicatorColor: timeIndicatorColor,
      showNowIndicator: false,
      cornerBuilder: (DateTime current) => const SizedBox.shrink(),
      onTap: widget.onTap,
      headerHeight: widget.isMobile ? headerHeightForDayView : 40,
      headerCellBuilder: (DateTime date) => DayHeader(
          date: date,
          isMobile: widget.isMobile,
          timeLineWidth: widget.timetableController.timelineWidth),
      headerTitleBuilder: (DateTime date) => widget.isMobile
          ? const SizedBox.shrink()
          : Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                      height: widget.timetableController.headerHeight,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 0.5),
                          color: lightGrey),
                      child: Center(
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width:
                                  widget.timetableController.timelineWidth / 4,
                            ),
                            Text(
                              DateFormat('EEEE').format(date).toUpperCase(),
                              style: context.subtitle1.copyWith(
                                  color: isSameDate(date) ? textBlack : null),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              DateFormat('d ').format(date),
                              style: context.headline1.copyWith(
                                  color: isSameDate(date) ? textBlack : null),
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
      hourLabelBuilder: (Period period) => DayHourLable(
          periodModel: period as PeriodModel, isMobile: widget.isMobile),
      controller: widget.timetableController,
      isCellDraggable: (CalendarEvent<EventData> event) =>
          CalendarUtils.isCelldraggable(event),
      itemBuilder: (CalendarEvent<EventData> item, int index, int length,
              double width) =>
          DayEvent(
            item: item,
            cellHeight: widget.timetableController.cellHeight,
            breakHeight: widget.timetableController.breakHeight,
            width: width,
            isMobile: widget.isMobile,
            onTap: widget.onTap,
            periods: widget.customPeriods,
          ),
      cellBuilder: (Period period, DateTime date) => DayCell(
          periodModel: period as PeriodModel,
          breakHeight: widget.timetableController.breakHeight,
          cellHeight: widget.timetableController.cellHeight,
          isMobile: widget.isMobile));
}
