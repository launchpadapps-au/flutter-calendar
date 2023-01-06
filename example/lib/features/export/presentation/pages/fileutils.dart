import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// this class contain utility function for the file saving
class FileUtils {
  ///it will save data as pdf
  static Future<String> saveTomImage(Uint8List image,
      {required String filename}) async {
    final Directory? path = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory(); //FOR iOS

    final String filePath = '${path!.path}/exported/$filename.png';

    final File file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync(recursive: true);
    await file.writeAsBytes(image);
    log('image Path:${file.path}');
    return file.path;
  }
}
