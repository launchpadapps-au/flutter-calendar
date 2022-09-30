/// enum data type for the CalendarView
enum CalendarViewType {
  /// day view of the calendar
  dayView,

  ///schedule view of the calendar
  scheduleView,

  ///week view of the calendar
  weekView,

  ///MonthView of the calendar
  monthView,

  ///termView of the calendar
  termView,

  ///glScheduleView view of the calendar,similar to google calendar scheduleView
  glScheduleView,
}

///return calendar view based on string
CalendarViewType getCalendarViewString(String viewType) {
  if (viewType == CalendarViewType.dayView.name) {
    return CalendarViewType.dayView;
  } else if (viewType == CalendarViewType.weekView.name) {
    return CalendarViewType.weekView;
  } else if (viewType == CalendarViewType.scheduleView.name) {
    return CalendarViewType.scheduleView;
  } else if (viewType == CalendarViewType.monthView.name) {
    return CalendarViewType.monthView;
  } else if (viewType == CalendarViewType.termView.name) {
    return CalendarViewType.termView;
  } else {
    return CalendarViewType.weekView;
  }
}
