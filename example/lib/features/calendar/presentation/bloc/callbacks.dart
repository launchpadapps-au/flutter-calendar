import 'dart:async';
import 'dart:developer';

import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/date_change_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
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
      'date': dateTime.toString()
    };
    await sendToNativeApp(SendMethods.onTap, data);
    return true;
  }

  ///send addEvent callback to native app
  Future<bool> sendAddEventToNativeApp(
      DateTime dateTime, CalendarViewType viewType, Period? period) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'viewType': viewType.toString(),
      'date': dateTime.toString(),
    };
    if (period != null) {
      data.putIfAbsent('period', () => period.toJson().toString());
    }
    await sendToNativeApp(SendMethods.addEvent, data);
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
  Future<bool> sendEventDraggedToNativeApp(PlannerEvent old,
      PlannerEvent newEvent, CalendarViewType viewType) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'oldEvent': old.toJson(),
      'newEvent': newEvent.toJson(),
      'viewType': viewType.toString(),
    };
    await sendToNativeApp(SendMethods.eventDragged, data);
    return true;
  }

  ///send showEvent callback to native app
  Future<bool> sendShowEventToNativeApp(DateTime dateTime,
      List<CalendarEvent<EventData>> events, CalendarViewType viewType) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'viewType': viewType.toString(),
      'date': dateTime.toString(),
      'events': events.toString()
    };
    log(data.toString());
    await sendToNativeApp(SendMethods.showEvent, data);
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
