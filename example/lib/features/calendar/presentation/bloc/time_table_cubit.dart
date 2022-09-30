import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/change_view_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/date_change_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_periods_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/callbacks.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///timetable cubit
class TimeTableCubit extends Cubit<TimeTableState> {
  /// initialized timetable cubit
  TimeTableCubit() : super(InitialState()) {
    nativeCallBack.initializeChannel('com.example.demo/data');
    getDummyEvents();
    setListener();
  }

  ///current date time
  static DateTime now = DateTime.now();

  ///start date of the timetable

  DateTime startDate = DateTime(now.year, now.month);

  ///end date of the timetable

  DateTime endDate =
      DateTime(now.year, now.month + 1).subtract(const Duration(days: 1));

  ///view of the calendar
  CalendarViewType viewType = CalendarViewType.dayView;

  ///list of the periods of the timetable
  List<Period> periods = customStaticPeriods;

  /// set method handler to receive data from flutter
  static const MethodChannel platform = MethodChannel('com.example.demo/data');

  ///object of the native callback class
  NativeCallBack nativeCallBack = NativeCallBack();

  ///code related to native callback and data listener

  void setListener() {
    nativeCallBack.onDataReceived.stream.listen((MethodCall call) async {
      switch (call.method) {

        ///receive method name and data from native app and it handle / update
        ///data depends on the methodName
        case ReceiveMethods.sendToFlutter:
          debugPrint('id receive from ios app');
          await updateId(call.arguments);
          break;

        ///receive data change command from ios
        ///handle data change
        case ReceiveMethods.setDates:
          debugPrint('date receive from flutter');
          final DateChange dateChange =
              DateChange.fromJson(jsonDecode(call.arguments));
          startDate = dateChange.startTime;
          endDate = dateChange.endTime;
          emit(DateUpdated(endDate, startDate, _events, viewType, periods));
          break;

        ///handle view change
        case ReceiveMethods.setView:
          debugPrint('set view received from native app');
          final ChangeView changeView =
              ChangeView.fromJson(jsonDecode(call.arguments));
          changeViewType(changeView.viewType);
          break;

        ///handle set periods method
        case ReceiveMethods.setPeriods:
          debugPrint('set periods received from native app');
          final GetPeriods changePeriods =
              GetPeriods.fromJson(jsonDecode(call.arguments));
          periods = changePeriods.periods;
          emit(PeriodsUpdated(periods, _events, viewType));
          break;

        ///handle setEvents methods
        case ReceiveMethods.setEvents:
          debugPrint('set events received from native app');
          final GetEvents getEvents =
              GetEvents.fromJson(jsonDecode(call.arguments));

          _events = getEvents.events;
          emit(EventsAdded(periods, _events, viewType, getEvents.events));
          break;

        ///handle addEvent method
        case ReceiveMethods.addEvent:
          debugPrint('add events received from native app');
          final GetEvents getEvents =
              GetEvents.fromJson(jsonDecode(call.arguments));

          _events.addAll(getEvents.events);
          emit(LoadedState(_events, viewType, periods));
          break;

        ///handle update event methods
        case ReceiveMethods.updateEvent:
          debugPrint('update events received from native app');
          final GetEvents getEvents =
              GetEvents.fromJson(jsonDecode(call.arguments));
          for (final PlannerEvent e in getEvents.events) {
            _events.removeWhere((PlannerEvent element) => element.id == e.id);
          }
          _events.addAll(getEvents.events);
          emit(EventsUpdated(periods, _events, viewType, getEvents.events));
          break;

        ///handle delete Event method
        case ReceiveMethods.deleteEvent:
          debugPrint('delete events received from native app');
          final GetEvents getEvents =
              GetEvents.fromJson(jsonDecode(call.arguments));
          for (final PlannerEvent e in getEvents.events) {
            _events.removeWhere((PlannerEvent element) => element.id == e.id);
          }

          emit(DeletedEvents(periods, _events, viewType, getEvents.events));
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
    emit(DateUpdated(endDate, startDate, _events, viewType, periods));
    return true;
  }

  ///update id of the user
  Future<void> updateId(dynamic data) async {
    final Map<String, dynamic> jData = await jsonDecode(data);

    id = jData['id'].toString();
    emit(LoadedState(_events, viewType, periods));
  }

  ///get dummy events
  Future<void> getDummyEvents() async {
    try {
      emit(LoadingState());
      await Future<dynamic>.delayed(const Duration(seconds: 3));
      _events = dummyEventData;

      emit(LoadedState(_events, viewType, periods));
    } on Exception catch (e) {
      debugPrint(e.toString());
      emit(ErrorState());
    }
  }

  ///call this function to add events
  Future<void> addEvent(PlannerEvent value) async {
    emit(AddingEvent());

    await Future<dynamic>.delayed(const Duration(seconds: 2));

    if (state is LoadedState) {}
    _events.add(value);
    emit(LoadedState(_events, viewType, periods));
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
    emit(LoadedState(_events, viewType, periods));
    log('added${newEvent.toMap}');
    return true;
  }

  ///void save image as psd

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
    emit(ViewUpdated(events, viewType, periods));
  }

  ///this function changed
  void jumpToCurrentDate() {
    final DateTime now = DateTime.now();

    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      emit(ChangeToCurrentDate(periods, events, viewType, <PlannerEvent>[]));
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
      emit(ChangeToCurrentDate(periods, events, viewType, <PlannerEvent>[],
          isDateChanged: true, isViewChanged: isViewChanged));
    }
  }
}
