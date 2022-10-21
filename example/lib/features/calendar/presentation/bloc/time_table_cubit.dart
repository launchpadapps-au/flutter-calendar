import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/change_view_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/date_change_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/jump_to_date_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/loading_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/callbacks.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///timetable cubit
class TimeTableCubit extends Cubit<TimeTableState> {
  /// initialized timetable cubit
  TimeTableCubit() : super(InitialState()) {
    nativeCallBack.initializeChannel('com.example.demo/data');
    checkRunningStatus();

    setListener();
  }

  ///check for standalone

  Future<void> checkRunningStatus() async {
    try {
      await nativeCallBack.platform.invokeMethod<dynamic>('method');
    } on MissingPluginException {
      debugPrint('Project is running as app');
      standAlone = true;
      await getDummyData();
    }
  }

  ///true if running as standalone
  bool standAlone = false;

  ///current date time
  static DateTime now = DateTime.now();

  ///current date  for the calendar
  static DateTime currentDate = DateTime.now();

  ///get Current date
  DateTime get date => currentDate;

  ///start date of the timetable

  DateTime startDate = DateTime(now.year, now.month);

  ///end date of the timetable

  DateTime endDate =
      DateTime(now.year, now.month + 1).subtract(const Duration(days: 1));

  ///view of the calendar
  CalendarViewType viewType = CalendarViewType.weekView;

  ///list of the periods of the timetable
  List<PeriodModel> periods = customStaticPeriods;
  // List<PeriodModel> periods = dummyPeriods;

  ///this model hold the data related to terms of the s
  TermModel termModel = defaultTermModel;

  ///true if calendar is in loading mode
  bool isLoading = true;

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

  ///set listner for
  void setListener() {
    nativeCallBack.onDataReceived.stream.listen((MethodCall call) async {
      switch (call.method) {

        ///receive method name and data from native app and it handle / update
        ///data depends on the methodName
        case ReceiveMethods.sendToFlutter:
          debugPrint('id receive from ios app');
          await updateId(call.arguments);
          break;

        case ReceiveMethods.setLoading:
          debugPrint('setLoading received from native app');
          final LoadingModel loadingModel =
              loadingModelFromJson(jsonEncode(call.arguments));
          isLoading = loadingModel.isLoading;
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
          final JumpToDateModel jumpToDateModel =
              jumpToDateFromJson(jsonEncode(call.arguments));

          emit(JumpToDateState(jumpToDateModel.date));

          break;

        ///handle set periods method
        case ReceiveMethods.setPeriods:
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
          debugPrint('set events received from native app');
          final GetEvents getEvents = GetEvents.fromJsonWithPeriod(
              jsonDecode(jsonEncode(call.arguments)), periods);
          _events = getEvents.events;
          emit(EventsAdded(
              periods, _events, viewType, getEvents.events, termModel));
          break;

        ///handle addEvent method
        case ReceiveMethods.addEvent:
          debugPrint('add events received from native app');
          final GetEvents getEvents =
              GetEvents.fromJsonWithPeriod(jsonDecode(call.arguments), periods);
          _events.addAll(getEvents.events);
          emit(LoadedState(_events, viewType, periods, termModel));
          break;

        ///handle update event methods
        case ReceiveMethods.updateEvent:
          debugPrint('update events received from native app');
          final GetEvents getEvents =
              GetEvents.fromJsonWithPeriod(jsonDecode(call.arguments), periods);
          for (final PlannerEvent e in getEvents.events) {
            _events.removeWhere((PlannerEvent element) => element.id == e.id);
          }
          _events.addAll(getEvents.events);
          emit(EventsUpdated(
              periods, _events, viewType, getEvents.events, termModel));
          break;

        ///handle delete Event method
        case ReceiveMethods.removeEvent:
          debugPrint('delete events received from native app');

          final Map<String, dynamic> json =
              jsonDecode(jsonEncode(call.arguments));
          final String id = json['eventId'].toString();

          final List<PlannerEvent> events = _events
              .where((PlannerEvent element) =>
                  element.eventData!.id.toString() == id)
              .toList();
          for (final PlannerEvent element in events) {
            log('');
            _events.remove(element);
          }

          emit(DeletedEvents(periods, _events, viewType, events, termModel));
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
    nativeCallBack.sendDateChangeToNativeApp(first, end);
    emit(
        DateUpdated(endDate, startDate, _events, viewType, periods, termModel));
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

  ///currrent index of the of the terms
  int index = listOfTerm.indexOf(currentTerm);

  ///set terms for three year
  void setThreeYearTerm(TermModel termModel) {
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
    TermsUpdated(periods, events, viewType, termModel);
  }

  ///check for term when date changed and and ask for fetch datat
  void getDataDateWise(DateTime dateTime) {
    final Term next = listOfTerm[index + 1];
    final Term pre = listOfTerm[index - 1];

    if (isSameDate(dateTime, ref: next.startDate)) {
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
      emit(TermsUpdated(periods, events, viewType, termModel));
    } else if (isSameDate(dateTime, ref: pre.endDate)) {
      nativeCallBack.sendFetchDataToNativeApp(pre);
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
      emit(TermsUpdated(periods, events, viewType, termModel));
    }
  }

  ///set current date
  void setDate(DateTime date) {
    currentDate = date;
    getDataDateWise(currentDate);
    emit(CurrrentDateUpdated(currentDate: currentDate));
  }

  ///setCurrent Month
  void setMonth(DateTime startDate, DateTime endDate) {
    currentDate=startDate;
    emit(
        MonthUpdated(periods, events, viewType, termModel, startDate, endDate));
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
      newEvent.eventData!.period = period;
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
      newEvent.eventData!.period = period;
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
      newEvent.eventData!.period = period;
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

  ///save time table as image
  Future<void> saveTomImage(Uint8List image, {String? filename}) async {
    final Directory? path = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : Platform.isIOS
            ? await getApplicationSupportDirectory()
            : await getDownloadsDirectory(); //FOR iOS
    final String fileName =
        '${path!.path}/${viewType.name}-${filename ?? DateTime.now().toString()}';
    final File file = File('$fileName.png');
    await file.writeAsBytes(image);
    log('image Path:${file.path}');
    return;
  }

  ///chang calendar view
  void changeViewType(CalendarViewType viewType) {
    this.viewType = viewType;
    nativeCallBack.sendViewChangedToNativeApp(viewType);
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
