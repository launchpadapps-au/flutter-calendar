// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer'; 
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_settings.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/pdf_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/dummy_subject.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    value: saveImg,
                    title: const Text('Save To Img'),
                    onChanged: (bool value) {
                      saveImg = value;
                      setState(() {});
                    }),
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
                      onPressed: () {
                        PdfUtils.saveDemo(PdfPageFormat.a4, 'demo-exported');

                        final List<DateTimeRange> weeks =
                            getListOfWeek(start, end);
                        log(weeks.toString());
                      },
                      child: const Text('Export Demo'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // PdfUtils.saveDemo(
                        //     Size(PdfPageFormat.a4.width
                        //, PdfPageFormat.a4.height),
                        //     "demo-exported");

                        final List<Subject> subject = selectedSubject['id'] == 0
                            ? <Subject>[]
                            : <Subject>[
                                Subject.fromJson(selectedSubject)
                              ];
                        // ignore: invalid_use_of_visible_for_testing_member
                        BlocProvider.of<TimeTableCubit>(context).emit(
                            ExportPreview(ExportSetting(
                                startFrom: start,
                                endTo: end,
                                pageFormat: PdfPageFormat.a4.landscape.copyWith(
                                    marginLeft: 10,
                                    marginRight: 10,
                                    marginTop: 0,
                                    marginBottom: 10),
                                view: <CalendarViewType>[currentView!],
                                subjects: subject,
                                fullWeek: fullWeek,
                                saveImg: saveImg)));
                      },
                      child: const Text('Export Preview'),
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
