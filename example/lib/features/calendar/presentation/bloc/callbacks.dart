import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/core/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/date_change_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/method_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///this class contains all method related to callBack
class NativeCallBack {
  ///initialized the class
  NativeCallBack() {
    log('Call back initialized');
  }

  /// set method handler to receive data from flutter
  late MethodChannel platform;

  ///initialize the channel
  void initializeChannel(String channelName) {
    platform = MethodChannel(channelName);
    platform.setMethodCallHandler((MethodCall call) async {
      onDataReceived.add(call);
    });
  }

  ///function called when we receive data from native app

  StreamController<MethodCall> onDataReceived = StreamController<MethodCall>();

  ///send onTap callback to native app
  Future<bool> onTap(DateTime dateTime, List<PlannerEvent> events) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'events': events.toString(),
      'date': dateTime.toString().substring(0, 10),
    };
    await sendToNativeApp(SendMethods.onTap, data);
    return true;
  }

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
    debugPrint('data: $data');
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
    log(periodModel.toString());
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
    debugPrint('Data: $data');
    await sendToNativeApp(SendMethods.eventDragged, data);
    return true;
  }

  ///send visible date changed to native app
  Future<bool> sendVisibleDateChnged(DateTime dateTime) async {
    log(dateTime.toString().substring(0, 10));
    await sendToNativeApp(SendMethods.visibleDateChanged,
        <String, String>{'date': dateTime.toString().substring(0, 10)});
    return true;
  }

  ///send showEvent callback to native app
  Future<bool> sendShowEventToNativeApp(DateTime dateTime,
      List<CalendarEvent<EventData>> events, CalendarViewType viewType) async {
    if (events.length == 1) {
      if (isOnTapEnable(events.first)) {
        final int eventID = int.parse(events.first.eventData!.id.toString());
        final Map<String, dynamic> data = <String, dynamic>{
          'viewType': viewType.toString(),
          'date': dateTime.toString().substring(0, 10),
          'events': events.toString(),
          'eventId': eventID,
          'eventIds': List<String>.from(events.map<String>(
              (CalendarEvent<EventData> e) => e.eventData!.id.toString()))
        };
        log(data.toString());
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
      log(data.toString());
      await sendToNativeApp(SendMethods.showEvent, data);
    }

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

  ///send showRecord callback to native app
  Future<bool> sendShowRecordToNativeApp() async {
    final Map<String, dynamic> data = <String, dynamic>{
      'message': 'Show records',
    };
    log(data.toString());
    await sendToNativeApp(SendMethods.showRecord, data);
    return true;
  }

  ///send data to native app
  Future<bool> sendToNativeApp(String methodName, dynamic data) {
    platform
        .invokeMethod<dynamic>(
      methodName,
      data,
    )
        .then((dynamic value) {
      debugPrint('MethodName: $methodName');
      debugPrint('Data: $data');
    });

    return Future<bool>.value(true);
  }
}
