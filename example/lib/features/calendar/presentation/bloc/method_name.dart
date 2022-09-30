///send callback when user tap cell
const String onTapMethod = 'onTap';

///class which contain static method names which return data from native aoo
class ReceiveMethods {
  ///data from native app to flutter
  static const String sendToFlutter = 'sendToFlutter';

  ///date from native app to flutter
  static const String setDates = 'setDates';

  ///setView called from native aoo
  static const String setView = 'setView';

  ///setPeriods called from native aoo
  static const String setPeriods = 'setPeriods';

  ///set events called from native ios
  static const String setEvents = 'setEvents';

  ///add event called from native app
  static const String addEvent = 'addEvents';

  ///update event called from native app
  static const String updateEvent = 'updateEvent';

  ///deleteEvent called from native app
  static const String deleteEvent = 'deleteEvent';

  ///jumpToCurrentDate
  static const String jumpToCurrentDate = 'jumpToCurrentDate';
}

///class which contain static method name which used to send data to native app

class SendMethods {
  ///onTap method called when user tap on cell with the event
  static const String onTap = 'onTap';

  /// addEvent method called when user tap on empty cell

  static const String addEvent = 'addEvent';

  /// showEvent method called when user tan on cell which have events

  static const String showEvent = 'showEvent';

  ///dateChanged method called when user ch tap on the side strips

  static const String dateChanged = 'dateChanged';

  ///viewChanged called when user change current view from side strips

  static const String viewChanged = 'viewChanged';

  ///eventDragged called when user drag event from one cell to another cell

  static const String eventDragged = 'eventDragged';

  /// showRecord called when user tap on the record button on
  /// the right side strip on tablet view

  static const String showRecord = 'showRecord';
}
