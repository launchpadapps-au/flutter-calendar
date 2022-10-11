// ignore_for_file: prefer_adjacent_string_concatenation

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/widgets/day_cell.dart';

import '../core/app_log.dart';

/// The [SlTermView] widget displays calendar like view of the events
/// that scrolls
class SlTermView<T> extends StatefulWidget {
  /// initialize TermView for the calendar
  const SlTermView({
    required this.timelines,
    required this.onWillAccept,
    required this.onMonthChanged,
    Key? key,
    this.onEventDragged,
    this.controller,
    this.cellBuilder,
    this.headerCellBuilder,
    this.dateBuilder,
    this.itemBuilder,
    this.fullWeek = false,
    this.headerHeight = 45,
    this.nowIndicatorColor,
    this.isDraggable = false,
    this.isSwipeEnable = false,
    this.showNowIndicator = true,
    this.deadCellBuilder,
    this.snapToDay = true,
    this.onTap,
  }) : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController<T>? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(Period)? cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(int)? headerCellBuilder;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(List<CalendarEvent<T>>, Size size, DateTime)?
      itemBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current)? deadCellBuilder;

  /// Renders upper right corner of the timetable cell
  final Widget Function(DateTime current)? dateBuilder;

  /// Snap to hour column. Default is `true`.
  final bool snapToDay;

  ///bool is draggable
  ///
  final bool isDraggable;

  ///final isSwipeEnable
  final bool isSwipeEnable;

  ///show now indicator,default is true
  final bool showNowIndicator;

  /// Color of indicator line that shows the current time.

  ///  Default is `Theme.indicatorColor`.
  final Color? nowIndicatorColor;

  /// Full week only

  final bool fullWeek;

  /// height  of the header
  final double headerHeight;

  ///onTap callback
  final Function(DateTime dateTime)? onTap;

  // ///OnEventCellTap callback
  // final Function(DateTime dateTime, List<CalendarEvent<T>>)? onEventsTap;

  /// The [SlTermView] widget displays calendar like view
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

  @override
  State<SlTermView<T>> createState() => _SlTermViewState<T>();
}

class _SlTermViewState<T> extends State<SlTermView<T>> {
  double columnWidth = 50;
  TimetableController<T> controller = TimetableController<T>();
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  Color get nowIndicatorColor =>
      widget.nowIndicatorColor ?? Theme.of(context).indicatorColor;
  int? _listenerId;

  List<CalendarDay> dateRange = <CalendarDay>[];
  ScrollController scrollController = ScrollController();

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
    WidgetsBinding.instance.addPostFrameCallback((_) => adjustColumnWidth());
    initDate();
    super.initState();
  }

  ///get initial list of dates
  void initDate() {
    log('Setting dates in month view');
    final int diff = controller.end.difference(controller.start).inDays + 1;
    dateRange.clear();
    for (int i = 0; i < diff; i++) {
      final DateTime date = controller.start.add(Duration(days: i));
      if (widget.fullWeek) {
        dateRange.add(CalendarDay(dateTime: date));
      } else {
        if (date.weekday > 5) {
        } else {
          dateRange.add(CalendarDay(dateTime: date));
        }
      }
    }

    dateRange = addPaddingDate(dateRange);
    dateForHeader = dateRange[0].dateTime;
    setState(() {});
    controller.jumpTo(DateTime.now());
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
    eventNotifier.close();
    super.dispose();
  }

  Future<void> _eventHandler(TimetableControllerEvent event) async {
    if (event is TimetableJumpToRequested) {
      await _jumpTo(event.date);
    }

    if (event is TimetableVisibleDateChanged) {
      appLog('visible data changed');
      await adjustColumnWidth();
      return;
    }
    if (event is TimetableDateChanged) {
      appLog('date changed');
      initDate();
    }
    if (event is TimetableMaxColumnsChanged) {
      appLog('max column changed');
      await adjustColumnWidth();
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
    if (mounted) {
      setState(() {});
    }
  }

  double getHeightOfTheEvent(CalendarEvent<dynamic> item) {
    double h = 0;

    final List<Period> periods = <Period>[];

    for (final Period period in widget.timelines) {
      if (period.startTime.hour >= item.startTime.hour) {
        if (period.endTime.hour <= item.endTime.hour) {
          if (period.startTime.minute >= item.startTime.minute) {
            if (period.endTime.minute <= item.endTime.minute) {
              periods.add(period);
            }
          }
        }
      }
    }

    for (final Period element in periods) {
      h = h +
          (element.isCustomeSlot
              ? controller.breakHeight
              : controller.cellHeight);
    }
    return h;
  }

  double maxColumn = 5;

  Future<dynamic> adjustColumnWidth() async {
    final RenderBox? box =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    if (box.hasSize) {
      final Size size = box.size;
      final double layoutWidth = size.width;
      final double width = layoutWidth < 550
          ? ((layoutWidth - controller.timelineWidth) / controller.columns)
          : (layoutWidth - controller.timelineWidth) / controller.maxColumn;
      if (width != columnWidth) {
        columnWidth = width;

        await Future<dynamic>.microtask(() => null);
        setState(() {});
      }
    }
  }

  double columnHeightForScrolling = 0;

  DateTime dateForHeader = DateTime.now();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;

        final double cw = size.width / 7;
        final double columnHeight = (size.height - controller.headerHeight) / 7;
        columnHeightForScrolling = columnHeight;
        final double aspectRatio = cw / columnHeight;
        return SizedBox(
          height: getTimelineHeight(
              widget.timelines, controller.cellHeight, controller.breakHeight),
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
              SizedBox(
                  height: size.height - controller.headerHeight,
                  child: StreamBuilder<List<CalendarEvent<T>>>(
                      stream: eventNotifier.stream,
                      builder: (BuildContext context,
                              AsyncSnapshot<List<CalendarEvent<T>>> snapshot) =>
                          GridView.builder(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            itemCount: dateRange.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: aspectRatio,
                                    crossAxisCount: 7),
                            itemBuilder: (BuildContext context, int index) {
                              final DateTime dateTime =
                                  dateRange[index].dateTime;
                              final List<CalendarEvent<T>> events = items
                                  .where((CalendarEvent<T> event) =>
                                      DateUtils.isSameDay(
                                          dateTime, event.startTime))
                                  .toList();

                              return DayCell<T>(
                                  calendarDay: dateRange[index],
                                  columnWidth: columnWidth,
                                  dateBuilder: widget.dateBuilder,
                                  isDraggable: true,
                                  deadCellBuilder: widget.deadCellBuilder!,
                                  itemBuilder:
                                      (List<CalendarEvent<T>> dayEvents) =>
                                          widget.itemBuilder!(dayEvents,
                                              Size(cw, columnHeight), dateTime),
                                  events: events,
                                  breakHeight: controller.breakHeight,
                                  cellHeight: controller.cellHeight,
                                  dateTime: dateTime,
                                  onTap: (DateTime date) {
                                    if (widget.onTap != null) {
                                      widget.onTap!(date);
                                    }
                                  },
                                  onWillAccept: (CalendarEvent<T?> event,
                                          Period period) =>
                                      true,
                                  onAcceptWithDetails:
                                      (DragTargetDetails<CalendarEvent<T>>
                                          details) {
                                    final CalendarEvent<T> event = details.data;
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
                          ))),
            ],
          ),
        );
      });

  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.linear;

  ///jump to given date
  Future<dynamic> _jumpTo(DateTime date) async {
    if (scrollController.hasClients) {
      try {
        final CalendarDay objectOfCd = dateRange.firstWhere((CalendarDay now) =>
            now.dateTime.year == date.year &&
            now.dateTime.month == date.month &&
            now.dateTime.day == date.day);

        final int index = dateRange.indexOf(objectOfCd);
        final double rm = (index + 1) / 7;

        await scrollController.animateTo(rm * columnHeightForScrolling,
            duration: _animationDuration, curve: _animationCurve);
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}
