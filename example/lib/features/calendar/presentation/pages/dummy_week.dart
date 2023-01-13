import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

class DummyWeek extends StatelessWidget {
  DummyWeek({super.key});

  final TimetableController<EventData> timeTableController =
      TimetableController<EventData>(
    start: DefaultDates.startDate,
    infiniteScrolling: CalendarParams.infiniteScrolling,
    end: DefaultDates.endDate,
    timelineWidth: CalendarParams.timelineWidth,
    breakHeight: CalendarParams.breakHeighth,
    cellHeight: CalendarParams.cellHeighth,
  );
  @override
  Widget build(BuildContext context) {
    return SlWeekView<EventData>(
      fullWeek: true,
      controller: timeTableController,
      timelines: customStaticPeriods,
      onWillAccept: (p0, p1) => true,
    );
  }
}
