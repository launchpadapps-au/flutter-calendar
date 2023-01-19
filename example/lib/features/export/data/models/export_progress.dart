///export progess model
class ExportProgress {
  ///initilize the model
  ExportProgress(
      {required this.status,
      required this.progress,
      this.message = '',
      this.path = const <String>[]});

  ///create object from json

  factory ExportProgress.fromJson(Map<String, dynamic> json) => ExportProgress(
        status: typeValues.map[json['status']]!,
        progress: json['progress'],
        message: json['message'],
      );

  ///status of the progress
  final ExportStatus status;

  ///percentage of the progress
  final double progress;

  ///extra message for the progress
  final String message;

  ///List of path for the exported images and the pdf
  final List<String> path;

  ///create json from the object
  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': typeValues.reverse![status],
        'progress': progress,
        'message': message,
        'path': List<dynamic>.from(path.map<String>((String x) => x))
      };
}

///type of the note
enum ExportStatus {
  ///This type will only display note in the month and term view
  started,

  ///when in progress
  inProgress,

  ///when done
  done
}

///retunr enum based oon map
final EnumValues<ExportStatus> typeValues =
    EnumValues<ExportStatus>(<String, ExportStatus>{
  'started': ExportStatus.started,
  'inProgress': ExportStatus.inProgress,
  'done': ExportStatus.done
});

///hold enum value
class EnumValues<ExportStatus> {
  ///initilize enum value
  EnumValues(this.map);

  ///map of the status
  Map<String, ExportStatus> map;

  ///reverse map of the status
  Map<ExportStatus, String>? reverseMap;

  ///return revers map
  Map<ExportStatus, String>? get reverse => reverseMap ??= map
      .map((String k, ExportStatus v) => MapEntry<ExportStatus, String>(v, k));
}
