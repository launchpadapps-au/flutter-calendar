// To parse this JSON data, do
//
//     final loadingModel = loadingModelFromJson(jsonString);

import 'dart:convert';

///create model from json encoded string
LoadingModel loadingModelFromJson(String str) =>
    LoadingModel.fromJson(json.decode(str));

///convert to json encoded string from object
String loadingModelToJson(LoadingModel data) => json.encode(data.toJson());

///loading model for to show loading indicator in ui
class LoadingModel {
  ///initilize the model
  LoadingModel({
    required this.isLoading,
  });

  ///loading model from the json
  factory LoadingModel.fromJson(Map<String, dynamic> json) => LoadingModel(
        isLoading: json['isLoading'],
      );

  ///true if want to showloading indi
  bool isLoading;

  ///conver to json from the model
  Map<String, dynamic> toJson() => <String, dynamic>{
        'isLoading': isLoading,
      };
}
