import 'dart:developer';

///this function log given data to console using log function from dart:
///developer
void appLog(dynamic data, {bool show = false}) {
  if (show) {
    log(data.toString());
  }
}
