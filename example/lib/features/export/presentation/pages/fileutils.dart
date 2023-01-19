import 'dart:io';

import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// this class contain utility function for the file saving
class FileUtils {
  ///it will save data as pdf
  static Future<String> saveTomImage(Uint8List image,
      {required String filename, String? localPath}) async {
    final Directory? path = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory(); //FOR iOS

    final String storagePath = localPath ?? path!.path;
    final String filePath = '$storagePath/exported/$filename.png';

    final File file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync(recursive: true);
    await file.writeAsBytes(image);
    logInfo('image Path:${file.path}');
    return file.path;
  }

  ///save file as pdf
  static Future<String?> saveTopdf(Uint8List image,
      {required String filename, String? localPath}) async {
    try {
      final Directory? path = Platform.isAndroid
          ? await getExternalStorageDirectory() //FOR ANDROID
          : Platform.isIOS
              ? await getApplicationDocumentsDirectory()
              : await getDownloadsDirectory(); //FOR iOS

      final String storagePath = localPath ?? path!.path;
      final String filePath = '$storagePath/exported/$filename.pdf';

      final File file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      file.createSync(recursive: true);
      await file.writeAsBytes(image);
      logInfo('image Path:${file.path}');
      return filePath;
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
