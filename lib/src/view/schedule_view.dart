import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/core/constants.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/app_log.dart';

/// The [SlScheduleView] widget displays calendar like view of the events
/// that scrolls
class SlScheduleView<T> extends StatefulWidget {
  /// initialize schedule for the calendar
  const SlScheduleView({
    required this.timelines,
    required this.onWillAccept,
    required this.cellBuilder,
    this.backgroundColor = Colors.transparent,
    Key? key,
    this.onEventDragged,
    this.onEventToEventDragged,
    this.isCellDraggable,
    this.controller,
    this.headerCellBuilder,
    this.itemBuilder,
    this.isDraggable = true,
    this.fullWeek = false,
    this.headerHeight = 45,
    this.cellHeight = 51,
    this.hourLabelBuilder,
    this.nowIndicatorColor,
    this.showNowIndicator = true,
    this.cornerBuilder,
    this.snapToDay = true,
    this.heightOfTheCell = 65,
    this.onTap,
  }) : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController<T>? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(DateTime) cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(DateTime)? headerCellBuilder;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(CalendarEvent<T>)? itemBuilder;

  /// Renders hour label given [TimeOfDay] for each hour
  final Widget Function(Period period)? hourLabelBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current)? cornerBuilder;

  /// Snap to hour column. Default is `true`.
  final bool snapToDay;

  ///show now indicator,default is true
  final bool showNowIndicator;

  /// Color of indicator line that shows the current time.

  ///  Default is `Theme.indicatorColor`.
  final Color? nowIndicatorColor;

  /// Full week only

  final bool fullWeek;

  /// height  of the header
  final double headerHeight;

  ///height of the single event or cell
  final double cellHeight;

  ///onTap callback
  final Function(DateTime dateTime, List<CalendarEvent<T>>?)? onTap;

  /// The [SlScheduleView] widget displays calendar like view
  /// of the events that scrolls

  /// list of the timeline
  final List<Period> timelines;

  ///return new and old event
  final Function(CalendarEvent<T> old, CalendarEvent<T> newEvent)?
      onEventDragged;

  ///return existing ,old and new event when used drag and drop
  ///the event on the existing event
  final Function(CalendarEvent<T> existing, CalendarEvent<T> old,
      CalendarEvent<T> newEvent, Period? periodModel)? onEventToEventDragged;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final DragTargetWillAccept<CalendarEvent<T>> onWillAccept;

  ///function will handle if event is draggable
  final bool Function(CalendarEvent<T> event)? isCellDraggable;

  ///bool isDraggable
  final bool isDraggable;

  ///background color
  final Color backgroundColor;

  ///hegiht of cell
  final double heightOfTheCell;

  @override
  State<SlScheduleView<T>> createState() => _SlScheduleViewState<T>();
}

class _SlScheduleViewState<T> extends State<SlScheduleView<T>> {
  final ScrollController dayScrollController = ScrollController();
  double columnWidth = 50;
  TimetableController<T> controller = TimetableController<T>();
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  Color get nowIndicatorColor =>
      widget.nowIndicatorColor ?? Theme.of(context).indicatorColor;
  int? _listenerId;

  List<DateTime> dateRange = <DateTime>[];

  /// Timetable items to display in the timetable
  List<CalendarEvent<T>> items = <CalendarEvent<T>>[];
  StreamController<List<CalendarEvent<T>>> eventNotifier =
      StreamController<List<CalendarEvent<T>>>.broadcast();

  @override
  void initState() {
    controller = widget.controller ?? controller;
    _listenerId = controller.addListener(_eventHandler);
    if (controller.events.isNotEmpty) {
      items = controller.events;
      items.sort((CalendarEvent<T> a, CalendarEvent<T> b) =>
          a.startTime.compareTo(b.startTime));
      eventNotifier.sink.add(items);
    }
    initDate();
    super.initState();
  }

  ///get initial list of dates
  void initDate() {
    appLog('Setting dates');
    final int diff = controller.end.difference(controller.start).inDays;
    dateRange.clear();
    for (int i = 0; i < diff; i++) {
      final DateTime date = controller.start.add(Duration(days: i));
      if (widget.fullWeek) {
        dateRange.add(date);
      } else {
        if (date.weekday > 5) {
        } else {
          dateRange.add(date);
        }
      }
    }
    setState(() {});
  }

  ///get data range
  List<DateTime> getDateRange() {
    final List<DateTime> tempDateRange = <DateTime>[];
    appLog('Setting dates');
    final int diff = controller.end.difference(controller.start).inDays;
    dateRange.clear();
    for (int i = 0; i < diff; i++) {
      final DateTime date = controller.start.add(Duration(days: i));
      if (widget.fullWeek) {
        dateRange.add(date);
      } else {
        if (date.weekday > 5) {
        } else {
          dateRange.add(date);
        }
      }
    }
    return tempDateRange;
  }

  ///return count of periods and break that are overlapping
  List<int> getOverLappingTimeline(TimeOfDay start, TimeOfDay end) {
    const int p = 0;
    const int b = 0;

    appLog('Event P:$p and B:$b');
    return <int>[p, b];
  }

  ///get cell height
  double getCellHeight(List<int> data) =>
      data[0] * controller.cellHeight + data[1] * controller.breakHeight;

  @override
  void dispose() {
    if (_listenerId != null) {
      controller.removeListener(_listenerId!);
    }
    dayScrollController.dispose();
    eventNotifier.close();
    super.dispose();
  }

  Future<void> _eventHandler(TimetableControllerEvent event) async {
    if (event is TimetableJumpToRequested) {
      await _jumpTo(event.date);
    }

    if (event is TimetableVisibleDateChanged) {
      appLog('visible data changed');
      final DateTime prev = controller.visibleDateStart;
      final DateTime now = DateTime.now();

      await _jumpTo(
          DateTime(prev.year, prev.month, prev.day, now.hour, now.minute));
      return;
    }
    if (event is TimetableDateChanged) {
      appLog('date changed');
      initDate();
    }
    if (event is AddEventToTable<T>) {
      List<CalendarEvent<T>> myevents = items;
      final List<CalendarEvent<T>> tempEvetnts = event.events;
      if (event.replace) {
        myevents = tempEvetnts;
      } else {
        myevents.addAll(tempEvetnts);
      }
      items = myevents;
      eventNotifier.sink.add(items);
      log('adding events  ${items.length}');
    }

    if (event is RemoveEventFromCalendar<T>) {
      if (items.isNotEmpty) {
        for (final CalendarEvent<T> element in event.events) {
          if (items.contains(element)) {
            items.remove(element);
          }
        }
        eventNotifier.sink.add(items);
        log('total events  ${items.length}');
      }
    }
    if (event is UpdateEventInCalendar<T>) {
      log('updating calendar');

      if (items.contains(event.oldEvent)) {
        final int index = items.indexOf(event.oldEvent);
        items
          ..removeAt(index)
          ..insert(index, event.newEvent);
      } else {
        log('old event is not present in the list');
      }

      eventNotifier.sink.add(items);
      log('total events  ${items.length}');
    }
    if (event is TimeTableSave) {
      ///impliment timetable sabe
    }
    if (event is TimetableJumpToRequested) {
      log('jumping to ${event.date}');
      await _jumpTo(event.date);
    }
    if (mounted) {
      setState(() {});
    }
  }

  double maxColumn = 5;

  bool isSavingTimeTable = false;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) => Container(
            color: widget.backgroundColor,
            child: StreamBuilder<List<CalendarEvent<T>>>(
                stream: eventNotifier.stream,
                builder: (BuildContext context,
                        AsyncSnapshot<List<CalendarEvent<T>>> snapshot) =>
                    ListView.separated(
                        controller: dayScrollController,
                        padding: EdgeInsets.zero,
                        physics: isSavingTimeTable
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        itemCount: dateRange.length,
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                              height: 3,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final DateTime date = dateRange[index];
                          final List<CalendarEvent<T>> events = items
                              .where((CalendarEvent<T> event) =>
                                  DateUtils.isSameDay(date, event.startTime))
                              .toList();

                          return ListTile(
                            key: Key(date.toString().substring(0, 10)),
                            onTap: () {
                              if (widget.onTap != null) {
                                widget.onTap!(
                                    date, events.isEmpty ? null : events);
                              }
                            },
                            leading: widget.headerCellBuilder!(date),
                            title: events.isEmpty
                                ? DragTarget<CalendarEvent<T>>(
                                    onWillAccept: (CalendarEvent<T>? data) =>
                                        widget.onWillAccept(data),
                                    onAcceptWithDetails:
                                        (DragTargetDetails<CalendarEvent<T>>
                                            details) {
                                      final CalendarEvent<T> event =
                                          details.data;
                                      final DateTime newStartTime = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          event.startTime.hour,
                                          event.startTime.minute);
                                      final DateTime newEndTime = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          event.endTime.hour,
                                          event.endTime.minute);

                                      final CalendarEvent<T> newEvent =
                                          CalendarEvent<T>(
                                              startTime: newStartTime,
                                              endTime: newEndTime,
                                              eventData: event.eventData);

                                      widget.onEventDragged!(
                                          details.data, newEvent);
                                    },
                                    builder: (BuildContext content,
                                            List<Object?> obj,
                                            List<dynamic> data) =>
                                        widget.cellBuilder(date))
                                : Column(
                                    children: events
                                        .map((CalendarEvent<T> e) => DragTarget<
                                                CalendarEvent<T>>(
                                            onWillAccept: (CalendarEvent<T>? data) =>
                                                widget.onWillAccept(data),
                                            onAcceptWithDetails:
                                                (DragTargetDetails<CalendarEvent<T>>
                                                    details) {
                                              final CalendarEvent<T> event =
                                                  details.data;
                                              final DateTime newStartTime =
                                                  DateTime(
                                                      date.year,
                                                      date.month,
                                                      date.day,
                                                      event.startTime.hour,
                                                      event.startTime.minute);
                                              final DateTime newEndTime =
                                                  DateTime(
                                                      date.year,
                                                      date.month,
                                                      date.day,
                                                      event.endTime.hour,
                                                      event.endTime.minute);

                                              final CalendarEvent<T> newEvent =
                                                  CalendarEvent<T>(
                                                      startTime: newStartTime,
                                                      endTime: newEndTime,
                                                      eventData:
                                                          event.eventData);

                                              widget.onEventToEventDragged!(e,
                                                  details.data, newEvent, null);
                                            },
                                            builder: (BuildContext content,
                                                    List<Object?> obj,
                                                    List<dynamic> data) =>
                                                Draggable<CalendarEvent<T>>(
                                                    ignoringFeedbackSemantics: false,
                                                    data: e,
                                                    maxSimultaneousDrags: widget.isCellDraggable == null
                                                        ? 1
                                                        : widget.isCellDraggable!(e)
                                                            ? 1
                                                            : 0,
                                                    childWhenDragging: widget.cellBuilder(date),
                                                    feedback: Material(child: widget.itemBuilder!(e)),
                                                    child: widget.itemBuilder!(e))))
                                        .toList()),
                          );
                        })),
          ));

  // bool _isSnapping = false;

  // Future<dynamic> _snapToCloset() async {
  //   if (_isSnapping || !widget.snapToDay) {
  //     return;
  //   }

  //   _isSnapping = true;
  //   await Future<dynamic>.microtask(() => null);
  //   final double snapPosition =
  //       ((_dayScrollController.offset) / columnWidth).round() * columnWidth;
  //   await _dayScrollController.animateTo(
  //     snapPosition,
  //     duration: _animationDuration,
  //     curve: _animationCurve,
  //   );
  //   _isSnapping = false;
  // }

  // Future<dynamic> _updateVisibleDate() async {
  //   final DateTime date = controller.start.add(Duration(
  //     days: _dayHeadingScrollController.position.pixels ~/ columnWidth,
  //   ));
  //   if (date != controller.visibleDateStart) {
  //     controller.updateVisibleDate(date);
  //     setState(() {});
  //   }
  // }

  Future<dynamic> _jumpTo(DateTime date) async {
    if (dayScrollController.hasClients) {
      final double maxScroll = dayScrollController.position.maxScrollExtent;
      final double intialPosition = dayScrollController.initialScrollOffset;
      final List<DateTime> dates = dateRange
          .where((DateTime element) => element.isBefore(date))
          .toList();
      final double datePosition = dates.length * 65 + (dates.length * 3);
      log('Max scroll $maxScroll');
      log('intial scroll $intialPosition');
      log('scroll positiomn $datePosition');

      await dayScrollController.animateTo(
        datePosition,
        duration: animationDuration,
        curve: animationCurve,
      );
    } else {
      log('No Client for scrolling');
    }
  }
}
