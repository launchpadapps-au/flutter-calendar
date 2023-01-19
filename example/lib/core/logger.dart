import 'package:logging/logging.dart';

///logger object for the app
final Logger log = Logger('edgar-planner');

///log info the console
void logInfo(Object data) {
  log.info(data);
}

///log info with decoration
void logPrety(Object data) {
  log.info('===== $data =====');
}
