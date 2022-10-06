// To parse this JSON data, do
//
//     final termModel = termModelFromJson(jsonString);

import 'dart:convert';

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

  ///term 1 date
  Term get term1Date => Term.fromString(term1);

  ///term 2 date
  Term get term2Date => Term.fromString(term2);

  ///term 3 date
  Term get term3Date => Term.fromString(term3);

  ///term 4 date
  Term get term4Date => Term.fromString(term4);

  ///convert to json object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'territory': territory,
        'term1': term1,
        'term2': term2,
        'term3': term3,
        'term4': term4,
      };
}

///Term class
class Term {
  ///initilized term
  Term({required this.startDate, required this.endDate});

  ///create term object from the String data
  factory Term.fromString(String data) {
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
        startDate: DateTime(now.year, startMonth, startDate),
        endDate: DateTime(now.year, endMonth, endDate));
  }

  ///start date of the term
  DateTime startDate;

  ///end date of the term
  DateTime endDate;
}
