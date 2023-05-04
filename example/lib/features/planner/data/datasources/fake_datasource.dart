import 'dart:convert';

import 'package:edgar_planner_calendar_flutter/core/static.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/assets_path.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/term_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///fake datasource the app
class FakeDataSource {
  ///return list of period from the json
  static Future<List<PeriodModel>> getPeriods() async =>
      periodModelFromJson(await rootBundle.loadString(AssetPath.periodJson));

  ///return events
  static Future<List<PlannerEvent>> getEvents(List<PeriodModel> periods) async {
    final String response = await rootBundle.loadString(AssetPath.eventJson);
    final dynamic data = jsonDecode(response);
    final GetEvents getEvents = GetEvents.fromJsonWithPeriod(data, periods);
    return getEvents.events;
  }

  ///return notes
  static Future<List<CalendarEvent<Note>>> getNotes() async =>
      GetNotes.fromRawJson(await rootBundle.loadString(AssetPath.noteJson))
          .note;

  ///return default term model
  static TermModel termModel = termFromJson;

  ///return terms
  static Terms get terms => termModel.terms;
}
