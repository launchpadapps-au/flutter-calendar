// To parse this JSON data, do
//
//     final termModel = termModelFromJson(jsonString);

import 'dart:convert';

import 'package:edgar_planner_calendar_flutter/core/extension/date_extension.dart';
import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:flutter/material.dart';

///convert to term model from the json encoded string
TermModel termModelFromJson(String str) => TermModel.fromJson(json.decode(str));

///convert to json encoded string from the model data
String termModelToJson(TermModel data) => json.encode(data.toJson());

///term model which hold data from the api
class TermModel {
  ///initilize the model
  TermModel({
    required this.terms,
    required this.id,
  });

  ///create object from the json
  factory TermModel.fromJson(Map<String, dynamic> json) => TermModel(
        terms: Terms.fromJson(json['term']),
        id: json['id'],
      );

  ///Terms of the table
  Terms terms;

  ///id of the terms
  dynamic id;

  ///convert to json object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'term': terms.toJson(),
        'id': id,
      };
}

///Term class which hold list of all terms
class Terms {
  ///initililized terms
  Terms({
    required this.id,
    required this.territory,
    required this.term1,
    required this.term2,
    required this.term3,
    required this.term4,
  });

  ///convewrt object from the json
  factory Terms.fromJson(Map<String, dynamic> json) => Terms(
        id: json['id'],
        territory: json['territory'],
        term1: json['term1'],
        term2: json['term2'],
        term3: json['term3'],
        term4: json['term4'],
      );

  ///id of objecy
  dynamic id;

  ///territory of the school
  String territory;

  ///term 1 date
  String term1;

  ///term 2 date
  String term2;

  ///term 3 date
  String term3;

  ///term 4 date
  String term4;

  ///year of the term model
  int year = DateTime.now().year;

  ///previos term
  Term get previosTerm => Term.fromString(term4, year: year - 1, type: 'term4');

  ///term 1 date
  Term get term1Date => Term.fromString(term1, year: year, type: 'term1');

  ///term 2 date
  Term get term2Date => Term.fromString(term2, year: year, type: 'term2');

  ///term 3 date
  Term get term3Date => Term.fromString(term3, year: year, type: 'term3');

  ///term 4 date
  Term get term4Date => Term.fromString(term4, year: year, type: 'term4');

  ///previos term
  Term get nextTerm => Term.fromString(term1, year: year + 1, type: 'term1');

  ///return terms
  List<Term> terms() => <Term>[term1Date, term2Date, term3Date, term4Date];

  ///return terms
  List<Term> allTern() =>
      <Term>[previosTerm, term1Date, term2Date, term3Date, term4Date, nextTerm];

  ///convert to json object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'territory': territory,
        'term1': term1,
        'term2': term2,
        'term3': term3,
        'term4': term4,
      };

  ///return list of buffer time
  List<DateTimeRange> bufferTime() {
    final Term term1 = term1Date;
    final Term term2 = term2Date;
    final Term term3 = term3Date;
    final Term term4 = term4Date;
    final DateTimeRange dateRange1 = DateTimeRange(
        start: DateTime(year),
        end: term1.startDate.subtract(const Duration(days: 1)));
    final DateTimeRange dateRange2 = DateTimeRange(
        start: term1.endDate.add(const Duration(days: 1)),
        end: term2.startDate.subtract(const Duration(days: 1)));
    final DateTimeRange dateRange3 = DateTimeRange(
        start: term2.endDate.add(const Duration(days: 1)),
        end: term3.startDate.subtract(const Duration(days: 1)));
    final DateTimeRange dateRange4 = DateTimeRange(
        start: term3.endDate.add(const Duration(days: 1)),
        end: term4.startDate.subtract(const Duration(days: 1)));
    final DateTimeRange dateRange5 = DateTimeRange(
        start: term4.endDate.add(const Duration(days: 1)),
        end: DateTime(year, 12, 31));

    return <DateTimeRange>[
      dateRange1,
      dateRange2,
      dateRange3,
      dateRange4,
      dateRange5
    ];
  }

  ///return true if date is bn buffer time
  bool isInBufferTime(DateTime date) {
    bool inBuffer = false;

    if (date.year < year && date.year > year) {
      logInfo('Given date is not in year');
    } else {
      for (final DateTimeRange buffer in bufferTime()) {
        if (buffer.isInBetWeen(date)) {
          inBuffer = true;
          break;
        }
      }
    }

    return inBuffer;
  }

  ///retunr biffer index for given date
  int? bufferIndex(DateTime date) {
    int? bufferIndex;
    final List<DateTimeRange> buffers = bufferTime();

    if (date.year < year) {
      return -1;
    } else if (date.year > year) {
      return 5;
    } else {
      for (final DateTimeRange buffer in buffers) {
        if (buffer.isInBetWeen(date)) {
          bufferIndex = buffers.indexOf(buffer);
          break;
        }
      }
    }

    return bufferIndex;
  }
}

///Term class
class Term {
  ///initilized term
  Term({
    required this.startDate,
    required this.endDate,
    this.type,
  });

  ///create term object from the String data
  factory Term.fromString(String data, {int? year, String? type}) {
    final DateTime now = DateTime.now();
    final List<String> objects = data.split('|').toList();
    final String first = objects.first;
    final String last = objects.last;
    final List<String> dateObject = first.split('-');
    final int startMonth = int.parse(dateObject.last);
    final int startDate = int.parse(dateObject.first);
    final List<String> enddateObject = last.split('-');
    final int endMonth = int.parse(enddateObject.last);
    final int endDate = int.parse(enddateObject.first);

    return Term(
        type: type ?? data,
        startDate: DateTime(year ?? now.year, startMonth, startDate),
        endDate: DateTime(year ?? now.year, endMonth, endDate));
  }

  ///return true if given date is in the term
  bool isBeetWeen(DateTime dateTime) =>
      dateTime.isAferORSame(startDate) && dateTime.isBeforeORSame(endDate);

  ///start date of the term
  DateTime startDate;

  ///type of the term
  String? type = '';

  ///end date of the term
  DateTime endDate;
  @override
  String toString() => <String, String>{
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
        'type': type ?? ''
      }.toString();
}
