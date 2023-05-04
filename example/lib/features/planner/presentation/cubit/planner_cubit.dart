import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/datasources/fake_datasource.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/change_view_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/date_change_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/loading_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/callbacks/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/callbacks/mock_method.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/callbacks/native_callbacks.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_settings.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/export_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///timetable cubit
class PlannerCubit extends Cubit<PlannerState> {
  /// initialized timetable cubit

  PlannerCubit() : super(InitialState()) {
    nativeCallBack.initializeChannel('com.example.demo/data');
    setListener(mock: standAlone);
    addData(addDummyEvent: false);
  }

  ///if code is running as stand alone app then it will be true
  static const bool _standAlone = bool.fromEnvironment('standalone');

  ///rrturn true if project run as stand alone
  bool get standAlone => _standAlone;

  /// set method handler to receive data from flutter
  static const MethodChannel platform = MethodChannel(
    'com.example.demo/data',
  );

  ///mock method object
  static MockMethod mockObject = MockMethod();

  ///object of the native callback class
  NativeCallBack nativeCallBack = NativeCallBack();

  ///current date timex
  static DateTime now = DateUtils.dateOnly(DateTime.now());

  ///current date  for the calendar
  static DateTime currentDate = now;

  ///get Current date
  DateTime get date => currentDate;

  ///start date of the timetable

  DateTime startDate = DateTime(now.year, now.month);

  ///margin from top
  double topMargin = 0;

  ///end date of the timetable

  DateTime endDate =
      DateTime(now.year, now.month + 1).subtract(const Duration(days: 1));

  ///view of the calendar
  CalendarViewType viewType = CalendarViewType.weekView;

  ///list of the periods of the timetable
  List<PeriodModel> periods = customStaticPeriods;

  ///all cade related to state management inside the flutter module
  ///get event
  List<PlannerEvent> get events => _events;

  ///events of timetable
  List<PlannerEvent> _events = <PlannerEvent>[];
  // List<PeriodModel> periods = dummyPeriods;
  ///events of timetable
  List<CalendarEvent<Note>> _notes = <CalendarEvent<Note>>[];

  ///return list of month event
  List<CalendarEvent<Note>> get notes => _notes;

  ///this model hold the data related to terms .it cant be change
  TermModel globalTermModel = FakeDataSource.termModel;

  ///this model hold the data related to terms of the s
  TermModel termModel = termFromJson;

  ///true if calendar is in loading mode
  bool isLoading = false;

  ///json encoded string of the event for the backup
  String? eventString;

  ///String id
  String? id;

  ///object for the export preview
  late ExportView exportView = ExportView(nativeCallBack);

  ///set listner for
  void setListener({bool mock = false}) {
    if (mock) {
      logPrety('Mocking Platform Channel');
    }

    (mock ? mockObject.stream : nativeCallBack.onDataReceived.stream)
        .listen((MethodCall call) async {
      switch (call.method) {
        case ReceiveMethods.setLoading:
          final LoadingModel loadingModel =
              loadingModelFromJson(jsonEncode(call.arguments));

          isLoading = loadingModel.isLoading;
          logPrety('setLoading received from native app: $isLoading');
          emit(LoadingUpdated(periods, _events, viewType, termModel,
              isLoading: isLoading));
          break;

        ///receive data change command from ios
        ///handle data change
        case ReceiveMethods.setDates:
          final DateChange dateChange =
              DateChange.fromJson(jsonDecode(call.arguments));
          startDate = dateChange.startTime;
          endDate = dateChange.endTime;
          emit(DateUpdated(
              endDate, startDate, _events, viewType, periods, termModel));
          break;

        ///handle view change
        case ReceiveMethods.setView:
          final ChangeView changeView =
              ChangeView.fromJson(jsonDecode(call.arguments));
          logPrety('Set view recived from native app${changeView.viewType}');
          changeViewType(changeView.viewType);
          break;

        case ReceiveMethods.jumpToCurrentDate:
          logInfo('JumpTo Current Date received from native app');
          // final JumpToDateModel jumpToDateModel =
          //     jumpToDateFromJson(jsonEncode(call.arguments));

          if (viewType == CalendarViewType.monthView ||
              viewType == CalendarViewType.termView) {
            logInfo('Current view is $viewType');
            changeViewType(CalendarViewType.weekView);
          } else {}

          currentDate = DateTime.now();

          emit(JumpToDateState(DateTime.now()));

          break;

        ///handle set periods method
        case ReceiveMethods.setPeriods:
          logInfo('set periods received from native app');

          final List<PeriodModel> newPeriods =
              periodModelFromJson(jsonEncode(call.arguments));

          if (newPeriods.isEmpty) {
            logInfo('Received empty slots,no changes made');
          } else {
            periods = newPeriods;
            logInfo('Received  slots,perios updated');
          }
          emit(PeriodsUpdated(periods, _events, viewType, termModel));

          break;

        ///handle set Terms method when data recieve from native app
        case ReceiveMethods.setTerms:
          logInfo('set Terms recived from native app');
          _termModel = termModelFromJson(jsonEncode(call.arguments));
          globalTermModel = termModelFromJson(jsonEncode(call.arguments));
          setCurrentTerm(date);
          emit(TermsUpdated(periods, _events, viewType, termModel));
          break;

        ///handle setEvents methods
        case ReceiveMethods.setEvents:
          final String jsonString = jsonEncode(call.arguments);
          eventString = jsonString;
          final GetEvents getEvents =
              GetEvents.fromJsonWithPeriod(jsonDecode(jsonString), periods);
          _events = getEvents.events
              .where((PlannerEvent element) =>
                  !globalTermModel.terms.isInBufferTime(element.startTime))
              .toList();

          logInfo(
              'set events received from native app:${getEvents.events.length}');
          emit(EventsAdded(
              periods, _events, viewType, getEvents.events, termModel));
          break;
        case ReceiveMethods.resetEvent:
          logPrety('Reset event recived from the IOS');
          if (eventString != null) {
            final GetEvents getEvents =
                GetEvents.fromJsonWithPeriod(jsonDecode(eventString!), periods);
            _events = getEvents.events;
            emit(EventsAdded(
                periods, _events, viewType, getEvents.events, termModel));
          }

          break;

        ///handle setNotes methods
        case ReceiveMethods.setNots:
          final GetNotes getNotes =
              GetNotes.fromRawJson(jsonEncode(call.arguments));
          _notes = getNotes.note;
          logInfo('Set Notes received from ios: no Notes:${_notes.length}');
          emit(NotesAdded(periods, _notes, viewType, getNotes.note, termModel));
          break;

        case ReceiveMethods.generatePreview:
          logInfo('Generate Preview received from native app');
          final ExportSetting exportSetting =
              exportSettingFromJson(call.arguments);

          await exportView.generatePreview(
              exportSetting, periods, _events, _notes);
          break;

        case ReceiveMethods.downloadPdf:
          logInfo('Download pdf received from native app');
          await exportView.exportPdf();
          break;
        case ReceiveMethods.canclePreview:
          logInfo('Cancle Preview received from native app');
          await exportView.canclePreview();
          break;

        default:
          logInfo('Data receive from flutter:No handler');
      }
    });
  }

  ///change date
  bool changeDate(DateTime first, DateTime end) {
    endDate = end;
    startDate = first;

    nativeCallBack
      ..dateChanged(first, end)
      ..fetchDataDatesWise(first, end);
    emit(
        DateUpdated(endDate, startDate, _events, viewType, periods, termModel));
    currentDate = startDate;
    emit(JumpToDateState(currentDate));
    return true;
  }

  ///update id of the user
  Future<void> updateId(dynamic data) async {
    final Map<String, dynamic> jData = await jsonDecode(data);

    id = jData['id'].toString();
    emit(LoadedState(_events, _notes, viewType, periods, termModel));
  }

  ///get dummy events
  Future<void> addData({bool addDummyEvent = true}) async {
    try {
      emit(LoadingState());
      await Future<dynamic>.delayed(const Duration(seconds: 3));
      if (addDummyEvent) {
        final List<PeriodModel> newPeriods = await FakeDataSource.getPeriods();
        if (newPeriods.isEmpty) {
          logInfo('Received empty slots,no changes made');
        } else {
          periods = newPeriods;
          logInfo('Received  slots,perios updated');
        }
        emit(PeriodsUpdated(periods, _events, viewType, termModel));
        _events = await FakeDataSource.getEvents(periods);
        _notes = await FakeDataSource.getNotes();
        _termModel = termFromJson;
        globalTermModel = termFromJson;
        setCurrentTerm(date);
        emit(LoadedState(_events, _notes, viewType, periods, _termModel!));
      }
    } on Exception catch (e) {
      logInfo(e.toString());
      emit(ErrorState());
    }
  }

  ///set month from date
  void setMonthFromDate(DateTime date) {
    final int month = date.month;
    final int year = date.year;
    final DateTime firstDate = DateTime(year, month);
    final DateTime lastDate =
        DateTime(year, month + 1).subtract(const Duration(days: 1));
    nativeCallBack.fetchNotes(firstDate, lastDate);
  }

  ///call maintaning state of the dragged event
  bool onEventDragged(CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent, Period? period) {
    emit(UpdatingEvent());
    _events.remove(old);
    if (period != null) {
      newEvent.eventData!.slots = period.id;
    }

    logInfo('removed${old.toMap}');
    _events.add(PlannerEvent(
        startTime: newEvent.startTime,
        endTime: newEvent.endTime,
        eventData: newEvent.eventData));
    emit(EventUpdatedState(
        _events, old, newEvent, viewType, periods, termModel));
    logInfo('added${newEvent.toMap}');

    nativeCallBack.eventDragged(old, newEvent, viewType, period);
    return true;
  }

  ///chang calendar view
  void changeViewType(CalendarViewType viewType, {bool jump = true}) {
    this.viewType = viewType;
    nativeCallBack.viewChanged(viewType);
    emit(ViewUpdated(events, viewType, periods, termModel, jump: jump));
  }

  ///this function changed
  void jumpToCurrentDate() {
    final DateTime now = DateTime.now();

    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      emit(ChangeToCurrentDate(
          periods, events, viewType, <PlannerEvent>[], termModel));
    }
    {
      startDate = DateTime(now.year, now.month);
      endDate =
          DateTime(now.year, now.month + 1).subtract(const Duration(days: 2));
      bool isViewChanged = false;
      if (viewType == CalendarViewType.termView) {
        viewType = CalendarViewType.weekView;
        isViewChanged = true;
      }
      emit(ChangeToCurrentDate(
          periods, events, viewType, <PlannerEvent>[], termModel,
          isDateChanged: true, isViewChanged: isViewChanged));
    }
  }

  ////New cubit function
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///

  TermModel? _termModel;

  Term? _currentTerm;

  ///return value of the current term

  Term? get term => _currentTerm;

  ///it will send call back to native app for note data
  void fetchNotes(Term term) {
    _currentTerm = term;
    currentDate = _currentTerm!.startDate;
    nativeCallBack.visibleDateChnged(currentDate);
    emit(DateUpdated(
        term.startDate, term.endDate, events, viewType, periods, termModel));
    emit(MonthUpdated(
        periods, events, viewType, termModel, term.startDate, term.endDate));
    nativeCallBack.fetchNotes(term.startDate, term.endDate);
    // nativeCallBack.visibleDateChnged(date);
  }

  ///it handle date change functionality
  void onDateChange(DateTime dateTime, {bool jump = false}) {
    currentDate = dateTime;
    emit(DateUpdated(endDate, startDate, events, viewType, periods, termModel));
    if (jump) {
      emit(JumpToDateState(dateTime));
    }
    logPrety('New Date $dateTime');
    nativeCallBack.visibleDateChnged(dateTime);
    if (_termModel == null && _currentTerm == null) {
      logInfo('Term data is null');
    } else {
      try {
        final Term term = getCurrentTerm(dateTime);
        logInfo('Term for the date $term');
        if (term.type == _currentTerm!.type &&
            term.startDate.year == _currentTerm!.startDate.year) {
          logInfo('Date is in current term');
        } else {
          _currentTerm = term;
          nativeCallBack.fetchData(term);
        }
      } on Exception {
        logInfo('Erorr in getting terms');
      }
    }
  }

  ///find out current term based on the  date Time
  Term getCurrentTerm(DateTime dateTime) {
    late Term crTerm;
    if (_termModel != null) {
      final List<Term> terms = _termModel!.terms.terms();

      try {
        final Term term =
            terms.firstWhere((Term element) => element.isBeetWeen(dateTime));
        crTerm = term;
      } on StateError {
        final int? index = _termModel!.terms.bufferIndex(dateTime);
        if (index != null) {
          if (index == -1) {
            crTerm = _termModel!.terms.previosTerm;
            _termModel!.terms.year = crTerm.startDate.year;
          } else if (index == 0) {
            logPrety('Revious year date');
            crTerm = _termModel!.terms.term1Date;
          } else if (index == 1) {
            crTerm = _termModel!.terms.term2Date;
          } else if (index == 2) {
            crTerm = _termModel!.terms.term3Date;
          } else if (index == 3) {
            crTerm = _termModel!.terms.term4Date;
          } else if (index == 4) {
            crTerm = _termModel!.terms.term4Date;
          } else if (index == 5) {
            crTerm = _termModel!.terms.nextTerm;
            _termModel!.terms.year = crTerm.startDate.year;
          }
          logInfo('Erorr in getting terms');
        } else {
          logInfo('Buffer index is null');
        }
      }
    }
    emit(TermsUpdated(periods, events, viewType, _termModel!));
    logInfo('Current Term is :$crTerm');

    return crTerm;
  }

  ///it will set current term based on date
  void setCurrentTerm(DateTime dateTime) {
    _currentTerm = getCurrentTerm(dateTime);
    emit(TermsUpdated(periods, events, viewType, termModel));
  }
}
