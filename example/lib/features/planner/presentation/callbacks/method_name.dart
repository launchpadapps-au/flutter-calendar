///send callback when user tap cell
const String onTapMethod = 'onTap';

///class which contain static method names which return data from native aoo
class ReceiveMethods {
  ///data from native app to flutter
  static const String sendToFlutter = 'sendToFlutter';

  ///method using to show loading indcator from the ui
  static const String setLoading = 'setLoading';

  ///date from native app to flutter
  static const String setDates = 'setDates';

  ///setView called from native aoo
  static const String setView = 'setView';

  ///setPeriods called from native aoo
  static const String setPeriods = 'setPeriods';

  ///setTerms called when we recived custom term from the native app fro the
  ///term view
  static const String setTerms = 'setTerms';

  ///set events called from native ios
  static const String setEvents = 'setEvents';

  ///set notes called from native ios
  static const String setNots = 'setNotes';

  ///add event called from native app
  static const String addEvent = 'addEvents';

  ///update event called from native app
  static const String updateEvent = 'updateEvent';

  ///deleteEvent called from native app
  static const String removeEvent = 'removeEvent';

  ///jumpToCurrentDate
  static const String jumpToCurrentDate = 'jumpToCurrentDate';

  ///nextday
  static const String nextDay = 'nextDay';

  ///prvious day
  static const String previousDay = 'previousDay';

  ///next month
  static const String nextMonth = 'nextMonth';

  ///previous month
  static const String previousMonth = 'previousMonth';

  ///next term
  static const String nextTerm = 'nextTerm';

  ///previous term
  static const String previousTerm = 'previousTerm';

  ///next week
  static const String nextWeek = 'nextWeek';

  ///previous week
  static const String previousWeek = 'previousWeek';

  ///set margin from the top in ui
  static const String topMargin = 'topMargin';

  ///end export
  static const String canclePreview = 'canclePreview';

  ///it will start generating preview from selected parameter
  static const String generatePreview = 'generatePreview';

  ///dowanload pdf
  static const String downloadPdf = 'downloadPdf';

  ///it will rest event to state before dragging
  static const String resetEvent = 'resetEvent';
}

///class which contain static method name which used to send data to native app

class SendMethods {
  ///onTap method called when user tap on cell with the event
  static const String checkMethodImpl = 'checkMethodImpl';

  /// addEvent method called when user tap on empty cell

  static const String addEvent = 'addEvent';

  /// showEvent method called when user tan on cell which have events

  static const String showEvent = 'showEvent';

  /// showDuty method called when user tan on cell
  /// which have duty in before of after school slot

  static const String showDuty = 'showDuty';

  ///it will be
  static const String showNonTeachingTime = 'showNonTeachingTime';

  /// showEvent method called when user tan on cell which have events

  static const String visibleDateChanged = 'visibleDateChanged';

  ///dateChanged method called when user ch tap on the side strips

  static const String dateChanged = 'dateChanged';

  ///viewChanged called when user change current view from side strips

  static const String viewChanged = 'viewChanged';

  ///eventDragged called when user drag event from one cell to another cell

  static const String eventDragged = 'eventDragged';

  /// showRecord called when user tap on the record button on
  /// the right side strip on tablet view

  static const String showRecord = 'showRecord';

  /// openDrive called when user tap on the drive button
  static const String openDrive = 'openDrive';

  /// showTodos called when user tap on the Todos button on
  /// the right side strip on tablet view

  static const String showTodos = 'showTodos';

  ///this is newaly generated method for fetching data termwise
  ///specificaly used for edgar planner project
  static const String fetchData = 'fetchData';

  ///this is newaly generated method for fetching notes datewise
  ///specificaly used for edgar planner project
  static const String fetchNotes = 'fetchNotes';

  ///open url
  static const String openUrl = 'openUrl';

  /// [addNote] method called when user tap on empty cell in month view

  static const String addNote = 'addNote';

  /// showEvent method called when user tan on cell which have events

  static const String showNote = 'showNote';

  ///provide callback when generate preview progress
  static const String previewProgress = 'previewProgress';

  ///provide callback when generate export progress
  static const String downloadProgress = 'downloadProgress';
}
