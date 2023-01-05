import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart'; 
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/single_day_event_tile.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_calendar/flutter_calendar.dart';

///event tile for the week
class DayEvent extends StatelessWidget {
  ///initilize the week event
  const DayEvent(
      {required this.item,
      required this.cellHeight,
      required this.breakHeight,
      required this.width,
      required this.timeLineWidth,
      required this.periods,
      super.key,
      this.onTap});

  ///event during day
  final CalendarEvent<EventData> item;

  ///cell and break height
  final double cellHeight, breakHeight;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, Period?, CalendarEvent<EventData>?)? onTap;

  ///widht of event
  final double width;

  ///list of periods
  final List<Period> periods;

  ///width of the timeline
  final double timeLineWidth;

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
    return GestureDetector(
      onTap: () {
        onTap!(item.startTime, null, item);
      },
      child: SingleDayEventTile(
          border: item.eventData!.isDuty
              ? null
              : Border.all(color: white, width: 2),
          cellWidth: width - timeLineWidth,
          item: item,
          isDraggable: false,
          periodModel: periodModel,
          breakHeight: breakHeight,
          cellHeight: cellHeight),
    );
  }
}
