import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart'; 
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/event_tile.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_calendar/flutter_calendar.dart';

///event tile for the week
class WeekEvent extends StatelessWidget {
  ///initilize the week event
  const WeekEvent(
      {required this.item,
      required this.cellHeight,
      required this.breakHeight,
      required this.width,
      required this.periods,
      super.key,
      this.onTap});

  ///event object during week
  final CalendarEvent<EventData> item;
///list of periods
 final List<Period> periods;

  ///cell and break height
  final double cellHeight, breakHeight;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, Period?, CalendarEvent<EventData>?)? onTap;

  ///widht of event
  final double width;

  @override
  Widget build(BuildContext context) {
    PeriodModel? periodModel;

    try {
      final Period p = periods
          .firstWhere((Period element) => element.id == item.eventData!.slots);
      periodModel = p as PeriodModel;
    } on Exception {
      periodModel = null;
    }

    Color dutyColor = item.eventData!.color;
    Color borderColor = textGrey;
    if (periodModel != null) {
      if (periodModel.isAfterSchool || periodModel.isBeforeSchool) {
        dutyColor = lightPink;
        borderColor = lightPinkBorder;
      }
    }
    return InkWell(
      onTap: () {
        onTap!(item.startTime, null, item);
      },
      child: Container(
        margin: EdgeInsets.all(item.eventData!.isDutyTime ? 0 : 4),
        child: Container(
            padding: EdgeInsets.all(item.eventData!.isDutyTime ? 0 : 6),
            height: item.eventData!.isDuty ? breakHeight : cellHeight,
            decoration: item.eventData!.isDutyTime
                ? BoxDecoration(
                    border:
                        Border(left: BorderSide(color: borderColor, width: 8)),
                    color: dutyColor)
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        item.eventData!.isDutyTime ? 0 : 6),
                    color: item.eventData!.color),
            child: item.eventData!.isDuty
                ? SizedBox(
                    height: breakHeight,
                    child: Center(
                        child: Text(
                      item.eventData!.title,
                      style: context.subtitle,
                    )),
                  )
                : EventTile(
                    item: item,
                    height: item.eventData!.isDuty ? breakHeight : cellHeight,
                    width: width,
                  )),
      ),
    );
  }
}
