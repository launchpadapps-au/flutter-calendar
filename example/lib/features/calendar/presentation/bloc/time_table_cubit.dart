import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/change_view_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/date_change_model.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_settings.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/loading_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/mock_method.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/callbacks.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///timetable cubit
class TimeTableCubit extends Cubit<TimeTableState> {
  /// initialized timetable cubit

  TimeTableCubit() : super(InitialState()) {
    nativeCallBack.initializeChannel('com.example.demo/data');
    checkRunningStatus();

    setListener(mock: mockMethod);
    setThreeYearTerm(termModel);
  }

  ///check for standalone

  Future<void> checkRunningStatus() async {
    try {
      await nativeCallBack.platform.invokeMethod<dynamic>('method');
    } on MissingPluginException {
      debugPrint('Project is running as app');
      standAlone = true;
      await getDummyData(addDummyEvent: false);
    }
  }

  ///true if running as standalone
  bool standAlone = false;

  ///true if want use mock platform method
  static bool mockMethod = false;

  ///current date time
  static DateTime now = DateTime.now();

  ///current date  for the calendar
  static DateTime currentDate = DateTime.now();

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

  // List<PeriodModel> periods = dummyPeriods;

  ///this model hold the data related to terms of the s
  TermModel termModel = termFromJson;

  ///true if calendar is in loading mode
  bool isLoading = false;

  /// set method handler to receive data from flutter
  static const MethodChannel platform = MethodChannel('com.example.demo/data');

  ///object of the native callback class
  NativeCallBack nativeCallBack = NativeCallBack();

  ///code related to native callback and data listener

  /// data for term logic for infinite scrolling

  ///string for term 1
  static String term1String = '01-01 | 31-03';

  ///string for term 2
  static String term2String = '01-04 | 30-06';

  ///string for term 3
  static String term3String = '01-07 | 30-09';

  ///string for term 4
  static String term4String = '01-10 | 31-12';

  ///previous year term1
  static Term previousTerm1 =
      Term.fromString(term1String, year: now.year - 1, type: 'term1');

  ///previous year term2
  static Term previousTerm2 =
      Term.fromString(term2String, year: now.year - 1, type: 'term2');

  ///previous year term3
  static Term previousTerm3 =
      Term.fromString(term3String, year: now.year - 1, type: 'term3');

  ///previous year term4
  static Term previousTerm4 =
      Term.fromString(term4String, year: now.year - 1, type: 'term4');

  ///current year term1
  static Term term1 = Term.fromString(term1String, type: 'term1');

  ///current year term2
  static Term term2 = Term.fromString(term2String, type: 'term2');

  ///current year term3
  static Term term3 = Term.fromString(term3String, type: 'term3');

  ///current year term4
  static Term term4 = Term.fromString(term4String, type: 'term4');

  ///next year term1
  static Term nextTerm1 =
      Term.fromString(term1String, year: now.year + 1, type: 'term1');

  ///next year term1
  static Term nextTerm2 =
      Term.fromString(term2String, year: now.year + 1, type: 'term2');

  ///next year term1
  static Term nextTerm3 =
      Term.fromString(term3String, year: now.year + 1, type: 'term3');

  ///next year term1
  static Term nextTerm4 =
      Term.fromString(term4String, year: now.year + 1, type: 'term4');

  ///list of the term for current,next and previous year
  static List<Term> listOfTerm = <Term>[
    previousTerm1,
    previousTerm2,
    previousTerm3,
    previousTerm4,
    term1,
    term2,
    term3,
    term4,
    nextTerm1,
    nextTerm2,
    nextTerm3,
    nextTerm4
  ];

  ///mock method object
  MockMethod mockObject = MockMethod();

  ///set listner for
  void setListener({bool mock = false}) {
    (mock ? mockObject.stream : nativeCallBack.onDataReceived.stream)
        .listen((MethodCall call) async {
      switch (call.method) {
        case ReceiveMethods.setLoading:
          final LoadingModel loadingModel =
              loadingModelFromJson(jsonEncode(call.arguments));

          isLoading = loadingModel.isLoading;
          debugPrint('setLoading received from native app: $isLoading');
          emit(LoadingUpdated(periods, _events, viewType, termModel,
              isLoading: isLoading));
          break;

        ///receive data change command from ios
        ///handle data change
        case ReceiveMethods.setDates:
          debugPrint('date receive from flutter');
          final DateChange dateChange =
              DateChange.fromJson(jsonDecode(call.arguments));
          startDate = dateChange.startTime;
          endDate = dateChange.endTime;
          emit(DateUpdated(
              endDate, startDate, _events, viewType, periods, termModel));
          break;

        ///handle view change
        case ReceiveMethods.setView:
          debugPrint('set view received from native app');
          final ChangeView changeView =
              ChangeView.fromJson(jsonDecode(call.arguments));

          changeViewType(changeView.viewType);
          break;

        case ReceiveMethods.jumpToCurrentDate:
          debugPrint('JumpTo Current Date received from native app');
          // final JumpToDateModel jumpToDateModel =
          //     jumpToDateFromJson(jsonEncode(call.arguments));

          if (viewType == CalendarViewType.monthView ||
              viewType == CalendarViewType.termView) {
            debugPrint('Current view is $viewType');
            changeViewType(CalendarViewType.weekView);
          } else {}

          currentDate = DateTime.now();
          setDateWhenJump(currentDate);
          emit(JumpToDateState(DateTime.now()));

          break;

        ///handle set periods method
        case ReceiveMethods.setPeriods:
          debugPrint('Periods: ${call.arguments}');
          debugPrint('set periods received from native app');

          final List<PeriodModel> newPeriods =
              periodModelFromJson(jsonEncode(call.arguments));

          if (newPeriods.isEmpty) {
            debugPrint('Received empty slots,no changes made');
          } else {
            periods = newPeriods;
            debugPrint('Received  slots,perios updated');
          }
          emit(PeriodsUpdated(periods, _events, viewType, termModel));

          break;

        ///handle set Terms method when data recieve from native app
        case ReceiveMethods.setTerms:
          debugPrint('set Terms recived from native app');
          termModel = termModelFromJson(jsonEncode(call.arguments));

          setThreeYearTerm(termModel);
          debugPrint(termModel.toJson().toString());
          emit(TermsUpdated(periods, _events, viewType, termModel));
          break;

        ///handle setEvents methods
        case ReceiveMethods.setEvents:
          final GetEvents getEvents = GetEvents.fromJsonWithPeriod(
              jsonDecode(jsonEncode(call.arguments)), periods);
          _events = getEvents.events;
          debugPrint(
              'set events received from native app:${getEvents.events.length}');
          emit(EventsAdded(
              periods, _events, viewType, getEvents.events, termModel));
          break;

        case ReceiveMethods.nextDay:
          debugPrint('Next dat received from native app');
          nextDay();
          break;
        case ReceiveMethods.previousDay:
          debugPrint('Previous dat received from native app');
          previousDay();
          break;
        case ReceiveMethods.nextWeek:
          debugPrint('Next Week received from native app');
          nextWeek();
          break;
        case ReceiveMethods.previousWeek:
          debugPrint('Previous Week received from native app');
          previousWeek();
          break;
        case ReceiveMethods.nextMonth:
          debugPrint('Next month received from native app');
          nextMonth();
          break;
        case ReceiveMethods.previousMonth:
          debugPrint('Previous month received from native app');
          previousMonth();
          break;
        case ReceiveMethods.nextTerm:
          debugPrint('Previous Term received from native app');
          nextTerm();
          break;
        case ReceiveMethods.previousTerm:
          debugPrint('Previous Term received from native app');
          previousTerm();
          break;

        case ReceiveMethods.exportPreview:
          final ExportSetting exportSetting =
              ExportSetting.fromJson(jsonDecode(jsonEncode(call.arguments)));
          debugPrint('Export setting received from native app');
          emit(ExportPreview(exportSetting));
          break;
        default:
          debugPrint('Data receive from flutter:No handler');
      }
    });
  }

  ///all cade related to state management inside the flutter module
  ///get event
  List<PlannerEvent> get events => _events;

  ///events of timetable
  List<PlannerEvent> _events = <PlannerEvent>[];

  ///String id
  String? id;

  ///change date
  bool changeDate(DateTime first, DateTime end) {
    endDate = end;
    startDate = first;

    nativeCallBack
      ..sendDateChangeToNativeApp(first, end)
      ..sendFetchDataDatesToNativeApp(first, end);
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
    emit(LoadedState(_events, viewType, periods, termModel));
  }

  ///get dummy events
  Future<void> getDummyData({bool addDummyEvent = true}) async {
    try {
      emit(LoadingState());
      await Future<dynamic>.delayed(const Duration(seconds: 3));
      if (addDummyEvent) {
        final String response1 =
            await rootBundle.loadString('assets/period.json');

        final List<PeriodModel> newPeriods = periodModelFromJson(response1);

        if (newPeriods.isEmpty) {
          debugPrint('Received empty slots,no changes made');
        } else {
          periods = newPeriods;
          debugPrint('Received  slots,perios updated');
        }
        emit(PeriodsUpdated(periods, _events, viewType, termModel));
        final String response =
            await rootBundle.loadString('assets/event.json');
        final dynamic data = jsonDecode(response);
        final GetEvents getEvents = GetEvents.fromJsonWithPeriod(data, periods);
        _events = getEvents.events;
        emit(LoadedState(_events, viewType, periods, termModel));
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      emit(ErrorState());
    }
  }

  ///current term for the calendar
  static Term currentTerm = term4;

  ///get current term
  Term get term => currentTerm;

  ///currrent index of the of the terms
  int index = listOfTerm.indexOf(currentTerm);

  ///set current term based on current time
  void setCurruentTerm({DateTime? dateTime}) {
    final int month = dateTime != null ? dateTime.month : now.month;
    if (month >= term1.startDate.month && month <= term1.endDate.month) {
      currentTerm = term1;
      index = listOfTerm.indexOf(currentTerm);
    } else if (month >= term2.startDate.month && month <= term2.endDate.month) {
      currentTerm = term2;
      index = listOfTerm.indexOf(currentTerm);
    } else if (month >= term3.startDate.month && month <= term3.endDate.month) {
      currentTerm = term3;
      index = listOfTerm.indexOf(currentTerm);
    } else if (month >= term4.startDate.month && month <= term4.endDate.month) {
      currentTerm = term4;
      index = listOfTerm.indexOf(currentTerm);
    }
  }

  ///set terms for three year
  void setThreeYearTerm(TermModel termModel, {DateTime? date}) {
    final DateTime now = date ?? DateTime.now();
    term1String = termModel.terms.term1;
    term2String = termModel.terms.term2;
    term3String = termModel.terms.term3;
    term4String = termModel.terms.term4;

    previousTerm1 =
        Term.fromString(term1String, year: now.year - 1, type: 'term1');
    previousTerm2 =
        Term.fromString(term2String, year: now.year - 1, type: 'term2');

    previousTerm3 =
        Term.fromString(term3String, year: now.year - 1, type: 'term3');
    previousTerm4 =
        Term.fromString(term4String, year: now.year - 1, type: 'term4');
    term1 = Term.fromString(term1String, type: 'term1');

    term2 = Term.fromString(term2String, type: 'term2');
    term3 = Term.fromString(term3String, type: 'term3');

    term4 = Term.fromString(term4String, type: 'term4');

    nextTerm1 = Term.fromString(term1String, year: now.year + 1, type: 'term1');

    nextTerm2 = Term.fromString(term2String, year: now.year + 1, type: 'term2');
    nextTerm3 = Term.fromString(term3String, year: now.year + 1, type: 'term3');

    nextTerm4 = Term.fromString(term4String, year: now.year + 1, type: 'term4');

    listOfTerm = <Term>[
      previousTerm1,
      previousTerm2,
      previousTerm3,
      previousTerm4,
      term1,
      term2,
      term3,
      term4,
      nextTerm1,
      nextTerm2,
      nextTerm3,
      nextTerm4
    ];
    setCurruentTerm();
    TermsUpdated(periods, events, viewType, termModel);
  }

  ///setThe current term
  void setTerm(String type) {
    // if (currentTerm.endDate.isBefore(term.startDate)) {
    //   getDataDateWise(term.startDate);
    // } else {
    //   getDataDateWise(term.endDate);
    // }
    final DateTime refdate = currentDate;
    final Iterable<Term> terms = listOfTerm.where((Term element) =>
        element.type == type && element.startDate.year == refdate.year);
    if (terms.length == 1) {
      final Term term = terms.first;
      final int i = listOfTerm.indexOf(term);
      currentTerm = term;
      index = i;
      startDate = term.startDate;
      endDate = term.endDate;
      currentDate = term.startDate;
      nativeCallBack.sendFetchDataDatesToNativeApp(startDate, endDate);
      viewType = CalendarViewType.termView;
      emit(TermsUpdated(periods, events, viewType, termModel));
    }
  }

  ///set current date
  void setDate(DateTime date) {
    currentDate = date;
    getDataDateWise(currentDate);
    emit(CurrrentDateUpdated(currentDate: currentDate));
  }

  ///jump to today
  void jumpToToday() {
    final DateTime now = DateTime.now();
    term1String = termModel.terms.term1;
    term2String = termModel.terms.term2;
    term3String = termModel.terms.term3;
    term4String = termModel.terms.term4;

    previousTerm1 =
        Term.fromString(term1String, year: now.year - 1, type: 'term1');
    previousTerm2 =
        Term.fromString(term2String, year: now.year - 1, type: 'term2');

    previousTerm3 =
        Term.fromString(term3String, year: now.year - 1, type: 'term3');
    previousTerm4 =
        Term.fromString(term4String, year: now.year - 1, type: 'term4');
    term1 = Term.fromString(term1String, type: 'term1');

    term2 = Term.fromString(term2String, type: 'term2');
    term3 = Term.fromString(term3String, type: 'term3');

    term4 = Term.fromString(term4String, type: 'term4');

    nextTerm1 = Term.fromString(term1String, year: now.year + 1, type: 'term1');

    nextTerm2 = Term.fromString(term2String, year: now.year + 1, type: 'term2');
    nextTerm3 = Term.fromString(term3String, year: now.year + 1, type: 'term3');

    nextTerm4 = Term.fromString(term4String, year: now.year + 1, type: 'term4');

    listOfTerm = <Term>[
      previousTerm1,
      previousTerm2,
      previousTerm3,
      previousTerm4,
      term1,
      term2,
      term3,
      term4,
      nextTerm1,
      nextTerm2,
      nextTerm3,
      nextTerm4
    ];
    setCurruentTerm();
    currentDate = now;
    nativeCallBack.sendFetchDataDatesToNativeApp(
        currentTerm.startDate, currentTerm.endDate);
    emit(JumpToDateState(currentDate));
  }

  ///set current date when jump requested
  void setDateWhenJump(DateTime date) {
    final Iterable<Term> terms = listOfTerm.where((Term element) =>
        element.startDate.isBefore(date) && element.endDate.isAfter(date));
    if (terms.length == 1) {
      index = listOfTerm.indexOf(terms.first);
      currentDate = date;
      startDate = terms.first.startDate;
      endDate = terms.last.endDate;
      nativeCallBack.sendFetchDataDatesToNativeApp(startDate, endDate);
    } else {}
    emit(CurrrentDateUpdated(currentDate: currentDate));
  }

  ///setCurrent Month
  void setMonth(DateTime monthStart, DateTime monthEnd) {
    currentDate = monthStart;
    log('Start Date : $monthStart End Date : $monthEnd');
    final Iterable<Term> terms = listOfTerm.where((Term element) =>
        element.startDate.isBefore(monthStart) &&
        element.endDate.isAfter(monthStart));
    if (terms.length == 1) {
      index = listOfTerm.indexOf(terms.first);
      startDate = monthStart;
      endDate = monthEnd;
      currentTerm = term;
    } else {
      final Term term = listOfTerm.firstWhere((Term element) =>
          element.startDate.isAfter(monthStart) ||
          isSameDate(monthStart, ref: element.startDate));
      index = listOfTerm.indexOf(term);
      currentTerm = term;
    }
    nativeCallBack.sendFetchDataDatesToNativeApp(monthStart, monthEnd);
    emit(MonthUpdated(
        periods, events, viewType, termModel, monthStart, monthEnd));
  }

  ///next month
  void nextMonth() {
    final DateTime dateTime =
        Jiffy(DateTime(currentDate.year, currentDate.month))
            .add(months: 1)
            .dateTime;
    currentDate = dateTime;
    final DateTime end = Jiffy(DateTime(currentDate.year, currentDate.month))
        .add(months: 2)
        .subtract(days: 1)
        .dateTime;
    endDate = end;
    startDate = currentDate;

    nativeCallBack.sendFetchDataDatesToNativeApp(startDate, endDate);

    emit(
        MonthUpdated(periods, events, viewType, termModel, startDate, endDate));
  }

  ///set month from date
  void setMonthFromDate(DateTime date) {
    final int month = date.month;
    final int year = date.year;
    final DateTime firstDate = DateTime(year, month);
    final DateTime lastDate =
        DateTime(year, month + 1).subtract(const Duration(days: 1));
    setMonth(firstDate, lastDate);
  }

  ///previous month
  void previousMonth() {
    final DateTime dateTime =
        Jiffy(DateTime(currentDate.year, currentDate.month))
            .subtract(months: 1)
            .dateTime;
    currentDate = dateTime;
    final DateTime end = Jiffy(DateTime(currentDate.year, currentDate.month))
        .subtract(months: 2)
        .add(days: 1)
        .dateTime;
    endDate = end;
    startDate = currentDate;

    nativeCallBack.sendFetchDataDatesToNativeApp(end, startDate);
    emit(
        MonthUpdated(periods, events, viewType, termModel, startDate, endDate));
  }

  ///next day
  void nextDay({DateTime? dateTime}) {
    final DateTime dateTime = Jiffy(currentDate).add(days: 1).dateTime;
    currentDate = dateTime;
    getDataDateWise(currentDate);
    emit(JumpToDateState(currentDate));
  }

  ///previous day
  void previousDay({DateTime? dateTime}) {
    final DateTime dateTime = Jiffy(currentDate).subtract(days: 1).dateTime;
    currentDate = dateTime;
    getDataDateWise(currentDate);
    emit(JumpToDateState(currentDate));
  }

  ///next day
  void nextWeek() {
    DateTime tempDate = currentDate;
    if (tempDate.weekday == 1) {
      tempDate = tempDate.add(const Duration(days: 1));
      getDataDateWise(tempDate);
    }
    while (tempDate.weekday != 1) {
      tempDate = tempDate.add(const Duration(days: 1));
      getDataDateWise(tempDate);
    }
    currentDate = tempDate;
    log('Next Monday: $currentDate');
    getDataDateWise(currentDate);
    emit(JumpToDateState(currentDate));
  }

  ///previous day
  void previousWeek() {
    DateTime tempDate = currentDate;
    if (tempDate.weekday == 1) {
      tempDate = tempDate.subtract(const Duration(days: 1));
      getDataDateWise(tempDate);
    }

    while (tempDate.weekday != 1) {
      tempDate = tempDate.subtract(const Duration(days: 1));
      getDataDateWise(tempDate);
    }
    currentDate = tempDate;
    log('Previous Monday: $currentDate');
    getDataDateWise(currentDate);
    emit(JumpToDateState(currentDate));
  }

  ///scroll to closest monday
  void snapToCloseMonday(DateTime date) {
    if (date.weekday != 1) {
      if (date.weekday == 6 || date.weekday == 7) {
        currentDate = date;
        nextWeek();
      } else {
        previousWeek();
      }
    }
  }

  ///next term
  void nextTerm() {
    final Term next = listOfTerm[index + 1];
    currentDate = next.startDate;
    getDataDateWise(next.startDate);
  }

  ///previous term

  void previousTerm() {
    final Term previous = listOfTerm[index - 1];
    currentDate = previous.startDate;
    getDataDateWise(previous.endDate);
  }

  ///check for term when date changed and and ask for fetch datat
  void setDayView() {
    setCurruentTerm(dateTime: currentDate);
  }

  ///check for term when date changed and and ask for fetch datat
  void getDataDateWise(DateTime dateTime) {
    final Term next = listOfTerm[index + 1];
    final Term pre = listOfTerm[index - 1];

    if (isSameDate(dateTime, ref: next.startDate)) {
      debugPrint('Load data for :${next.type} - ${next.startDate.year}');
      nativeCallBack.sendFetchDataToNativeApp(next);
      Term last = listOfTerm.last;
      if (last.type == 'term4') {
        last = Term.fromString(term1String,
            year: last.startDate.year + 1, type: 'term1');
        listOfTerm
          ..removeAt(0)
          ..add(last);
      } else if (last.type == 'term3') {
        last = Term.fromString(term4String,
            year: last.startDate.year, type: 'term4');
        listOfTerm
          ..removeAt(0)
          ..add(last);
      } else if (last.type == 'term2') {
        last = Term.fromString(term3String,
            year: last.startDate.year, type: 'term3');
        listOfTerm
          ..removeAt(0)
          ..add(last);
      } else if (last.type == 'term1') {
        last = Term.fromString(term2String,
            year: last.startDate.year, type: 'term2');
        listOfTerm
          ..removeAt(0)
          ..add(last);
      }

      log('Last term: $last');
      final Term term1 = listOfTerm[4];
      final Term term2 = listOfTerm[5];
      final Term term3 = listOfTerm[6];
      final Term term4 = listOfTerm[7];
      final Map<String, Object> json = <String, Object>{
        'id': '0',
        'term': <String, dynamic>{
          'id': '0',
          'territory': 'default',
          'term1': "${DateFormat('dd-MM').format(term1.startDate)}|"
              "${DateFormat('dd-MM').format(term1.endDate)}",
          'term2': "${DateFormat('dd-MM').format(term2.startDate)}|"
              "${DateFormat('dd-MM').format(term2.endDate)}",
          'term3': "${DateFormat('dd-MM').format(term3.startDate)}|"
              "${DateFormat('dd-MM').format(term3.endDate)}",
          'term4': "${DateFormat('dd-MM').format(term4.startDate)}|"
              "${DateFormat('dd-MM').format(term4.endDate)}",
        }
      };
      termModel = TermModel.fromJson(json);
      currentTerm = listOfTerm[index];
      debugPrint('Pre term ${listOfTerm[index - 1]}');
      debugPrint('Current term ${listOfTerm[index]}');
      debugPrint('Next term ${listOfTerm[index + 1]}');
      emit(TermsUpdated(periods, events, viewType, termModel));
    } else if (isSameDate(dateTime, ref: pre.endDate)) {
      nativeCallBack.sendFetchDataToNativeApp(pre);
      debugPrint('Load data for :${pre.type} - ${pre.startDate.year}');
      Term first = listOfTerm.first;
      if (first.type == 'term4') {
        first = Term.fromString(term3String,
            year: first.endDate.year, type: 'term3');
        listOfTerm
          ..removeAt(listOfTerm.length - 1)
          ..insert(0, first);
      } else if (first.type == 'term3') {
        first = Term.fromString(term2String,
            year: first.endDate.year, type: 'term2');
        listOfTerm
          ..removeAt(listOfTerm.length - 1)
          ..insert(0, first);
      } else if (first.type == 'term2') {
        first = Term.fromString(term1String,
            year: first.endDate.year, type: 'term1');
        listOfTerm
          ..removeAt(listOfTerm.length - 1)
          ..insert(0, first);
      } else if (first.type == 'term1') {
        first = Term.fromString(term4String,
            year: first.endDate.year - 1, type: 'term4');
        listOfTerm
          ..removeAt(listOfTerm.length - 1)
          ..insert(0, first);
      }

      log('first term: $first');
      final Term term1 = listOfTerm[4];
      final Term term2 = listOfTerm[5];
      final Term term3 = listOfTerm[6];
      final Term term4 = listOfTerm[7];
      final Map<String, Object> json = <String, Object>{
        'id': '0',
        'term': <String, dynamic>{
          'id': '0',
          'territory': 'default',
          'term1': "${DateFormat('dd-MM').format(term1.startDate)}|"
              "${DateFormat('dd-MM').format(term1.endDate)}",
          'term2': "${DateFormat('dd-MM').format(term2.startDate)}|"
              "${DateFormat('dd-MM').format(term2.endDate)}",
          'term3': "${DateFormat('dd-MM').format(term3.startDate)}|"
              "${DateFormat('dd-MM').format(term3.endDate)}",
          'term4': "${DateFormat('dd-MM').format(term4.startDate)}|"
              "${DateFormat('dd-MM').format(term4.endDate)}",
        }
      };
      termModel = TermModel.fromJson(json);
      currentTerm = listOfTerm[index];
      debugPrint('Pre term ${listOfTerm[index - 1]}');
      debugPrint('Current term ${listOfTerm[index]}');
      debugPrint('Next term ${listOfTerm[index + 1]}');
      emit(TermsUpdated(periods, events, viewType, termModel));
    }
  }

  ///call this function to add events
  Future<void> addEvent(PlannerEvent value) async {
    emit(AddingEvent());

    await Future<dynamic>.delayed(const Duration(seconds: 2));

    if (state is LoadedState) {
    } else {
      _events.add(value);
      emit(LoadedState(_events, viewType, periods, termModel));
    }
  }

  ///remove pld event and add new event
  bool updateEvent(CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent, Period? period) {
    emit(UpdatingEvent());
    _events.remove(old);
    if (period != null) {
      newEvent.eventData!.slots = period.id;
    }

    log('removed${old.toMap}');
    _events.add(PlannerEvent(
        startTime: newEvent.startTime,
        endTime: newEvent.endTime,
        eventData: newEvent.eventData));
    emit(EventUpdatedState(
        _events, old, newEvent, viewType, periods, termModel));
    log('added${newEvent.toMap}');
    return true;
  }

  ///call maintaning state of the dragged event
  bool onEventDragged(CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent, Period? period) {
    emit(UpdatingEvent());
    _events.remove(old);
    if (period != null) {
      newEvent.eventData!.slots = period.id;
    }

    log('removed${old.toMap}');
    _events.add(PlannerEvent(
        startTime: newEvent.startTime,
        endTime: newEvent.endTime,
        eventData: newEvent.eventData));
    emit(EventUpdatedState(
        _events, old, newEvent, viewType, periods, termModel));
    log('added${newEvent.toMap}');

    nativeCallBack.sendEventDraggedToNativeApp(old, newEvent, viewType, period);
    return true;
  }

  ///remove pld event and add new event
  bool updatePlannerEvent(
      PlannerEvent old, PlannerEvent newEvent, Period? period) {
    emit(UpdatingEvent());
    _events.remove(old);
    if (period != null) {
      newEvent.eventData!.slots = period.id;
    }

    log('removed${old.toMap}');
    _events.add(PlannerEvent(
        startTime: newEvent.startTime,
        endTime: newEvent.endTime,
        eventData: newEvent.eventData));
    emit(EventUpdatedState(
        _events, old, newEvent, viewType, periods, termModel));
    log('added${newEvent.toMap}');
    return true;
  }

  ///void save image as pdf

  Future<void> saveToPdf(Uint8List image) async {
    // final pw.Document pdf = pw.Document()
    //   ..addPage(pw.Page(
    //       build: (pw.Context context) =>
    //           pw.Image(pw.RawImage(bytes: image, width: 100, height: 100))));

    final Directory? path = await getDownloadsDirectory();
    try {
      // await FileSaver.instance
      //     .saveFile("example", image, "pdf", mimeType: MimeType.PDF);
      final File file = File('${path!.path}/example.png');
      await file.writeAsBytes(image);
    } on FileSystemException catch (e) {
      debugPrint(e.message);
    }
  }

  ///chang calendar view
  void changeViewType(CalendarViewType viewType) {
    this.viewType = viewType;
    nativeCallBack.sendViewChangedToNativeApp(viewType);
    jumpToToday();
    emit(ViewUpdated(events, viewType, periods, termModel));
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
}
