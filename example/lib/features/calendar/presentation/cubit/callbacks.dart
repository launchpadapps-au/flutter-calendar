import 'dart:async';
import 'dart:convert';

import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/date_change_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/mock_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///this class contains all method related to callBack
class NativeCallBack {
  ///initialized the class
  NativeCallBack({this.mockMethod});

  /// set method handler to receive data from flutter
  late MethodChannel platform;

  ///provide mock object if wanted to mock
  MockMethod? mockMethod;

  ///initialize the channel
  void initializeChannel(String channelName) {
    platform = MethodChannel(channelName);
    platform.setMethodCallHandler((MethodCall call) async {
      onDataReceived.add(call);
      logInfo('Call back initialized');
    });
  }

  ///function called when we receive data from native app

  StreamController<MethodCall> onDataReceived = StreamController<MethodCall>();

  ///send addEvent callback to native app
  Future<bool> sendAddEventToNativeApp(
      DateTime dateTime, CalendarViewType viewType, Period? period,
      {bool jsonEcoded = false}) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'viewType': viewType.toString(),
      'date': dateTime.toString().substring(0, 10),
    };
    if (period != null) {
      data
        ..putIfAbsent('period', () => period.toJson())
        ..putIfAbsent('slotId', () => period.id.toString());
    }
    logInfo('data: $data');
    if (jsonEcoded) {
      final String string = jsonEncode(data);
      await sendToNativeApp(SendMethods.addEvent, string);
    } else {
      await sendToNativeApp(SendMethods.addEvent, data);
    }
    return true;
  }

  ///send dateChanged to native app

  Future<bool> sendDateChangeToNativeApp(
      DateTime startTime, DateTime endTime) async {
    final DateChange dateChange =
        DateChange(startTime: startTime, endTime: endTime);
    await sendToNativeApp(SendMethods.dateChanged, dateChange.toJson());
    return true;
  }

  ///send viewChanged to native app
  Future<bool> sendViewChangedToNativeApp(
      CalendarViewType calendarViewType) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'viewType': calendarViewType.name
    };
    await sendToNativeApp(SendMethods.viewChanged, data);
    return true;
  }

  ///send eventDragged  to native app
  Future<bool> sendEventDraggedToNativeApp(
      CalendarEvent<EventData> old,
      CalendarEvent<EventData> newEvent,
      CalendarViewType viewType,
      Period? periodModel) async {
    final Period? period = periodModel;

    final String sid = period == null ? newEvent.eventData!.slots : period.id;
    logInfo(periodModel.toString());
    final int id = int.parse(sid);
    final int eventId = int.parse(newEvent.eventData!.id);
    bool isRec = false;
    if (newEvent.eventData!.event != null) {
      isRec = newEvent.eventData!.event!.isRecurringEvent;
    }

    final Map<String, dynamic> data = <String, dynamic>{
      'start_date': newEvent.startTime.toString().substring(0, 10),
      'end_date': newEvent.startTime.toString().substring(0, 10),
      'start_time': newEvent.startTime.toString().substring(11, 19),
      'end_time': newEvent.endTime.toString().substring(11, 19),
      'eventId': eventId,
      'is_recurring_event': isRec,
      'reminder_start_time': DateTime(
              2022, 10, 19, newEvent.startTime.hour, newEvent.startTime.minute)
          .toUtc()
          .toIso8601String()
    }..putIfAbsent('slotId', () => id);
    logInfo('Data: $data');
    await sendToNativeApp(SendMethods.eventDragged, data);
    return true;
  }

  ///send visible date changed to native app
  Future<bool> sendVisibleDateChnged(DateTime dateTime) async {
    logInfo(dateTime.toString().substring(0, 10));
    await sendToNativeApp(SendMethods.visibleDateChanged,
        <String, String>{'date': dateTime.toString().substring(0, 10)});
    return true;
  }

  ///send showEvent callback to native app
  Future<bool> sendShowEventToNativeApp(DateTime dateTime,
      List<CalendarEvent<EventData>> events, CalendarViewType viewType) async {
    if (events.length == 1) {
      if (CalendarUtils.isOnTapEnable(events.first)) {
        final int eventID = int.parse(events.first.eventData!.id.toString());
        final Map<String, dynamic> data = <String, dynamic>{
          'viewType': viewType.toString(),
          'date': dateTime.toString().substring(0, 10),
          'events': events.toString(),
          'eventId': eventID,
          'eventIds': List<String>.from(events.map<String>(
              (CalendarEvent<EventData> e) => e.eventData!.id.toString()))
        };
        logInfo(data.toString());
        await sendToNativeApp(SendMethods.showEvent, data);
      }
    } else {
      final Map<String, dynamic> data = <String, dynamic>{
        'viewType': viewType.toString(),
        'date': dateTime.toString().substring(0, 10),
        'events': events.toString(),
        'eventId': events.first.eventData!.id.toString(),
        'eventIds': List<String>.from(events.map<String>(
            (CalendarEvent<EventData> e) => e.eventData!.id.toString()))
      };
      logInfo(data.toString());
      await sendToNativeApp(SendMethods.showEvent, data);
    }

    return true;
  }

  ///send showDuty callback to native app
  Future<bool> sendShowDutyToNativeApp(
      DateTime dateTime,
      List<CalendarEvent<EventData>> events,
      CalendarViewType viewType,
      PeriodModel periodModel) async {
    if (events.length == 1) {
      if (CalendarUtils.isOnTapEnable(events.first)) {
        final int eventID = int.parse(events.first.eventData!.id.toString());
        final CalendarEvent<EventData> event = events.first;
        final Map<String, dynamic> data = <String, dynamic>{
          'viewType': viewType.toString(),
          'date': dateTime.toString().substring(0, 10),
          'events': events.toString(),
          'eventId': eventID,
          'location': events.first.eventData!.location,
          'startTime': event.eventData!.startTime,
          'endTime': event.eventData!.endTime,
          'breakTitle': periodModel.title
        };
        logInfo(data.toString());
        await sendToNativeApp(SendMethods.showDuty, data);
      }
    } else {
      final Map<String, dynamic> data = <String, dynamic>{
        'viewType': viewType.toString(),
        'date': dateTime.toString().substring(0, 10),
        'events': events.toString(),
        'eventId': events.first.eventData!.id.toString(),
        'eventIds': List<String>.from(events.map<String>(
            (CalendarEvent<EventData> e) => e.eventData!.id.toString())),
      };
      logInfo(data.toString());
      await sendToNativeApp(SendMethods.showDuty, data);
    }

    return true;
  }

  ///it will send showNonTrachingTime to native app using platform channerl
  Future<bool> senShowdNonTeachingTimeToNativeAoo(
      CalendarEvent<EventData> event,
      DateTime dateTime,
      CalendarViewType viewType) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'viewType': viewType.toString(),
      'date': dateTime.toString().substring(0, 10),
      'eventId': event.eventData!.id.toString(),
      'startTime': event.eventData!.startTime,
      'endTime': event.eventData!.endTime,
      'slotName': event.eventData!.calendarSlot.getTitle,
      'description': event.eventData!.description,
    };
    logInfo(data);
    await sendToNativeApp(SendMethods.showNonTeachingTime, data);
    return true;
  }

  ///ask native app to fetch more data between speceffic date

  Future<bool> sendFetchDataToNativeApp(Term term) async {
    final Map<String, String> data = <String, String>{
      'startDate': term.startDate.toString().substring(0, 10),
      'endDate': term.endDate.toString().substring(0, 10)
    };
    await sendToNativeApp(SendMethods.fetchData, data);
    return true;
  }

  ///ask native app to fetch more data between speceffic date

  Future<bool> sendFetchDataDatesToNativeApp(
      DateTime startDate, DateTime endDate) async {
    final Map<String, String> data = <String, String>{
      'startDate': startDate.toString().substring(0, 10),
      'endDate': endDate.toString().substring(0, 10)
    };
    await sendToNativeApp(SendMethods.fetchData, data);
    return true;
  }

  ///open url in web
  Future<bool> openUrl(String url) async {
    await sendToNativeApp(SendMethods.openUrl, url);
    return true;
  }

  ///send showRecord callback to native app
  Future<bool> sendShowRecordToNativeApp() async {
    final Map<String, dynamic> data = <String, dynamic>{
      'message': 'Show records',
    };
    logInfo(data.toString());
    await sendToNativeApp(SendMethods.showRecord, data);
    return true;
  }

  ///send openDrive callback to native app
  Future<bool> sendOpenDriveToNativeApp() async {
    final Map<String, dynamic> data = <String, dynamic>{
      'message': 'Open Google Drive',
    };
    logInfo(data.toString());
    await sendToNativeApp(SendMethods.openDrive, data);
    return true;
  }

  ///send showRecord callback to native app
  Future<bool> sendShowTodos() async {
    final Map<String, dynamic> data = <String, dynamic>{};

    await sendToNativeApp(SendMethods.showTodos, data);
    return true;
  }

  ////---------Callbacks for the Notes--------------///
  ///sned AddNote method callabck to ios
  Future<bool> sendAddNote(DateTime dateTime, CalendarViewType viewType) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'viewType': viewType.toString(),
      'date': dateTime.toString().substring(0, 12)
    };
    await sendToNativeApp(SendMethods.addNote, data);
    return true;
  }

  ///sned showNote method callabck to ios
  Future<bool> sendShowNote(Note note, CalendarViewType viewType) async {
    final Map<String, dynamic> data = note.toJson()
      ..putIfAbsent('viewType', () => viewType.toString());
    await sendToNativeApp(SendMethods.showNote, data);
    return true;
  }

  ///send data to native app
  Future<bool> sendToNativeApp(String methodName, dynamic data) {
    if (mockMethod != null) {
      mockMethod!.invokeMethod(methodName, data);
    } else {
      platform
          .invokeMethod<dynamic>(
        methodName,
        data,
      )
          .then((dynamic value) {
        logInfo('MethodName: $methodName');
      });
    }

    return Future<bool>.value(true);
  }
}
