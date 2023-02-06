// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_progress.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/fileutils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/pdf_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/dummy_subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:pdf/pdf.dart';

///This page show list of view and datarange for export
class ExportSettingView extends StatefulWidget {
  ///intilize the widget
  const ExportSettingView({super.key});

  @override
  State<ExportSettingView> createState() => _ExportSettingViewState();
}

class _ExportSettingViewState extends State<ExportSettingView> {
  List<CalendarViewType> types = <CalendarViewType>[
    CalendarViewType.dayView,
    CalendarViewType.weekView,
    CalendarViewType.monthView
  ];
  CalendarViewType? currentView = CalendarViewType.weekView;

  DateTime start = DateTime(2023);
  DateTime end = DateTime(2023, 1, 31);
  bool saveImg = false;
  bool fullWeek = true;
  dynamic selectedSubject;
  late ExportProgress exportProgres;

  StreamController<ExportProgress> streamController =
      StreamController<ExportProgress>.broadcast();
  void sendData(dynamic data, BuildContext context) {
    TimeTableCubit.mockObject
        .invokeMethod(ReceiveMethods.generatePreview, jsonEncode(data));
  }

  void listenMockStream(BuildContext context) {
    TimeTableCubit.mockObject.stream.listen((MethodCall event) {
      switch (event.method) {
        case SendMethods.previewProgress:
          exportProgres = ExportProgress.fromJson(event.arguments);
          streamController.sink.add(exportProgres);
          logInfo(exportProgres.toJson().toString());
          switch (exportProgres.status) {
            case ExportStatus.started:
              _showAlertDialog(context);

              break;
            case ExportStatus.inProgress:
              break;
            case ExportStatus.done:
              break;
          }

          break;
        case SendMethods.downloadProgress:
          exportProgres = ExportProgress.fromJson(event.arguments);
          streamController.sink.add(exportProgres);
          logInfo(exportProgres.toJson().toString());
          switch (exportProgres.status) {
            case ExportStatus.started:
              _showAlertDialog(context, isDownloading: true);

              break;
            case ExportStatus.inProgress:
              break;
            case ExportStatus.done:
              break;
          }
      }
    });
  }

// This shows a CupertinoModalPopup which hosts a CupertinoAlertDialog.
  void _showAlertDialog(BuildContext context, {bool isDownloading = false}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              StreamBuilder<ExportProgress>(
                  stream: streamController.stream,
                  builder: (BuildContext context,
                          AsyncSnapshot<ExportProgress> snapshot) =>
                      CupertinoAlertDialog(
                        title: Text(isDownloading
                            ? 'Downloadind PDF'
                            : 'Genetating Preview'),
                        content: exportProgres.status == ExportStatus.done
                            ? Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Icon(
                                    Icons.download_done_rounded,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(!isDownloading
                                      ? 'Pdf preview generated.'
                                      : 'Pdf downloade.'),
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(getTitle(
                                      isDownloading: isDownloading,
                                      exportProgres: exportProgres)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  LinearProgressIndicator(
                                    value: exportProgres.progress,
                                  ),
                                ],
                              ),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Ok'),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancle'),
                          ),
                        ],
                      ))),
    );
  }

  @override
  void initState() {
    listenMockStream(context);
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Export view')),
      body: Row(children: <Widget>[
        SizedBox(
          width: size.width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    showDateRangePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDateRange:
                                DateTimeRange(start: start, end: end),
                            lastDate: DateTime(2100))
                        .then((DateTimeRange? value) {
                      start = value!.start;
                      end = value.end;
                      setState(() {});
                    });
                  },
                  child: Text('Start: ${start.toString().substring(0, 12)} '
                      'End: ${end.toString().substring(0, 12)}'),
                ),
                DropdownButton<CalendarViewType>(
                  value: currentView,
                  hint: const Text('Select View'),
                  items: types
                      .map((CalendarViewType e) =>
                          DropdownMenuItem<CalendarViewType>(
                            value: e,
                            child: Text(e.toString()),
                          ))
                      .toList(),
                  onChanged: (CalendarViewType? value) {
                    currentView = value;
                    setState(() {});
                  },
                ),
                DropdownButton<dynamic>(
                  value: selectedSubject,
                  isExpanded: true,
                  hint: const Text('Select Subjects'),
                  items: dummySubject
                      .map((dynamic e) => DropdownMenuItem<dynamic>(
                            value: e,
                            child: ListTile(
                                leading: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: HexColor(
                                        e['color_code'],
                                      )),
                                ),
                                title: Text(e['subject_name'])),
                          ))
                      .toList(),
                  onChanged: (dynamic value) {
                    selectedSubject = value;
                    setState(() {});
                  },
                ),
                SwitchListTile.adaptive(
                    value: fullWeek,
                    title: const Text('Full Week'),
                    onChanged: (bool value) {
                      fullWeek = value;
                      setState(() {});
                    }),
                Wrap(
                  runSpacing: 20,
                  spacing: 20,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        await PdfUtils.saveDemo(PdfPageFormat.a4, 'demo');
                      },
                      child: const Text('Save Demo'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final String id =
                            Subject.fromJson(selectedSubject).id.toString();
                        final String subjectName =
                            Subject.fromJson(selectedSubject)
                                .subjectName
                                .toString();
                        FileUtils.getPath().then((Directory? path) {
                          final Map<String, dynamic> data = <String, dynamic>{
                            'startDate': start.toIso8601String(),
                            'endDate': end.toIso8601String(),
                            'view': currentView.toString(),
                            'subjectId': id,
                            'subjectName': subjectName,
                            'fullWeek': fullWeek,
                            'path': path!.path,
                            'allSubject': id == '0'
                          };
                          sendData(data, context);
                        });
                      },
                      child: const Text('Generate'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        TimeTableCubit.mockObject
                            .invokeMethod(ReceiveMethods.downloadPdf, null);
                      },
                      child: const Text('Download'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final Map<String, dynamic> data = <String, dynamic>{};
                        TimeTableCubit.mockObject
                            .invokeMethod(ReceiveMethods.canclePreview, data);
                      },
                      child: const Text('Cancle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  ///return tile for dialog
  String getTitle(
      {required bool isDownloading, required ExportProgress exportProgres}) {
    final String progress = (exportProgres.progress * 100).toStringAsFixed(3);
    switch (isDownloading) {
      case true:
        return 'Pdf download progress: $progress}';

      case false:
        return 'Preview generation: progress: $progress}';

      default:
        return '';
    }
  }
}
