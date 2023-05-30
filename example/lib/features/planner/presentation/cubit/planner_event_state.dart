import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_settings.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///event state
abstract class PlannerState extends Equatable {}

///event initial state
class InitialState extends PlannerState {
  @override
  List<Object> get props => <Object>[];
}

///loading state
class LoadingState extends PlannerState {
  @override
  List<Object> get props => <Object>[];
}

///use for rebuilding ui
class UpdatedState extends PlannerState {
  @override
  List<Object> get props => <Object>[];
}

///loading state
class CurrrentDateUpdated extends PlannerState {
  ///intialize
  CurrrentDateUpdated({required this.currentDate});

  ///date time
  final DateTime currentDate;

  @override
  List<Object> get props => <Object>[currentDate];
}

/// jumto date state
class JumpToDateState extends PlannerState {
  ///initilize the state
  JumpToDateState(this.dateTime);

  ///DateTime date
  final DateTime dateTime;

  @override
  List<Object> get props => <Object>[dateTime];
}

///loaded state
class LoadedState extends PlannerState {
  ///
  LoadedState(
      this.events, this.notes, this.viewType, this.periods, this.termModel);

  ///list of events
  ///list of events
  final List<PlannerEvent> events;

  ///list of events
  final List<CalendarEvent<Note>> notes;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period
  final List<Period> periods;

  ///terms model
  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[events, notes, viewType, periods, termModel];
}

///loaded state
class EventUpdatedState extends PlannerState {
  ///
  EventUpdatedState(
    this.events,
    this.oldEvent,
    this.newEvent,
    this.viewType,
    this.periods,
    this.termModel,
  );

  ///list of events
  ///list of events
  final List<PlannerEvent> events;

  /// old event
  final CalendarEvent<EventData> oldEvent;

  ///new event
  final CalendarEvent<EventData> newEvent;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period
  final List<Period> periods;

  ///terms model
  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[events, oldEvent, newEvent, viewType, periods, termModel];
}

///View updated state
class ViewUpdated implements PlannerState {
  ///
  ViewUpdated(this.events, this.viewType, this.periods, this.termModel,
      {this.jump = true});

  ///list of events
  final List<PlannerEvent> events;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  ///want to juot today
  final bool jump;

  @override
  List<Object> get props =>
      <Object>[events, viewType, periods, termModel, jump];

  @override
  bool? get stringify => false;
}

///error state
class ErrorState extends PlannerState {
  @override
  List<Object> get props => <Object>[];
}

///adding event state
class AddingEvent extends PlannerState {
  @override
  List<Object> get props => <Object>[];
}

///adding event state
class UpdatingEvent extends PlannerState {
  ///initialized updating event
  UpdatingEvent();

  @override
  List<Object> get props => <Object>[];
}

///date update event state
class DateUpdated implements PlannerState {
  ///initialize start
  DateUpdated(this.endDate, this.startDate, this.events, this.viewType,
      this.periods, this.termModel);

  ///list of events
  final List<PlannerEvent> events;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///start date
  final DateTime startDate;

  ///end Date
  final DateTime endDate;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[startDate, endDate, events, viewType, periods, termModel];

  @override
  bool? get stringify => throw UnimplementedError();
}

///PeriodsUpdated event state
class PeriodsUpdated implements PlannerState {
  ///initialize start
  PeriodsUpdated(this.periods, this.events, this.viewType, this.termModel);

  ///list of events
  final List<PlannerEvent> events;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  @override
  List<Object> get props => <Object>[periods, viewType, events, termModel];

  @override
  bool? get stringify => false;
}

///TermsUpdated event state
class TermsUpdated implements PlannerState {
  ///initialize start
  TermsUpdated(this.periods, this.events, this.viewType, this.termModel);

  ///list of events
  final List<PlannerEvent> events;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  @override
  List<Object> get props => <Object>[periods, viewType, events, termModel];

  @override
  bool? get stringify => false;
}

///MonthUpdated event state
class MonthUpdated implements PlannerState {
  ///initialize start
  MonthUpdated(this.periods, this.events, this.viewType, this.termModel,
      this.startDate, this.endDate);

  ///list of events
  final List<PlannerEvent> events;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  ///startDate
  final DateTime startDate;

  ///end date
  final DateTime endDate;

  @override
  List<Object> get props =>
      <Object>[periods, viewType, events, termModel, startDate, endDate];

  @override
  bool? get stringify => false;
}

///LoadingUpdated event state
class LoadingUpdated implements PlannerState {
  ///initialize start
  LoadingUpdated(this.periods, this.events, this.viewType, this.termModel,
      {this.isLoading = false});

  ///list of events
  final List<PlannerEvent> events;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

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
class EventsAdded implements PlannerState {
  ///initialize start
  EventsAdded(this.periods, this.events, this.viewType, this.addedEvents,
      this.termModel);

  ///list of events
  final List<PlannerEvent> events;

  ///added events
  final List<PlannerEvent> addedEvents;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[periods, events, addedEvents, viewType, termModel];

  @override
  bool? get stringify => false;
}

///EventsUpdated event state
class EventsUpdated implements PlannerState {
  ///initialize start
  EventsUpdated(this.periods, this.events, this.viewType, this.updatedEvents,
      this.termModel);

  ///list of events
  final List<PlannerEvent> events;

  ///updated events
  final List<PlannerEvent> updatedEvents;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[periods, events, viewType, updatedEvents, termModel];

  @override
  bool? get stringify => false;
}

///EventsUpdated event state
class DeletedEvents implements PlannerState {
  ///initialize start
  DeletedEvents(this.periods, this.events, this.viewType, this.deletedEvents,
      this.termModel);

  ///list of events
  final List<PlannerEvent> events;

  ///deleted events
  final List<PlannerEvent> deletedEvents;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[periods, events, viewType, deletedEvents, termModel];

  @override
  bool? get stringify => false;
}

///ChangeToCurrentDate event state
class ChangeToCurrentDate implements PlannerState {
  ///initialize ChangeToCurrentDate
  ChangeToCurrentDate(this.periods, this.events, this.viewType,
      this.deletedEvents, this.termModel,
      {this.isDateChanged = false, this.isViewChanged = false});

  ///list of events
  final List<PlannerEvent> events;

  ///deleted events
  final List<PlannerEvent> deletedEvents;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///bool isDateChanged
  final bool isDateChanged;

  /// isViewChanged true when view changed because eof term view
  final bool isViewChanged;

  ///terms model

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

///export
class GeneratePreview implements PlannerState {
  ///initilize the state
  GeneratePreview(this.exportSetting);

  ///object of the export setting
  final ExportSetting exportSetting;

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  bool? get stringify => false;
}

///EventsAdded event state
class NotesAdded implements PlannerState {
  ///initialize start
  NotesAdded(
      this.periods, this.notes, this.viewType, this.addedNotes, this.termModel);

  ///list of events
  final List<CalendarEvent<Note>> notes;

  ///added [Notes]
  final List<CalendarEvent<Note>> addedNotes;

  /// view type of the calendar
  final CalendarViewType viewType;

  ///list of the period

  final List<Period> periods;

  ///terms model

  final TermModel termModel;

  @override
  List<Object> get props =>
      <Object>[periods, notes, addedNotes, viewType, termModel];

  @override
  bool? get stringify => false;
}