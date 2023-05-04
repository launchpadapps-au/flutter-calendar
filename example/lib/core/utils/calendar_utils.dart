import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///utils method for the calendar
class CalendarUtils {
  ///check is cell is dragagble or not
  static bool isCelldraggable(CalendarEvent<EventData> event) {
    if (event.eventData!.isDutyTime || event.eventData!.freeTime) {
      return false;
    }
    return true;
  }

  ///check if cell is tapable or not
  static bool isOnTapEnable(CalendarEvent<EventData> event) {
    if (event.eventData!.freeTime) {
      return false;
    }
    return true;
  }

  ///get index of the index stack
  static int getIndex(CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.dayView:
        return 0;
      case CalendarViewType.weekView:
        return 1;
      case CalendarViewType.scheduleView:
        return 2;
      case CalendarViewType.monthView:
        return 3;
      case CalendarViewType.termView:
        return 4;
      case CalendarViewType.glScheduleView:
        return 5;
      default:
        return 2;
    }
  }

  ///return day name based on index
  static String getWeekDay(int index) {
    switch (index) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return 'Day';
    }
  }
}
