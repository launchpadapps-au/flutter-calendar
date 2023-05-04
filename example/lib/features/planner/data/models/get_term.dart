// To parse this JSON data, do
//
//     final getTerm = getTermFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

///create term model from the data
class GetTerm {
  ///initialize the term object
  GetTerm({
    required this.term,
    required this.id,
  });

  ///create object from the json
  factory GetTerm.fromJson(Map<String, dynamic> json) => GetTerm(
        term: Terms.fromJson(json['term']),
        id: json['id'],
      );

////create object from the json encoded string
  factory GetTerm.fromRawJson(String str) => GetTerm.fromJson(json.decode(str));

  ///object of the [Terms]
  final Terms term;

  ///id of the user
  final String id;

  ///create another object from
  GetTerm copyWith({
    Terms? term,
    String? id,
  }) =>
      GetTerm(
        term: term ?? this.term,
        id: id ?? this.id,
      );

  ///create json encoded string from the object
  String toRawJson() => json.encode(toJson());

  ///create json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'term': term.toJson(),
        'id': id,
      };
}

///hold terms details
class Terms {
  ///initialize the terms
  Terms({
    required this.id,
    required this.territory,
    required this.term1,
    required this.term2,
    required this.term3,
    required this.term4,
  });

  ///create term from the json
  factory Terms.fromJson(Map<String, dynamic> json) => Terms(
        id: json['id'],
        territory: json['territory'],
        term1: fromSpecialString(json['term1']),
        term2: fromSpecialString(json['term1']),
        term3: fromSpecialString(json['term1']),
        term4: fromSpecialString(json['term1']),
      );

  ///create object from the json encoded string
  factory Terms.fromRawJson(String str) => Terms.fromJson(json.decode(str));

  ///id of the date
  final int id;

  ///territory of the user
  final String territory;

  /// [DateTimeRange] of first Tirm
  final DateTimeRange term1;

  /// [DateTimeRange] of second Tirm
  final DateTimeRange term2;

  /// [DateTimeRange] of third Tirm
  final DateTimeRange term3;

  /// [DateTimeRange] of firfourthst Tirm
  final DateTimeRange term4;

  ///create another object fron object
  Terms copyWith({
    int? id,
    String? territory,
    DateTimeRange? term1,
    DateTimeRange? term2,
    DateTimeRange? term3,
    DateTimeRange? term4,
  }) =>
      Terms(
        id: id ?? this.id,
        territory: territory ?? this.territory,
        term1: term1 ?? this.term1,
        term2: term2 ?? this.term2,
        term3: term3 ?? this.term3,
        term4: term4 ?? this.term4,
      );

  ///create json encoded string from the object
  String toRawJson() => json.encode(toJson());

  ///crate json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'territory': territory,
        'term1': term1,
        'term2': term2,
        'term3': term3,
        'term4': term4,
      };
}

///create term object from the String data
DateTimeRange fromSpecialString(String data, {int? year, String? type}) {
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

  return DateTimeRange(
      start: DateTime(year ?? now.year, startMonth, startDate),
      end: DateTime(year ?? now.year, endMonth, endDate));
}
