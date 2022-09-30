import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
///pdf service generate require pdf from given data
class PdfService {
  ///generate pdf for the lesson plan
  static Future<void> generateLessonPlanPdf() async {
    final pw.Document pdf = pw.Document();
    final ByteData font =
        await rootBundle.load('assets/fonts/sofiapro-Regular.ttf');

    final pw.Font ttf = pw.Font.ttf(font);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(children:<pw.Widget> [
          pw.Row(children:  <pw.Widget>[
            pw.Container(
                width: 20,
                height: 20,
                decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(10),
                    color: const PdfColor.fromInt(0xFF7483D1))),
            pw.SizedBox(width: 20),
            pw.Text('Math Lesson',
                style: pw.TextStyle(fontSize: 20, font: ttf)),
          ]),
          pw.Row(children:<pw.Widget>[
            pw.Expanded(
            
                child: pw.Column(children: <pw.Widget> [
                  pw.Text('Math Lesson',
                      style: pw.TextStyle(fontSize: 20, font: ttf)),
                  pw.Text('Math Lesson',
                      style: pw.TextStyle(fontSize: 20, font: ttf))
                ])),
            pw.Expanded(
                
                child: pw.Column(children: <pw.Widget> [
                  pw.Text('Math Lesson',
                      style: pw.TextStyle(fontSize: 20, font: ttf)),
                  pw.Text('Math Lesson',
                      style: pw.TextStyle(fontSize: 20, font: ttf))
                ])),
          ]),
          pw.Center(
            child: pw.Text('Hello World!'),
          )
        ]),
      ),
    );
    final Directory? dir = await getDownloadsDirectory();
    final File file = File('${dir!.path}/example.pdf');
    await file.writeAsBytes(await pdf.save());
    log('file saved');
  }
}
