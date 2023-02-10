// ignore_for_file: prefer_adjacent_string_concatenation

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/widgets/day_cell.dart';

import '../core/app_log.dart';

/// The [SlMonthView] widget displays calendar like view of the events
/// that scrolls
class SlMonthView<T> extends StatefulWidget {
  /// initialize monthView for the calendar
  const SlMonthView(
      {required this.timelines,
      required this.onWillAccept,
      required this.onMonthChanged,
      required this.cellBuilder,
      Key? key,
      this.onEventDragged,
      this.controller,
      this.headerCellBuilder,
      this.itemBuilder,
      this.fullWeek = false,
      this.headerHeight = 45,
      this.hourLabelBuilder,
      this.nowIndicatorColor,
      this.isDraggable = false,
      this.isSwipeEnable = false,
      this.showNowIndicator = true,
      this.deadCellBuilder,
      this.snapToDay = true,
      this.backgroundColor = Colors.transparent,
      this.onTap,
      this.size})
      : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController<T>? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(Size size, CalendarDay calendarDay) cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(int)? headerCellBuilder;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(
      List<CalendarEvent<T>>, Size size, CalendarDay calendarDay)? itemBuilder;

  /// Renders hour label given [TimeOfDay] for each hour
  final Widget Function(Period period)? hourLabelBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current, Size cellSize)? deadCellBuilder;

  /// Snap to hour column. Default is `true`.
  final bool snapToDay;

  ///bool is draggable
  ///
  final bool isDraggable;

  ///final isSwipeEnable
  final bool isSwipeEnable;

  ///show now indicator,default is true
  final bool showNowIndicator;

  ///background color
  final Color backgroundColor;

  /// Color of indicator line that shows the current time.

  ///  Default is `Theme.indicatorColor`.
  final Color? nowIndicatorColor;

  /// Full week only

  final bool fullWeek;

  /// height  of the header
  final double headerHeight;

  ///onTap callback
  final Function(CalendarDay dateTime)? onTap;

  /// The [SlMonthView] widget displays calendar like view
  /// of the events that scrolls

  /// list of the timeline
  final List<Period> timelines;

  ///return new and okd event
  final Function(CalendarEvent<T> old, CalendarEvent<T> newEvent)?
      onEventDragged;

  ///return current month when user swipe and month changed
  final Function(Month) onMonthChanged;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final Function(CalendarEvent<T>, DateTime, Period) onWillAccept;

  ///size of the view that user for export functionality
  final Size? size;

  @override
  State<SlMonthView<T>> createState() => _SlMonthViewState<T>();
}

class _SlMonthViewState<T> extends State<SlMonthView<T>> {
  double columnWidth = 50;
  TimetableController<T> controller = TimetableController<T>();
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  Color get nowIndicatorColor =>
      widget.nowIndicatorColor ?? Theme.of(context).indicatorColor;
  int? _listenerId;

  List<Month> monthRange = <Month>[];
  PageController pageController = PageController();

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
    monthRange = getMonthRange(controller.start, controller.end);
    dateForHeader = monthRange.first.firstDay;
    setState(() {});
    controller.jumpTo(controller.start);
  }

  @override
  void dispose() {
    if (_listenerId != null) {
      controller.removeListener(_listenerId!);
    }
    eventNotifier.close();
    super.dispose();
  }

  Future<void> _eventHandler(TimetableControllerEvent event) async {
    if (event is TimetableJumpToRequested) {
      await _jumpTo(event.date);
    } else if (event is TimetableVisibleDateChanged) {
      appLog('visible data changed');

      return;
    } else if (event is TimetableDateChanged) {
      appLog('date changed');
      initDate();
    } else if (event is TimetableMaxColumnsChanged) {
      appLog('max column changed');
    } else if (event is AddEventToTable<T>) {
      List<CalendarEvent<T>> myevents = items;
      final List<CalendarEvent<T>> tempEvetnts = event.events;
      if (event.replace) {
        myevents = tempEvetnts;
      } else {
        myevents.addAll(tempEvetnts);
      }
      items = myevents;
      eventNotifier.sink.add(items);
      appLog('adding events in monthview:  ${items.length}');
    } else if (event is RemoveEventFromCalendar<T>) {
      if (items.isNotEmpty) {
        for (final CalendarEvent<T> element in event.events) {
          if (items.contains(element)) {
            items.remove(element);
          }
        }
        eventNotifier.sink.add(items);
      }
    } else if (event is UpdateEventInCalendar<T>) {
      appLog('updating calendar');

      if (items.contains(event.oldEvent)) {
        final int index = items.indexOf(event.oldEvent);
        items
          ..removeAt(index)
          ..insert(index, event.newEvent);
      } else {
        appLog('old event is not present in the list');
      }

      eventNotifier.sink.add(items);
      appLog('total events  ${items.length}');
    }
    if (mounted) {
      setState(() {});
    }
  }

  DateTime dateForHeader = DateTime.now();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = widget.size ?? constraints.biggest;
        final double cw = size.width / 7;
        final double columnHeight = (size.height - controller.headerHeight) / 6;
        final double aspectRatio = cw / columnHeight;

        return Container(
          decoration: BoxDecoration(color: widget.backgroundColor),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: controller.headerHeight,
                child: GridView.builder(
                    itemCount: 7,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7),
                    itemBuilder: (BuildContext context, int index) => Column(
                          children: <Widget>[widget.headerCellBuilder!(index)],
                        )),
              ),
              Container(
                height: size.height - controller.headerHeight,
                child: PageView.builder(
                    controller: pageController,
                    padEnds: false,
                    physics: widget.isSwipeEnable
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    onPageChanged: (int value) {
                      widget.onMonthChanged(monthRange[value]);
                    },
                    itemCount: monthRange.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Month month = monthRange[index];
                      final List<CalendarDay> dates =
                          getMonthDates(month);

                      return StreamBuilder<List<CalendarEvent<T>>>(
                          stream: eventNotifier.stream,
                          builder: (BuildContext context,
                                  AsyncSnapshot<List<CalendarEvent<T>>>
                                      snapshot) =>
                              GridView.builder(
                                itemCount: dates.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: aspectRatio,
                                        crossAxisCount: 7),
                                itemBuilder: (BuildContext context, int index) {
                                  final DateTime dateTime =
                                      dates[index].dateTime;
                                  final List<CalendarEvent<T>> events = items
                                      .where((CalendarEvent<T> event) =>
                                          DateUtils.isSameDay(
                                              dateTime, event.startTime))
                                      .toList();
                                  final CalendarDay day = dates[index];

                                  return DayCell<T>(
                                      calendarDay: dates[index],
                                      columnWidth: columnWidth,
                                      cellBuilder: (DateTime dateTime) =>
                                          widget.cellBuilder(
                                              Size(cw, columnHeight), day),
                                      isDraggable: widget.isDraggable,
                                      deadCellBuilder: (DateTime current,
                                              Size cellSize) =>
                                          widget.deadCellBuilder!(
                                              dateTime, Size(cw, columnHeight)),
                                      itemBuilder: (List<CalendarEvent<T>> dayEvents) =>
                                          widget.itemBuilder!(dayEvents,
                                              Size(cw, columnHeight), day),
                                      events: events,
                                      breakHeight: controller.breakHeight,
                                      cellHeight: controller.cellHeight,
                                      dateTime: dateTime,
                                      onTap: (CalendarDay date) {
                                        if (widget.onTap != null) {
                                          widget.onTap!(date);
                                        }
                                      },
                                      onWillAccept:
                                          (CalendarEvent<Object?> e, Period p) =>
                                              true,
                                      onAcceptWithDetails:
                                          (DragTargetDetails<CalendarEvent<T>> details) {
                                        final CalendarEvent<T> event =
                                            details.data;
                                        final DateTime newStartTime = DateTime(
                                            dateTime.year,
                                            dateTime.month,
                                            dateTime.day,
                                            event.startTime.hour,
                                            event.startTime.minute);
                                        final DateTime newEndTime = DateTime(
                                            dateTime.year,
                                            dateTime.month,
                                            dateTime.day,
                                            event.endTime.hour,
                                            event.endTime.minute);

                                        final CalendarEvent<T> newEvent =
                                            CalendarEvent<T>(
                                                startTime: newStartTime,
                                                endTime: newEndTime,
                                                eventData: event.eventData);

                                        widget.onEventDragged!(
                                            details.data, newEvent);
                                      });
                                },
                              ));
                    }),
              ),
            ],
          ),
        );
      });

  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.linear;

  ///jump to given  date
  Future<dynamic> _jumpTo(DateTime date) async {
    if (!pageController.hasClients) {
      return false;
    }
    try {
      final Month month = monthRange.firstWhere((Month element) =>
          element.month == date.month && element.year == date.year);
      await pageController.animateToPage(monthRange.indexOf(month),
          duration: _animationDuration, curve: _animationCurve);
      return true;
    } on StateError catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
