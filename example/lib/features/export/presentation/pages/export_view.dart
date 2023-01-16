import 'dart:developer';
import 'dart:typed_data';

import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart' as utils;
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dayview/day_event.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/dead_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_hour_lable.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/weekview/week_event.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/fileutils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/pdf_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_corner.dart.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_header.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_hour_lable.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_month_event.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_month_header.dart';
import 'package:edgar_planner_calendar_flutter/features/screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

///it will export selected view using static fucntion
class ExportView {
  ///scale factor'
  static double scaleFactor = 1;

  ///hright of the cell
  static double cellHeight = 130 * scaleFactor;

  ///height of the break
  static double breakHeight = 35 * scaleFactor;

  ///width of the cell
  static double cellWidth = 130 * scaleFactor;

  ///widdth of the outer border
  static double borderWidth = 10 * scaleFactor;

  ///width of the timeline
  static double timeLineWidth = 70 * scaleFactor;

  ///height of the break
  static double appBarHeight = 48 * scaleFactor;

  ///pgae format
  static PdfPageFormat pageFormat = PdfPageFormat.a4.landscape;

  ///export week view
  static Future<void> exportWeekView(
      {required DateTime startDate,
      required DateTime endDate,
      required List<Period> timelines,
      required List<PlannerEvent> event,
      required BuildContext context,
      required List<Subject> subjects,
      required PdfPageFormat pageFormat,
      bool saveImage = true,
      bool fullWeek = true,
      bool appBar = false,
      bool isMobile = false}) async {
    log('Start: $startDate End: $endDate');
    final List<DateTimeRange> weeks = utils.getListOfWeek(startDate, endDate);
    final int numberOfCell = fullWeek ? 7 : 5;
    Size size =
        Size(pageFormat.availableWidth, pageFormat.availableHeight - 35);
    final double ar = size.aspectRatio;
    cellWidth = (size.width - timeLineWidth) / numberOfCell;
    final double timeLigneHeight =
        getTimelineHeight(timelines, cellHeight, breakHeight) + appBarHeight;

    size = Size(timeLigneHeight * ar, timeLigneHeight + 5);
    cellWidth = (size.width - timeLineWidth) / numberOfCell;
    log('Size-> Width: ${size.width}'
        ' Height: ${PdfPageFormat.a4.height}');

    ///list of memory
    final List<Uint8List> datalist = <Uint8List>[];

    ///list of tile
    final List<String> titles = <String>[];
    List<PlannerEvent> filterdEvent;
    if (subjects.isEmpty) {
      filterdEvent = event
          .where((PlannerEvent element) =>
              element.eventData!.startDate
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              element.eventData!.endDate
                  .isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    } else {
      filterdEvent = event
          .where((PlannerEvent element) =>
              element.eventData!.startDate
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              element.eventData!.endDate
                  .isBefore(endDate.add(const Duration(days: 1))) &&
              (element.eventData!.subject != null &&
                  element.eventData!.subject!.id.toString() ==
                      subjects[0].id.toString()))
          .toList();
    }
    int page = 1;
    for (final DateTimeRange week in weeks) {
      final TimetableController<EventData> simpleController =
          TimetableController<EventData>(
              start: week.start,
              end: week.end,
              infiniteScrolling: false,
              timelineWidth: timeLineWidth,
              breakHeight: breakHeight,
              cellHeight: cellHeight)
            ..addEvent(filterdEvent);
      final DateTime first = week.start;
      final DateTime last = week.end;
      log('startDate: ${week.start}and endDate:  ${week.start}');
      await ScreenshotController()
          .captureFromWidget(
              MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Material(
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: Container(
                        width: size.height,
                        height: size.width,
                        decoration: BoxDecoration(
                            color: white, border: Border.all(width: 0)),
                        child: SlWeekView<EventData>(
                            backgroundColor: white,
                            fullWeek: fullWeek,
                            headerDivideThickness: 0,
                            columnWidth: cellWidth,
                            showNowIndicator: false,
                            size: size,
                            timelines: timelines,
                            onEventDragged: (CalendarEvent<EventData> old,
                                CalendarEvent<EventData> newEvent,
                                Period? period) {},
                            onTap: (DateTime date, Period period,
                                CalendarEvent<EventData>? event) {},
                            onEventToEventDragged:
                                (CalendarEvent<EventData> existing,
                                    CalendarEvent<EventData> old,
                                    CalendarEvent<EventData> newEvent,
                                    Period? periodModel) {},
                            onWillAccept:
                                (CalendarEvent<EventData>? event, Period p) =>
                                    true,
                            showActiveDateIndicator: false,
                            nowIndicatorColor: timeIndicatorColor,
                            cornerBuilder: (DateTime current) =>
                                const ExportCorner(),
                            headerHeight: headerHeight,
                            headerCellBuilder: (DateTime date) => ExportHeader(
                                  date: date,
                                ),
                            hourLabelBuilder: (Period period) =>
                                ExportHourLable(
                                    periodModel: period as PeriodModel,
                                    breakHeight: breakHeight,
                                    cellHeight: cellHeight,
                                    timelineWidth: timeLineWidth,
                                    isMobile: isMobile),
                            isCellDraggable: (CalendarEvent<EventData> event) =>
                                isCelldraggable(event),
                            controller: simpleController,
                            itemBuilder:
                                (CalendarEvent<EventData> item, double width) =>
                                    WeekEvent(
                                        item: item,
                                        cellHeight: cellHeight,
                                        breakHeight: breakHeight,
                                        width: width,
                                        periods: timelines),
                            cellBuilder: (Period period, DateTime dateTime) =>
                                ExportCell(
                                    periodModel: period as PeriodModel,
                                    breakHeight: simpleController.breakHeight,
                                    cellHeight: simpleController.cellHeight)),
                      ),
                    ),
                  )),
              targetSize: size)
          .then((Uint8List value) async {
        final String fileName = 'Week ${weeks.indexOf(week) + 1}';
        log(' Week view image received from planner');
        await FileUtils.saveTomImage(value, filename: fileName);
        if (saveImage) {
        } else {
          datalist.add(value);
          String subtitle = 'All Subjects';
          final String weekendsTitle = fullWeek ? '/ Weekend included' : '';
          if (subjects.isNotEmpty) {
            subtitle = subjects.first.subjectName;
          }
          titles.add(
            'From ${DateFormat('d MMM').format(first)}To ${DateFormat('d MMMM y').format(last)}/ $subtitle$weekendsTitle',
          );
        }
      });

      page = page + 1;
    }
    if (!saveImage) {
      await PdfUtils().savePdf(datalist, titles, pageFormat,
          'Week view${fullWeek ? '( Weekend included )' : ''}');
    } else {}
  }

  ///it will export day view
  static Future<void> exportDayView(
      {required DateTime startDate,
      required DateTime endDate,
      required List<Period> timelines,
      required List<PlannerEvent> event,
      required BuildContext context,
      required List<Subject> subjects,
      required PdfPageFormat pageFormat,
      bool saveImage = true,
      bool fullWeek = true,
      bool appBar = false,
      bool isMobile = false}) async {
    log('Start: $startDate End: $endDate');
    final int numberOfCell = fullWeek ? 7 : 5;
    Size size =
        Size(pageFormat.availableWidth, pageFormat.availableHeight - 35);
    final double ar = size.aspectRatio;
    cellWidth = (size.width - timeLineWidth) / numberOfCell;
    final double timeLigneHeight =
        getTimelineHeight(timelines, cellHeight, breakHeight) + appBarHeight;

    size = Size(timeLigneHeight * ar, timeLigneHeight + 5);
    cellWidth = (size.width - timeLineWidth) / numberOfCell;
    log('Size-> Width: ${size.width}'
        ' Height: ${PdfPageFormat.a4.height}');
    final int dif = endDate.difference(startDate).inDays;
    int i = 0;

    ///list of memory
    final List<Uint8List> datalist = <Uint8List>[];

    ///list of tile
    final List<String> titles = <String>[];
    while (i < dif) {
      final DateTime date = startDate.add(Duration(days: i));
      final DateTime end = date.add(const Duration(days: 1));

      final TimetableController<EventData> timetableController =
          TimetableController<EventData>(
              start: date,
              end: end,
              timelineWidth: timeLineWidth,
              breakHeight: breakHeight,
              infiniteScrolling: false,
              cellHeight: cellHeight)
            ..addEvent(event);
      await ScreenshotController()
          .captureFromWidget(
              MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Material(
                  child: Container(
                      width: size.height,
                      height: size.width,
                      decoration: BoxDecoration(
                          color: white, border: Border.all(width: 0)),
                      child: NewSlDayView<EventData>(
                          backgroundColor: white,
                          timelines: timelines,
                          size: size,
                          onDateChanged: (DateTime dateTime) {},
                          onEventDragged: (CalendarEvent<EventData> old,
                              CalendarEvent<EventData> newEvent,
                              Period? periodModel) {},
                          onEventToEventDragged:
                              (CalendarEvent<EventData> existing,
                                  CalendarEvent<EventData> old,
                                  CalendarEvent<EventData> newEvent,
                                  Period? periodModel) {},
                          onWillAccept: (CalendarEvent<EventData>? event,
                              DateTime date, Period period) {
                            final List<CalendarEvent<EventData>> events =
                                BlocProvider.of<TimeTableCubit>(context).events;
                            return isSlotAvlForSingleDay(
                                events, event!, date, period);
                          },
                          nowIndicatorColor: timeIndicatorColor,
                          fullWeek: true,
                          cornerBuilder: (DateTime current) =>
                              const SizedBox.shrink(),
                          onTap: (DateTime dateTime, Period p1,
                              CalendarEvent<EventData>? p2) {},
                          headerHeight: isMobile ? headerHeightForDayView : 40,
                          headerCellBuilder: (DateTime date) =>
                              const ExportCorner(),
                          headerTitleBuilder: (DateTime date) =>
                              ExportHeader(date: date),
                          headerDecoration: (DateTime dateTime) =>
                              const BoxDecoration(boxShadow: <BoxShadow>[
                                BoxShadow(
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                    color: Color(0x0000001A))
                              ]),
                          hourLabelBuilder: (Period period) => ExportHourLable(
                              periodModel: period as PeriodModel,
                              timelineWidth: timeLineWidth,
                              breakHeight: breakHeight,
                              cellHeight: cellHeight,
                              isMobile: isMobile),
                          controller: timetableController,
                          headerDivideThickness: 0.5,
                          isCellDraggable: (CalendarEvent<EventData> event) =>
                              isCelldraggable(event),
                          itemBuilder: (CalendarEvent<EventData> item,
                                  int index, int length, double width) =>
                              DayEvent(
                                item: item,
                                periods: timelines,
                                cellHeight: timetableController.cellHeight,
                                breakHeight: timetableController.breakHeight,
                                width: width,
                                isMobile: isMobile,
                              ),
                          cellBuilder: (Period period, DateTime dateTime) =>
                              ExportCell(
                                periodModel: period as PeriodModel,
                                breakHeight: timetableController.breakHeight,
                                cellHeight: timetableController.cellHeight,
                              ))),
                ),
              ),
              targetSize: size)
          .then((Uint8List value) async {
        const String subtitle = 'All Subjects';
        final String weekendsTitle = fullWeek ? '/ Weekend included' : '';
        final String fileName = 'Day ${i + 1}';
        log(' Day view image received from planner');
        await FileUtils.saveTomImage(value, filename: fileName);
        if (saveImage) {
        } else {
          datalist.add(value);
          titles.add(
            '${DateFormat('d MMMM y').format(date)}/ $subtitle$weekendsTitle',
          );
        }
      });

      i++;
    }
    if (!saveImage) {
      await PdfUtils().savePdf(datalist, titles, pageFormat, 'Day view');
    } else {}
  }

  ///it will export month view
  static Future<void> exportMonthView(
      {required DateTime startDate,
      required DateTime endDate,
      required List<Period> timelines,
      required List<PlannerEvent> event,
      required BuildContext context,
      required List<Subject> subjects,
      required PdfPageFormat pageFormat,
      bool fullWeek = true,
      bool saveImage = true,
      bool isMobile = false}) async {
    Size size =
        Size(pageFormat.availableWidth, pageFormat.availableHeight - 35);
    log(size.toString());
    size = Size(size.width * 2, size.height * 2);

    ///list of memory
    final List<Uint8List> datalist = <Uint8List>[];

    ///list of tile
    final List<String> titles = <String>[];

    final List<Month> months = getMonthRange(startDate, endDate);
    for (final Month month in months) {
      final DateTime first = DateTime(month.year, month.month, month.startDay);
      final DateTime end = DateTime(month.year, month.month, month.endDay);

      log('Capturing monthview from $first and $end');

      final TimetableController<EventData> timetableController =
          TimetableController<EventData>(
              start: first,
              end: end,
              timelineWidth: timeLineWidth,
              breakHeight: breakHeight,
              cellHeight: cellHeight)
            ..addEvent(event);
      await ScreenshotController()
          .captureFromWidget(
              MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Material(
                    child: SlMonthView<EventData>(
                        timelines: timelines,
                        size: size,
                        onMonthChanged: (Month month) {},
                        onEventDragged: (CalendarEvent<EventData> old,
                            CalendarEvent<EventData> newEvent) {},
                        onWillAccept: (CalendarEvent<EventData>? event,
                                DateTime dateTime, Period period) =>
                            true,
                        nowIndicatorColor: Colors.red,
                        fullWeek: true,
                        deadCellBuilder: (DateTime current, Size size) =>
                            SizedBox(
                              width: size.width,
                              height: size.height,
                              child: const DeadCell(),
                            ),
                        onTap: (DateTime date) {},
                        headerHeight: isMobile ? 38 : 40,
                        headerCellBuilder: (int index) => ExportMonthHeader(
                              height: timetableController.headerHeight,
                              index: index,
                            ),
                        hourLabelBuilder: (Period period) =>
                            MonthHourLable(periodModel: period as PeriodModel),
                        controller: timetableController,
                        itemBuilder: (List<CalendarEvent<EventData>> item,
                                Size size) =>
                            ExportMonthEvent(
                              item: item,
                              cellHeight: timetableController.cellHeight,
                              breakHeight: timetableController.breakHeight,
                              size: size,
                              onMoreTap: (List<CalendarEvent<EventData>> item,
                                      Offset globalPosition) =>
                                  log('Open $item'),
                              isDraggable: false,
                              onTap: (DateTime dateTime,
                                  List<CalendarEvent<EventData>> p1) {},
                            ),
                        cellBuilder: (Period period) => MonthCell(
                            periodModel: period as PeriodModel,
                            breakHeight: timetableController.breakHeight,
                            cellHeight: timetableController.cellHeight))),
              ),
              targetSize: size)
          .then((Uint8List value) async {
        final String fileName = 'Month $first to $end';
        const String subtitle = 'All Subjects';
        final String weekendsTitle = fullWeek ? '/ Weekend included' : '';
        log(' Month view image received from planner');
        await FileUtils.saveTomImage(value, filename: fileName);
        if (saveImage) {
        } else {
          datalist.add(value);
          titles.add(
            '${DateFormat('MMMM y').format(first)}/ $subtitle$weekendsTitle',
          );
        }
      });
    }
    if (!saveImage) {
      await PdfUtils().savePdf(datalist, titles, pageFormat, 'Month View');
    } else {}
  }
}
