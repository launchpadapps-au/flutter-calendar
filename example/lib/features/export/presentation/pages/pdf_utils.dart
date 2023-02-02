import 'dart:async';
import 'dart:io';

import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/assets_path.dart';
import 'package:edgar_planner_calendar_flutter/features/export/data/models/export_progress.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/fileutils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

///Pdf functionality for the app
class PdfUtils {
  ///strea contriller for export progress
  StreamController<ExportProgress> streamController =
      StreamController<ExportProgress>.broadcast();

  ///it will dispose the stram
  void disposeStream() {
    streamController.sink.close();
  }

  ///atream of progress
  Stream<ExportProgress> get stream => streamController.stream;

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
        (await rootBundle.load(AssetPath.sofiaProFont)).buffer.asUint8List();
    final Font ttf = Font.ttf(fontData.buffer.asByteData());
    final Document pdf = Document(
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
    for (final Uint8List item in items) {
      final int index = items.indexOf(item);
      pdf.addPage(Page(
          pageFormat: pageFormat,
          margin: const EdgeInsets.only(left: 10, bottom: 10),
          orientation: PageOrientation.landscape,
          build: (Context context) => Container(
                width: width,
                height: height,
                child: Column(children: <Widget>[
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
                          Text(
                            titles[index],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                font: ttf,
                                fontSize: 10),
                          ),
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
                            ' /${index + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                            item,
                            dpi: 500,
                            orientation: PdfImageOrientation.topRight,
                          ),
                          width: width,
                          height: height - 35,
                        ))
                  ])
                ]),
              )));

      if ((index + 1) != length) {
        streamController.sink.add(ExportProgress(
            status: ExportStatus.inProgress, progress: (index + 1) / length));
      }
    }

    final String? filePath = await FileUtils.saveTopdf(await pdf.save(),
        filename: fileName, localPath: localPath);
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
}
