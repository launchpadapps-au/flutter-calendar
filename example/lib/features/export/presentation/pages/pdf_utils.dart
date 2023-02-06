import 'dart:async';
import 'dart:io';

import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/assets_path.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_progress.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/fileutils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

///Pdf functionality for the app
class PdfUtils {
  ///strea contriller for export progress
  late StreamController<ExportProgress> _streamController;

  ///it will init the stream
  void init() {
    _streamController = StreamController<ExportProgress>.broadcast();
  }

  ///it will dispose the stram
  void dispose() {
    _streamController.close();
  }

  ///atream of progress
  Stream<ExportProgress> get stream => _streamController.stream;

  ///it will sabe pdf in the local storage
  ///
  ///

  Future<String> savePdf(List<Uint8List> items, List<String> titles,
      PdfPageFormat pageFormat, String fileName, String localPath) async {
    final double width = pageFormat.availableWidth;
    final double height = pageFormat.availableHeight;
    log
      ..info('page format $pageFormat')
      ..info('Pdf size width:$width height:$height');
    final Uint8List fontData =
        (await rootBundle.load(AssetPath.sofiaProFontBold))
            .buffer
            .asUint8List();
    final Font ttf = Font.ttf(fontData.buffer.asByteData());
    Document pdf = Document(
      pageMode: PdfPageMode.fullscreen,
    );
    final MemoryImage titleLogo = MemoryImage(
      (await rootBundle.load(AssetPath.logo)).buffer.asUint8List(),
    );
    final MemoryImage smallLogo = MemoryImage(
      (await rootBundle.load(AssetPath.smallLogo)).buffer.asUint8List(),
    );
    final int length = items.length;
    logInfo('saving pdf');

    Document getPage(AddPage data) {
      final Document pdf = data.document
        ..addPage(Page(
            pageFormat: pageFormat,
            margin: const EdgeInsets.only(left: 10, bottom: 10),
            orientation: PageOrientation.landscape,
            build: (Context context) => Container(
                  width: width,
                  height: height,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: 35,
                            width: width,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 30,
                                ),
                                Image(
                                  titleLogo,
                                  width: 56,
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      titles[data.index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          font: ttf,
                                          fontSize: 10),
                                    )),
                                Spacer(),
                                Image(
                                  smallLogo,
                                  width: 9,
                                  height: 11,
                                ),
                                SizedBox(
                                  width: 1,
                                ),
                                Text(
                                  ' /${data.index + 1}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      font: ttf,
                                      fontSize: 10),
                                ),
                                SizedBox(
                                  width: 35,
                                ),
                              ],
                            )),
                        Row(children: <Widget>[
                          Container(
                              width: width,
                              height: height - 35,
                              decoration: const BoxDecoration(),
                              // margin: EdgeInsets.only(left: 10, bottom: 10),
                              child: Image(
                                MemoryImage(
                                  data.item,
                                  dpi: 500,
                                  orientation: PdfImageOrientation.topRight,
                                ),
                                width: width,
                                height: height - 35,
                              ))
                        ])
                      ]),
                )));

      return pdf;
    }

    Future<Document> addPAge(AddPage data) => compute(getPage, data);

    for (final Uint8List item in items) {
      final int index = items.indexOf(item);
      pdf = await addPAge(AddPage(pdf, titles[index], item, index));
      if ((index + 1) != length) {
        _streamController.sink.add(ExportProgress(
            status: ExportStatus.inProgress, progress: (index + 1) / length));
      }
    }

    Future<Uint8List> getByteData(Document pdf) async => pdf.save();

    Future<Uint8List> savePage(Document pdf) => compute(getByteData, pdf);
    Future<String?> savePdfComputeFunction(FileDataForThred fileData) async =>
        FileUtils.saveTopdf(fileData.data,
            filename: fileData.filename, localPath: fileData.localPath);

    Future<String?> savePdfUsingThred(FileDataForThred fileData) =>
        compute(savePdfComputeFunction, fileData);
    final Uint8List biteData = await savePage(pdf);
    final String? filePath = await savePdfUsingThred(
        FileDataForThred(biteData, fileName, localPath));
    logInfo('file saved');
    return filePath!;
  }

  ///it will save demo pdf in the storage
  static Future<void> saveDemo(
      PdfPageFormat pageFormat, String fileName) async {
    final double height = pageFormat.height;
    final double width = pageFormat.width;
    final Document pdf = Document(
      pageMode: PdfPageMode.fullscreen,
    )..addPage(Page(
        pageFormat: PdfPageFormat.a4,
        margin: EdgeInsets.zero,
        clip: true,
        orientation: PageOrientation.landscape,
        build: (Context context) => Container(
              width: height,
              height: width,
              color: PdfColor.fromRYB(1, 0, 0),
              child: Column(children: <Widget>[
                Container(
                  height: 35,
                  width: height,
                  color: PdfColor.fromRYB(1, 0, 1),
                ),
                Container(
                    width: height,
                    height: width - 35,
                    decoration: BoxDecoration(
                        color: PdfColor.fromRYB(0, 1, 0),
                        border: Border.all(
                            width: 0, color: PdfColor.fromRYB(0, 0, 1)))
                    // child:
                    //  Image(
                    //   MemoryImage(
                    //     item,
                    //     dpi: 500,
                    //     orientation: PdfImageOrientation.topLeft,
                    //   ),
                    //   width: height - 50,
                    //   height: width,
                    // )
                    )
              ]),
            )));

    logInfo('saving pdf');
    final Directory? dir = await getDownloadsDirectory();
    final File file = File(
      '${dir!.path}/$fileName.pdf',
    );
    if (file.existsSync()) {
      file
        ..deleteSync()
        ..createSync();
    }
    await file.writeAsBytes(await pdf.save());
    logInfo('file saved');
  }

  ///return pdf name based on view type and other prameter
  static String pdfName(
    CalendarViewType viewType, {
    required bool fullWeek,
    required bool allSubject,
    String? subjectName,
  }) {
    {
      switch (viewType) {
        case CalendarViewType.weekView:
          const String title = 'Week view';
          final String? subject = allSubject ? 'All Subjects' : subjectName;
          const String weekend = 'Weekends included';
          final String? subTitle = fullWeek ? '$weekend - $subject' : subject;
          return '$title ( $subTitle )';
        case CalendarViewType.dayView:
          const String title = 'Day view';
          final String? subject = allSubject ? 'All Subjects' : subjectName;
          const String weekend = 'Weekends included';
          final String? subTitle = fullWeek ? '$weekend - $subject' : subject;
          return '$title ( $subTitle )';
        case CalendarViewType.monthView:
          return 'Month view ( All Notes)';
        case CalendarViewType.scheduleView:
          break;

        case CalendarViewType.termView:
          break;
        case CalendarViewType.glScheduleView:
          break;
      }
    }
    return '';
  }
}

/// This will use to supply page data to thread
class AddPage {
  ///initialize the page data
  AddPage(this.document, this.title, this.item, this.index);

  ///pdf document object
  Document document;

  ///title of the page
  String title;

  ///byte data of the page
  Uint8List item;

  ///index of the page
  int index;
}

/// This will use to supply page data to thread
class FileDataForThred {
  ///initialze the file data
  FileDataForThred(this.data, this.filename, this.localPath);

  ///byte data of the file
  Uint8List data;

  ///name of the file
  String filename;

  ///path of the file
  String localPath;
}
