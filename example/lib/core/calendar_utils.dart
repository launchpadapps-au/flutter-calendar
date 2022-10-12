import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
///check is cell is dragagble or not
bool isCelldraggable(CalendarEvent<EventData> event) {
  if (event.eventData!.isDutyTime || event.eventData!.freeTime) {
    return false;
  }
  return true;
}
///check if cell is tapable or not
bool isOnTapEnable(CalendarEvent<EventData> event) {
  if (event.eventData!.isDutyTime || event.eventData!.freeTime) {
    return false;
  }
  return true;
}
