// ignore_for_file: invalid_use_of_protected_member
import 'dart:io';

import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/pdf_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/dummy_subject.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:path_provider/path_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Export view')),
      body: Row(children: <Widget>[
        SizedBox(
          width: size.width / 2,
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
                            child: Text(e.toString()),
                            value: e,
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
                            value: e,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        await PdfUtils.saveDemo(PdfPageFormat.a4, 'demo');
                      },
                      child: const Text('Save Demo'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final String id =
                            Subject.fromJson(selectedSubject).id.toString();
                        final String subjectName =
                            Subject.fromJson(selectedSubject)
                                .subjectName
                                .toString();
                        final Directory path = (Platform.isIOS
                            ? await getApplicationSupportDirectory()
                            : await getDownloadsDirectory())!;
                        final Map<String, dynamic> data = <String, dynamic>{
                          'startDate': start.toIso8601String(),
                          'endDate': end.toIso8601String(),
                          'view': currentView.toString(),
                          'subjectId': id == '0' ? null : id,
                          'subjectName': id == '0' ? null : subjectName,
                          'fullWeek': fullWeek,
                          'path': path.path
                        };
                        BlocProvider.of<TimeTableCubit>(context)
                            .mockObject
                            .invokeMethod(ReceiveMethods.generatePreview, data);
                      },
                      child: const Text('Generate '),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<TimeTableCubit>(context)
                            .mockObject
                            .invokeMethod(ReceiveMethods.downloadPdf, null);
                      },
                      child: const Text('Download'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final Map<String, dynamic> data = <String, dynamic>{};
                        BlocProvider.of<TimeTableCubit>(context)
                            .mockObject
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
        SizedBox(
          width: size.width / 2,
        )
      ]),
    );
  }
}
