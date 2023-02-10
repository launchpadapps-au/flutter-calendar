import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/calendar_utils.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart' as utils;
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/callbacks.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/dayview/day_event.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/dead_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_hour_lable.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/weekview/week_event.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_progress.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_settings.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/fileutils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/pdf_utils.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_cell.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_corner.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_header.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_hour_lable.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_month_header.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/widgets/export_month_note.dart';
import 'package:edgar_planner_calendar_flutter/features/screenshot/screenshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

///it will export selected view using static fucntion
class ExportView {
  ///initialize the object
  ExportView(this.nativeCallBack);

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

  ///it will true if user started genrating preview
  bool generatingPreview = false;

  ///list of memory
  List<Uint8List> datalist = <Uint8List>[];

  ///list of tile
  List<String> titles = <String>[];

  ///list of image path
  List<String> paths = <String>[];

  ///title of the pdf
  String pdfTitle = '';

  ///String path of the storage
  String localPath = '';

  ///object for native caallabck
  late NativeCallBack nativeCallBack;

  ///it will start generating preview
  Future<void> generatePreview(
      ExportSetting exportSetting,
      List<Period> timelines,
      List<PlannerEvent> event,
      List<CalendarEvent<Note>> notes) async {
    generatingPreview = true;
    datalist.clear();
    titles.clear();
    paths.clear();
    switch (exportSetting.view) {
      case CalendarViewType.weekView:
        localPath = exportSetting.path;
        pageFormat = exportSetting.pageFormat;

        await exportWeekView(
            startDate: exportSetting.startDate,
            endDate: exportSetting.endDate,
            timelines: timelines,
            subjectName: exportSetting.subjectName,
            event: event,
            subjectId: exportSetting.subjectId,
            allSubject: exportSetting.allSubject,
            fullWeek: exportSetting.fullWeek);
        break;
      case CalendarViewType.dayView:
        localPath = exportSetting.path;
        pageFormat = exportSetting.pageFormat;

        await exportDayView(
            startDate: exportSetting.startDate,
            endDate: exportSetting.endDate,
            timelines: timelines,
            event: event,
            fullWeek: exportSetting.fullWeek,
            allSubject: exportSetting.allSubject,
            subjectId: exportSetting.subjectId,
            subjectName: exportSetting.subjectName);
        break;

      case CalendarViewType.monthView:
        localPath = exportSetting.path;
        pageFormat = exportSetting.pageFormat;

        await exportMonthView(
          startDate: exportSetting.startDate,
          endDate: exportSetting.endDate,
          timelines: timelines,
          event: notes,
        );
        break;
      case CalendarViewType.scheduleView:
        break;
      case CalendarViewType.termView:
        break;
      case CalendarViewType.glScheduleView:
        break;
    }
  }

  ///it will cancle preview generating

  Future<void> canclePreview() async {
    generatingPreview = false;
  }

  ///it will export pdf to given path
  Future<void> exportPdf() async {
    logInfo('No of images: ${datalist.length}');
    await nativeCallBack.sendToNativeApp(SendMethods.downloadProgress,
        ExportProgress(status: ExportStatus.started, progress: 0).toJson());
    final PdfUtils pdfUtils = PdfUtils()..init();
    pdfUtils.stream.listen((ExportProgress event) async {
      logInfo('stram is working');
      await nativeCallBack.sendToNativeApp(
          SendMethods.downloadProgress, event.toJson());
    });
    final String filePath = await pdfUtils.savePdf(
        datalist, titles, pageFormat, pdfTitle, localPath);

    for (final String path in paths) {
      logInfo('');
      FileUtils.deleteFile(path);
    }
    await nativeCallBack.sendToNativeApp(
        SendMethods.downloadProgress,
        ExportProgress(
            status: ExportStatus.done,
            progress: 1,
            path: <String>[filePath]).toJson());
    pdfUtils.dispose();
  }

  ///it will capture screenshot fromt the widget
  Future<Uint8List> getScreenshot(ScreenshotData data) => ScreenshotController()
      .captureFromWidget(data.widget, targetSize: data.targetSize);

  ///it will capture screenshot using thread
  Future<Uint8List> captureScreenshot(ScreenshotData data) =>
      compute(getScreenshot, data);

  ///export week view
  Future<bool> exportWeekView(
      {required DateTime startDate,
      required DateTime endDate,
      required List<Period> timelines,
      required List<PlannerEvent> event,
      required bool allSubject,
      required String subjectId,
      required String subjectName,
      bool fullWeek = true,
      bool appBar = false,
      bool isMobile = false}) async {
    logPrety('Exporting Week view');
    logPrety('Start Date: $startDate End Date: $endDate');
    logPrety('Exporting Full week: $fullWeek');
    await nativeCallBack.sendToNativeApp(SendMethods.previewProgress,
        ExportProgress(status: ExportStatus.started, progress: 0).toJson());
    try {
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

      List<PlannerEvent> filterdEvent;
      if (allSubject) {
        logPrety('Exporting All Subject');
        filterdEvent = event
            .where((PlannerEvent element) =>
                element.eventData!.startDate
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                element.eventData!.endDate
                    .isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      } else {
        logPrety('Exporting $subjectName with $subjectId');
        filterdEvent = event
            .where((PlannerEvent element) =>
                element.eventData!.startDate
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                element.eventData!.endDate
                    .isBefore(endDate.add(const Duration(days: 1))) &&
                (element.eventData!.subject != null &&
                    element.eventData!.subject!.id.toString() ==
                        subjectId.toString()))
            .toList();
      }
      logPrety('No of Weeks: ${weeks.length}');
      int page = 1;

      for (final DateTimeRange week in weeks) {
        if (!generatingPreview) {
          logPrety('Cancling preview');
          break;
        } else {
          final TimetableController<EventData> simpleController =
              TimetableController<EventData>(
                  start: week.start,
                  end: week.end,
                  infiniteScrolling: false,
                  timelineWidth: timeLineWidth,
                  breakHeight: breakHeight,
                  maxColumns: fullWeek ? 7 : 5,
                  cellHeight: cellHeight)
                ..addEvent(filterdEvent);
          logInfo('startDate: ${week.start}and endDate:  ${week.start}');
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
                          child: SlWeekView<EventData>(
                              fullWeek: fullWeek,
                              onDateChanged: (DateTime dateTime) {},
                              onEventToEventDragged:
                                  (CalendarEvent<EventData> e,
                                      CalendarEvent<EventData> old,
                                      CalendarEvent<EventData> newEvent,
                                      Period? periodModel) {},
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
                              onWillAccept: (CalendarEvent<EventData>? event,
                                      Period p) =>
                                  true,
                              showActiveDateIndicator: false,
                              nowIndicatorColor: timeIndicatorColor,
                              cornerBuilder:
                                  (DateTime current) => const ExportCorner(),
                              headerHeight: headerHeight,
                              headerCellBuilder: (DateTime date) =>
                                  ExportHeader(
                                    date: date,
                                  ),
                              hourLabelBuilder: (Period p) => ExportHourLable(
                                  periodModel: p as PeriodModel,
                                  breakHeight: breakHeight,
                                  cellHeight: cellHeight,
                                  timelineWidth: timeLineWidth,
                                  isMobile: isMobile),
                              isCellDraggable:
                                  (CalendarEvent<EventData> event) =>
                                      isCelldraggable(event),
                              controller: simpleController,
                              itemBuilder:
                                  (CalendarEvent<EventData> i, double w) =>
                                      WeekEvent(
                                          item: i,
                                          cellHeight: cellHeight,
                                          breakHeight: breakHeight,
                                          freeTimeBg: true,
                                          width: w,
                                          periods: timelines),
                              cellBuilder: (Period p, DateTime d) => ExportCell(
                                  periodModel: p as PeriodModel,
                                  breakHeight: simpleController.breakHeight,
                                  cellHeight: simpleController.cellHeight)),
                        ),
                      )),
                  targetSize: size,
                  delay: const Duration(seconds: 2))
              .then((Uint8List value) async {
            final String fileName = 'Week ${weeks.indexOf(week) + 1}';
            logInfo(' Week view image received from planner');
            final String imagePath = await FileUtils.saveTomImage(value,
                filename: fileName, localPath: localPath);
            paths.add(imagePath);
            datalist.add(value);
            String subtitle = 'All Subjects';
            final String weekendsTitle = fullWeek ? '/ Weekend included' : '';
            if (!allSubject) {
              subtitle = subjectName;
            }
            titles.add(
              'From ${DateFormat('d MMMM').format(startDate)} to ${DateFormat('d MMMM y').format(endDate)}/ $subtitle$weekendsTitle',
            );
          });

          if (page != weeks.length) {
            await nativeCallBack.sendToNativeApp(
                SendMethods.previewProgress,
                ExportProgress(
                        status: ExportStatus.inProgress,
                        progress: page / weeks.length)
                    .toJson());
          }

          page = page + 1;
        }
      }
      logInfo('All Week image generated');
      pdfTitle = PdfUtils.pdfName(CalendarViewType.weekView,
          subjectName: subjectName, fullWeek: fullWeek, allSubject: allSubject);
      if (generatingPreview) {
        await nativeCallBack.sendToNativeApp(
            SendMethods.previewProgress,
            ExportProgress(status: ExportStatus.done, progress: 1, path: paths)
                .toJson());
      }
      return true;
    } on Exception {
      return false;
    }
  }

  ///it will export day view
  Future<bool> exportDayView(
      {required DateTime startDate,
      required DateTime endDate,
      required List<Period> timelines,
      required List<PlannerEvent> event,
      required bool allSubject,
      required String subjectId,
      required String subjectName,
      bool fullWeek = true,
      bool appBar = false,
      bool isMobile = false}) async {
    try {
      await nativeCallBack.sendToNativeApp(SendMethods.previewProgress,
          ExportProgress(status: ExportStatus.started, progress: 0).toJson());
      logPrety('Exporting Day view');
      logPrety('Start Date: $startDate End Date: $endDate');
      logPrety('Exporting Full week: $fullWeek');
      final int numberOfCell = fullWeek ? 7 : 5;
      Size size =
          Size(pageFormat.availableWidth, pageFormat.availableHeight - 35);
      final double ar = size.aspectRatio;
      cellWidth = (size.width - timeLineWidth) / numberOfCell;
      final double timeLigneHeight =
          getTimelineHeight(timelines, cellHeight, breakHeight) + appBarHeight;

      size = Size(timeLigneHeight * ar, timeLigneHeight + 5);
      cellWidth = (size.width - timeLineWidth) / numberOfCell;

      final int dif = endDate.difference(startDate).inDays + 1;
      List<PlannerEvent> filterdEvent;
      if (allSubject) {
        logPrety('Exporting All Subject');
        filterdEvent = event
            .where((PlannerEvent element) =>
                element.eventData!.startDate
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                element.eventData!.endDate
                    .isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      } else {
        logPrety('Exporting $subjectName with $subjectId');
        filterdEvent = event
            .where((PlannerEvent element) =>
                element.eventData!.startDate
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                element.eventData!.endDate
                    .isBefore(endDate.add(const Duration(days: 1))) &&
                (element.eventData!.subject != null &&
                    element.eventData!.subject!.id.toString() ==
                        subjectId.toString()))
            .toList();
      }
      logPrety('Total Days Days: $dif');
      int i = 0;

      while (i < dif) {
        final DateTime date = startDate.add(Duration(days: i));
        if (date.weekday == 6 && !fullWeek) {
          logPrety('Skiping day because of Saturday');
          i++;
        } else if (date.weekday == 7 && !fullWeek) {
          logPrety('Skiping day because of Sunday');
          i++;
        } else if (!generatingPreview) {
          logPrety('Cancling preview');
          break;
        } else {
          final DateTime end = date.add(const Duration(days: 1));

          final TimetableController<EventData> timetableController =
              TimetableController<EventData>(
                  start: date,
                  end: end,
                  timelineWidth: timeLineWidth,
                  breakHeight: breakHeight,
                  infiniteScrolling: false,
                  cellHeight: cellHeight)
                ..addEvent(filterdEvent);
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
                              onWillAccept: (CalendarEvent<EventData>? event,
                                      DateTime date, Period period) =>
                                  true,
                              nowIndicatorColor: timeIndicatorColor,
                              fullWeek: fullWeek,
                              autoScrollToday: false,
                              cornerBuilder: (DateTime current) =>
                                  const SizedBox.shrink(),
                              onTap: (DateTime dateTime, Period p1,
                                  CalendarEvent<EventData>? p2) {},
                              headerHeight:
                                  isMobile ? headerHeightForDayView : 40,
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
                              hourLabelBuilder: (Period p) => ExportHourLable(
                                  periodModel: p as PeriodModel,
                                  timelineWidth: timeLineWidth,
                                  breakHeight: breakHeight,
                                  cellHeight: cellHeight,
                                  isMobile: isMobile),
                              controller: timetableController,
                              headerDivideThickness: 0.5,
                              itemBuilder: (CalendarEvent<EventData> item,
                                      int index, int length, double width) =>
                                  DayEvent(
                                    item: item,
                                    periods: timelines,
                                    cellHeight: timetableController.cellHeight,
                                    breakHeight:
                                        timetableController.breakHeight,
                                    width: width,
                                    freeTimeBg: true,
                                    isMobile: isMobile,
                                  ),
                              cellBuilder: (Period p, DateTime d) => ExportCell(
                                    periodModel: p as PeriodModel,
                                    breakHeight:
                                        timetableController.breakHeight,
                                    cellHeight: timetableController.cellHeight,
                                  ))),
                    ),
                  ),
                  targetSize: size)
              .then((Uint8List value) async {
            String subtitle = 'All Subjects';
            final String weekendsTitle = fullWeek ? '/ Weekend included' : '';
            final String fileName = 'Day ${i + 1}';
            logInfo(' Day view image received from planner');

            final String imagePath = await FileUtils.saveTomImage(value,
                filename: fileName, localPath: localPath);
            paths.add(imagePath);
            if (!allSubject) {
              subtitle = subjectName;
            }
            datalist.add(value);
            titles.add(
              'From ${DateFormat('d MMMM').format(startDate)} to ${DateFormat('d MMMM y').format(endDate)}/ $subtitle$weekendsTitle',
            );
          });
          await nativeCallBack.sendToNativeApp(
              SendMethods.previewProgress,
              ExportProgress(status: ExportStatus.inProgress, progress: i / dif)
                  .toJson());
          i++;
        }
      }
      logInfo('All Day image generated');
      pdfTitle = PdfUtils.pdfName(CalendarViewType.dayView,
          subjectName: subjectName, fullWeek: fullWeek, allSubject: allSubject);
      if (generatingPreview) {
        await nativeCallBack.sendToNativeApp(
            SendMethods.previewProgress,
            ExportProgress(status: ExportStatus.done, progress: 1, path: paths)
                .toJson());
      }
      return true;
    } on Exception {
      return false;
    }
  }

  ///it will export month view
  Future<bool> exportMonthView(
      {required DateTime startDate,
      required DateTime endDate,
      required List<Period> timelines,
      required List<CalendarEvent<Note>> event}) async {
    await nativeCallBack.sendToNativeApp(SendMethods.previewProgress,
        ExportProgress(status: ExportStatus.started, progress: 0).toJson());
    try {
      Size size =
          Size(pageFormat.availableWidth, pageFormat.availableHeight - 35);
      logInfo(size.toString());
      size = Size(size.width * 2, size.height * 2);

      final List<Month> months = getMonthRange(startDate, endDate);
      logPrety('Exporting Month view');
      logPrety('Start Date: $startDate End Date: $endDate');
      logPrety('No of monhts: ${months.length}');
      for (final Month month in months) {
        if (!generatingPreview) {
          logPrety('Cancling preview');
          break;
        } else {
          final DateTime first =
              DateTime(month.year, month.month, month.startDay);
          final DateTime end = DateTime(month.year, month.month, month.endDay);

          final TimetableController<Note> timetableController =
              TimetableController<Note>(
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
                        child: Container(
                      width: size.width,
                      height: size.height,
                      color: white,
                      child: SlMonthView<Note>(
                        timelines: timelines,
                        size: size,
                        onMonthChanged: (Month month) {},
                        onEventDragged: (CalendarEvent<Note> old,
                            CalendarEvent<Note> newEvent) {},
                        onWillAccept: (CalendarEvent<Note>? event,
                                DateTime dateTime, Period period) =>
                            true,
                        nowIndicatorColor: Colors.red,
                        fullWeek: true,
                        deadCellBuilder: (DateTime current, Size cellSize) =>
                            const Expanded(
                          child: DeadCell(),
                        ),
                        onTap: (CalendarDay date) {},
                        headerHeight: 40,
                        headerCellBuilder: (int index) => ExportMonthHeader(
                          height: timetableController.headerHeight,
                          index: index,
                        ),
                        hourLabelBuilder: (Period period) =>
                            MonthHourLable(periodModel: period as PeriodModel),
                        controller: timetableController,
                        itemBuilder: (List<CalendarEvent<Note>> item, Size size,
                                CalendarDay calendarDay) =>
                            ExportMonthNote(
                          item: item,
                          calendarDay: calendarDay,
                          cellHeight: cellHeight,
                          breakHeight: breakHeight,
                          size: size,
                          isDraggable: false,
                          onTap: (CalendarDay dateTime,
                              List<CalendarEvent<Note>> p1) {},
                        ),
                        cellBuilder: (Size size, CalendarDay calendarDay) =>
                            MonthCell(size: size),
                      ),
                    )),
                  ),
                  targetSize: size)
              .then((Uint8List value) async {
            final String formated =
                DateFormat('MMMM').format(DateTime(month.year, month.month));
            final String fileName = 'Month '
                '$formated';
            const String subtitle = 'All Notes';
            logInfo(' Month view image received from planner');

            final String imagePath = await FileUtils.saveTomImage(value,
                filename: fileName, localPath: localPath);
            paths.add(imagePath);
            datalist.add(value);
            titles.add(
              'From ${DateFormat('d MMMM').format(startDate)} to ${DateFormat('d MMMM y').format(endDate)}/ $subtitle',
            );
          });
          final int index = months.indexOf(month);
          if (index + 1 != months.length) {
            await nativeCallBack.sendToNativeApp(
                SendMethods.previewProgress,
                ExportProgress(
                        status: ExportStatus.inProgress,
                        progress: (index + 1) / months.length)
                    .toJson());
          }
        }
      }
      pdfTitle = PdfUtils.pdfName(CalendarViewType.monthView,
          fullWeek: true, allSubject: true);
      if (generatingPreview) {
        await nativeCallBack.sendToNativeApp(
            SendMethods.previewProgress,
            ExportProgress(status: ExportStatus.done, progress: 1, path: paths)
                .toJson());
      }
      return true;
    } on Exception {
      return false;
    }
  }
}

/// This will use to pass screenshot data to thread
class ScreenshotData {
  ///initialize the data
  ScreenshotData(this.widget, this.targetSize);

  ///Widget that require to take screenshot
  Widget widget;

  ///size  of the widget
  Size targetSize;
}
