import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///event state
abstract class TimeTableState extends Equatable {}

///event initial state
class InitialState extends TimeTableState {
  @override
  List<Object> get props => <Object>[];
}

///loading state
class LoadingState extends TimeTableState {
  @override
  List<Object> get props => <Object>[];
}

///loaded state
class LoadedState extends TimeTableState {
  ///
  LoadedState(this.events, this.viewType, this.periods, this.termModel);

  ///list of events
  final List<PlannerEvent> events;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period
  final List<Period> periods;

  ///terms model
  final TermModel termModel;
  @override
  List<Object> get props => <Object>[events, viewType, periods, termModel];
}

///View updated state
class ViewUpdated implements LoadedState {
  ///
  ViewUpdated(this.events, this.viewType, this.periods, this.termModel);

  ///list of events
  @override
  final List<PlannerEvent> events;

  /// view type of the calendar
  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;
  @override
  List<Object> get props => <Object>[events, viewType, periods, termModel];

  @override
  bool? get stringify => false;
}

///error state
class ErrorState extends TimeTableState {
  @override
  List<Object> get props => <Object>[];
}

///adding event state
class AddingEvent extends TimeTableState {
  @override
  List<Object> get props => <Object>[];
}

///adding event state
class UpdatingEvent extends TimeTableState {
  ///initialized updating event
  UpdatingEvent();

  @override
  List<Object> get props => <Object>[];
}

///date update event state
class DateUpdated implements LoadedState {
  ///initialize start
  DateUpdated(this.endDate, this.startDate, this.events, this.viewType,
      this.periods, this.termModel);

  @override
  final List<PlannerEvent> events;

  @override
  final CalendarViewType viewType;

  ///start date
  final DateTime startDate;

  ///end Date
  final DateTime endDate;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[startDate, endDate, events, viewType, periods, termModel];

  @override
  bool? get stringify => throw UnimplementedError();
}

///PeriodsUpdated event state
class PeriodsUpdated implements LoadedState {
  ///initialize start
  PeriodsUpdated(this.periods, this.events, this.viewType, this.termModel);

  @override
  final List<PlannerEvent> events;

  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;
  @override
  List<Object> get props => <Object>[periods, viewType, events, termModel];

  @override
  bool? get stringify => false;
}

///TermsUpdated event state
class TermsUpdated implements LoadedState {
  ///initialize start
  TermsUpdated(this.periods, this.events, this.viewType, this.termModel);

  @override
  final List<PlannerEvent> events;

  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;

  @override
  List<Object> get props => <Object>[periods, viewType, events, termModel];

  @override
  bool? get stringify => false;
}

///LoadingUpdated event state
class LoadingUpdated implements LoadedState {
  ///initialize start
  LoadingUpdated(this.periods, this.events, this.viewType, this.termModel,
      {this.isLoading = false});

  @override
  final List<PlannerEvent> events;

  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;

  ///true if loading indicator
  final bool isLoading;

  @override
  List<Object> get props =>
      <Object>[periods, viewType, events, termModel, isLoading];

  @override
  bool? get stringify => false;
}

///EventsAdded event state
class EventsAdded implements LoadedState {
  ///initialize start
  EventsAdded(this.periods, this.events, this.viewType, this.addedEvents,
      this.termModel);

  @override
  final List<PlannerEvent> events;

  ///added events
  final List<PlannerEvent> addedEvents;

  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[periods, events, addedEvents, viewType, termModel];

  @override
  bool? get stringify => false;
}

///EventsUpdated event state
class EventsUpdated implements LoadedState {
  ///initialize start
  EventsUpdated(this.periods, this.events, this.viewType, this.updatedEvents,
      this.termModel);

  @override
  final List<PlannerEvent> events;

  ///updated events
  final List<PlannerEvent> updatedEvents;
  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;
  @override
  List<Object> get props =>
      <Object>[periods, events, viewType, updatedEvents, termModel];

  @override
  bool? get stringify => false;
}

///EventsUpdated event state
class DeletedEvents implements LoadedState {
  ///initialize start
  DeletedEvents(this.periods, this.events, this.viewType, this.deletedEvents,
      this.termModel);

  @override
  final List<PlannerEvent> events;

  ///deleted events
  final List<PlannerEvent> deletedEvents;
  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///terms model
  @override
  final TermModel termModel;
  @override
  List<Object> get props =>
      <Object>[periods, events, viewType, deletedEvents, termModel];

  @override
  bool? get stringify => false;
}

///ChangeToCurrentDate event state
class ChangeToCurrentDate implements LoadedState {
  ///initialize ChangeToCurrentDate
  ChangeToCurrentDate(this.periods, this.events, this.viewType,
      this.deletedEvents, this.termModel,
      {this.isDateChanged = false, this.isViewChanged = false});

  @override
  final List<PlannerEvent> events;

  ///deleted events
  final List<PlannerEvent> deletedEvents;
  @override
  final CalendarViewType viewType;

  ///list of the period
  @override
  final List<Period> periods;

  ///bool isDateChanged
  final bool isDateChanged;

  /// isViewChanged true when view changed because eof term view
  final bool isViewChanged;

  ///terms model
  @override
  final TermModel termModel;
  @override
  List<Object> get props => <Object>[
        periods,
        events,
        termModel,
        viewType,
        deletedEvents,
        isDateChanged,
        isViewChanged
      ];

  @override
  bool? get stringify => false;
}
