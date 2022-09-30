// To parse this JSON data, do
//
//     final resizeModel = resizeModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

///get model from json encoded string
ResizeModel resizeModelFromJson(String str) =>
    ResizeModel.fromJson(json.decode(str));

///get json encoded string from model
String resizeModelToJson(ResizeModel data) => json.encode(data.toJson());

/// It's a model class for the data that is being passed to the widget
class ResizeModel {
  ///Initialize resize model
  ResizeModel({
    this.maxTime,
    this.minTime,
    this.top = 0,
    this.bottom = 0,
    this.hight = 0,
    this.isNextPeriodAvl = false,
    this.isPreviousPeriodAvl = false,
    this.maxDargOffset = 0,
    this.minDragOffset = 0,
  });

  ///convert from json
  factory ResizeModel.fromJson(Map<String, dynamic> json) => ResizeModel(
      top: json['top'],
      bottom: json['bottom'],
      hight: json['hight'],
      isNextPeriodAvl: json['isNextPeriodAvl'],
      isPreviousPeriodAvl: json['isPreviousPeriodAvl'],
      maxTime: json['maxTime'],
      minTime: json['minTime'],
      maxDargOffset: json['maxDargOffset'],
      minDragOffset: json['minDragOffset']);

  /// A model class for the data that is being passed to the widget.
  double top;

  ///bottom margin
  double bottom;

  ///total height
  double hight;

  ///true if  next period is available
  bool isNextPeriodAvl;

  ///true if previous period is available
  bool isPreviousPeriodAvl;

  ///max drag offset
  double maxDargOffset;

  ///min DragOffset
  double minDragOffset;

  ///max scroll Time
  TimeOfDay? maxTime;

  ///min scroll Time
  TimeOfDay? minTime;

  ///convert to json object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'top': top,
        'bottom': bottom,
        'hight': hight,
        'isNextPeriodAvl': isNextPeriodAvl,
        'isPreviousPeriodAvl': isPreviousPeriodAvl,
      };
}
