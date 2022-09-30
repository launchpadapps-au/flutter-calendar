import 'dart:developer';
import 'dart:io';

import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;

///Preview
class Preview {
  ///scale factor'
  static double scaleFactor = 1;

  ///export week view
  static Future<void> exportWeekView(DateTime startDate, DateTime endDate,
      List<Period> timelines, List<PlannerEvent> event, BuildContext context,
      {bool saveImage = true}) async {
    final double ch = 110 * scaleFactor,
        bw = 35 * scaleFactor,
        cw = 130 * scaleFactor,
        borderWidth = 10 * scaleFactor,
        timeLineWidth = 70 * scaleFactor;
    final int diff = endDate.difference(startDate).inDays;

    final List<CalendarDay> dateRange = <CalendarDay>[];
    for (int i = 0; i <= diff; i++) {
      dateRange.add(CalendarDay(dateTime: startDate.add(Duration(days: i))));
    }
    final List<CalendarDay> dates = addPaddingDate(dateRange);
    log('Exporting Week View: \nNo week: ${dates.length ~/ 7}');
    int skip = 0;
    final Size size = Size(7 * cw + timeLineWidth,
        bw + borderWidth + getTimelineHeight(timelines, ch, bw) + borderWidth);

    final pw.Document pdf = pw.Document();
    // final ByteData font =
    //     await rootBundle.load('assets/fonts/sofiapro-Regular.ttf');

    // final pw.Font ttf = pw.Font.ttf(font);

    while (skip < dates.length) {
      final Iterable<CalendarDay> myDateRange = dates.skip(skip).take(7);
      final DateTime first = myDateRange.first.dateTime;
      final DateTime last = myDateRange.last.dateTime;
      final TimetableController simpleController = TimetableController(
          start: first,
          end: last,
          timelineWidth: timeLineWidth,
          breakHeight: bw,
          cellHeight: ch);

      log('startDate: $first and endDate: $last');
      await ScreenshotController()
          .captureFromWidget(
              MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Material(
                    child: Container(
                      decoration: BoxDecoration(
                          color: white, border: Border.all(width: 5)),
                      width: size.width,
                      height: size.height,
                      child: SlWeekView<EventData>(
                        backgroundColor: white,
                        size: size,
                        columnWidth: 130,
                        showNowIndicator: false,
                        onImageCapture: (Uint8List data) {},
                        fullWeek: true,
                        timelines: timelines,
                        onEventDragged: (CalendarEvent<EventData> old,
                            CalendarEvent<EventData> newEvent,
                            Period? period) {},
                        onWillAccept:
                            (CalendarEvent<EventData>? event, Period period) =>
                                true,
                        nowIndicatorColor: primaryPink,
                        cornerBuilder: (DateTime current) => Container(
                          color: white,
                        ),
                        items: event,
                        onTap: (DateTime date, Period period,
                            CalendarEvent<EventData>? event) {},
                        headerHeight: 40,
                        headerCellBuilder: (DateTime date) => Container(
                          color: white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                DateFormat('E').format(date).toUpperCase(),
                                style: context.subtitle,
                              ),
                              Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.5),
                                      color: isSameDate(date)
                                          ? primaryPink
                                          : Colors.transparent),
                                  child: Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: context.headline1WithNotoSans
                                          .copyWith(
                                              color: isSameDate(date)
                                                  ? Colors.white
                                                  : null),
                                    ),
                                  )),
                              const SizedBox(
                                height: 2,
                              ),
                            ],
                          ),
                        ),
                        hourLabelBuilder: (Period period) {
                          final TimeOfDay start = period.startTime;

                          final TimeOfDay end = period.endTime;
                          return Container(
                            color: white,
                            child: period.isBreak
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(period.title ?? '',
                                          style: context.hourLabelTablet),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          start.format(context).substring(0, 5),
                                          style: context.hourLabelTablet),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(end.format(context).substring(0, 5),
                                          style: context.hourLabelTablet),
                                    ],
                                  ),
                          );
                        },
                        isCellDraggable: (CalendarEvent<EventData> event) {
                          if (event.eventData!.period.isBreak) {
                            return false;
                          } else {
                            return true;
                          }
                        },
                        controller: simpleController,
                        itemBuilder:
                            (CalendarEvent<EventData> item, double width) =>
                                Container(
                          margin: const EdgeInsets.all(4),
                          child: Container(
                              padding: const EdgeInsets.all(6),
                              height: item.eventData!.period.isBreak
                                  ? simpleController.breakHeight
                                  : simpleController.cellHeight,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: item.eventData!.color),
                              child: item.eventData!.period.isBreak
                                  ? SizedBox(
                                      height: simpleController.breakHeight,
                                      child: Center(
                                          child: Text(
                                        item.eventData!.title,
                                        style: context.subtitle,
                                      )),
                                    )
                                  : EventTile(
                                      item: item,
                                      height: item.eventData!.period.isBreak
                                          ? simpleController.breakHeight
                                          : simpleController.cellHeight,
                                      width: width,
                                    )),
                        ),
                        cellBuilder: (Period period) => Container(
                          height: period.isBreak
                              ? simpleController.breakHeight
                              : simpleController.cellHeight,
                          decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              color: period.isBreak
                                  ? lightGrey
                                  : Colors.transparent),
                        ),
                      ),
                    ),
                  )),
              targetSize: size)
          .then((Uint8List value) {
        final String fileName = 'Week ${skip ~/ 7}';
        log(' Week view image received from planner');
        if (saveImage) {
          BlocProvider.of<TimeTableCubit>(context)
              .saveTomImage(value, filename: fileName);
        } else {
          pdf.addPage(pw.Page(
              pageFormat: PdfPageFormat(size.height, size.width),
              build: (pw.Context context) => pw.Transform.rotate(
                  angle: -90 * math.pi / 180,
                  child: pw.Center(
                      child: pw.Container(
                          color: PdfColor.fromRYB(1, 0, 0),
                          child: pw.FittedBox(
                            child: pw.Image(
                                pw.MemoryImage(
                                  value,
                                  dpi: 500,
                                  orientation: PdfImageOrientation.topLeft,
                                ),
                                // width: 2480,
                                // height: 3508,
                                fit: pw.BoxFit.fitWidth,
                                width: size.width,
                                height: size.height),
                          ))))));
        }
      });
      skip = skip + 7;
    }
    if (!saveImage) {
      final Directory? dir = await getDownloadsDirectory();
      final File file = File(
        '${dir!.path}/example.pdf',
      );
      await file.writeAsBytes(await pdf.save());
      log('file saved');
    }
  }
}
