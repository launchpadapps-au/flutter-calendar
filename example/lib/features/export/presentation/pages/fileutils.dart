 
import 'dart:io';

import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:name_plus/name_plus.dart'; 
import 'package:path_provider/path_provider.dart';

/// this class contain utility function for the file saving
class FileUtils {
  ///it will save data as pdf
  static Future<String> saveTomImage(Uint8List image,
      {required String filename, required String localPath}) async {
//FOR iOS

    final String storagePath = localPath;
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
      {required String filename, required String localPath}) async {
    try {
//FOR iOS

      final String storagePath = localPath;
      // final String filePath = '$storagePath/exported/$filename.pdf';

      final File file = await File('$storagePath/exported').namePlus(
        '$filename.pdf',
        format: '(d)',
      );

      file.createSync(recursive: true);
      await file.writeAsBytes(image);
      logInfo('image Path:${file.path}');
      return file.path;
    } on Exception catch (e) {
      return e.toString();
    }
  }///it will return path based on the paltform

  static Future<Directory?> getPath() async {
    final Directory? path = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory();
    return path;
  }
///it will delete file
  static bool deleteFile(String path) {
    try {
      final File file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }
}
 