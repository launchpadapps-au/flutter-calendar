import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/core/constants.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/widgets/cell.dart';
import 'package:flutter_calendar/src/widgets/corner_cell.dart';
import 'package:flutter_calendar/src/widgets/header_cell.dart';
import 'package:flutter_calendar/src/widgets/hour_cell.dart';
import 'package:flutter_calendar/src/widgets/time_indicator.dart';
import 'package:flutter_calendar/src/widgets/timetable_event.dart';

import '../core/app_log.dart';

/// The [SlWeekView] widget displays calendar like view of the events
/// that scrolls
class SlWeekView<T> extends StatefulWidget {
  /// initialize weekView of the cALENDAR
  const SlWeekView({
    required this.timelines,
    required this.onWillAccept,
    this.columnWidth,
    this.size,
    this.backgroundColor = Colors.transparent,
    Key? key,
    this.onEventDragged,
    this.controller,
    this.cellBuilder,
    this.headerCellBuilder,
    this.isCellDraggable,
    this.itemBuilder,
    this.fullWeek = false,
    this.headerHeight = 45,
    this.hourLabelBuilder,
    this.nowIndicatorColor,
    this.showNowIndicator = true,
    this.showActiveDateIndicator = true,
    this.cornerBuilder,
    this.snapToDay = true,
    this.onTap,
  }) : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController<T>? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(Period)? cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(DateTime)? headerCellBuilder;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(CalendarEvent<T>, double width)? itemBuilder;

  /// Renders hour label given [TimeOfDay] for each hour
  final Widget Function(Period period)? hourLabelBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current)? cornerBuilder;

  /// Snap to hour column. Default is `true`.
  final bool snapToDay;

  ///show now indicator,default is true
  final bool showNowIndicator;

  ///show active/current date indicator
  final bool showActiveDateIndicator;

  /// Color of indicator line that shows the current time.

  ///  Default is `Theme.indicatorColor`.
  final Color? nowIndicatorColor;

  /// Full week only

  final bool fullWeek;

  /// height  of the header
  final double headerHeight;

  /// The [SlWeekView] widget displays calendar like view
  /// of the events that scrolls

  /// list of the timeline
  final List<Period> timelines;

  ///double column width
  final double? columnWidth;

  ///onTap
  final Function(DateTime dateTime, Period, CalendarEvent<T>?)? onTap;

  ///return new and okd event

  final Function(
          CalendarEvent<T> old, CalendarEvent<T> newEvent, Period? period)?
      onEventDragged;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final bool Function(CalendarEvent<T>, Period) onWillAccept;

  ///function will handle if event is draggable
  final bool Function(CalendarEvent<T> event)? isCellDraggable;

  ///background color
  final Color backgroundColor;

  ///Size of the view
  final Size? size;
  @override
  State<SlWeekView<T>> createState() => _SlWeekViewState<T>();
}

class _SlWeekViewState<T> extends State<SlWeekView<T>> {
  final ScrollController dayScrollController = ScrollController();
  final ScrollController _dayHeadingScrollController = ScrollController();
  final ScrollController timeScrollController = ScrollController();
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
    columnWidth = widget.columnWidth ?? columnWidth;
    setState(() {});
    controller = widget.controller ?? controller;
    _listenerId = controller.addListener(_eventHandler);

    WidgetsBinding.instance.addPostFrameCallback((_) => adjustColumnWidth());
    initDate();
    super.initState();
  }

  ///get initial list of dates
  void initDate() {
    appLog('Setting dates');
    final int diff = controller.end.difference(controller.start).inDays;
    dateRange.clear();
    for (int i = 0; i <= diff; i++) {
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
  List<int> getOverlappingTimeline(TimeOfDay start, TimeOfDay end) {
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
    _dayHeadingScrollController.dispose();
    timeScrollController.dispose();
    eventNotifier.close();
    super.dispose();
  }

  Future<void> _eventHandler(TimetableControllerEvent event) async {
    log('No of events${widget.controller!.events.length}');
    if (event is TimetableJumpToRequested) {
      appLog('jumping to ${event.date}');
      await _jumpTo(event.date);
    }

    if (event is TimetableVisibleDateChanged) {
      appLog('visible data changed');
      final DateTime prev = controller.visibleDateStart;
      final DateTime now = DateTime.now();
      await adjustColumnWidth();
      await _jumpTo(
          DateTime(prev.year, prev.month, prev.day, now.hour, now.minute));
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
    if (event is TimeTableSave) {}
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
      log('box resize');
      final Size size = widget.size ?? box.size;
      // size = widget.size ?? size;

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

  bool _isTableScrolling = false;
  bool _isHeaderScrolling = false;

  bool isDragEnable(CalendarEvent<T> event) =>
      widget.isCellDraggable == null || widget.isCellDraggable!(event);
  @override
  Widget build(BuildContext context) => Builder(
      key: _key,
      builder: (BuildContext context) {
        adjustColumnWidth();
        final Size size = widget.size ?? MediaQuery.of(context).size;
        log('render box size $size');

        return Container(
          color: widget.backgroundColor,
          width: size.width,
          height: size.height,
          child: Column(
            children: <Widget>[
              Text(items.length.toString()),
              SizedBox(
                height: widget.headerHeight,
                width: size.width,
                child: Row(
                  children: <Widget>[
                    CornerCell<T>(
                        controller: controller,
                        cornerBuilder: widget.cornerBuilder,
                        headerHeight: widget.headerHeight),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (_isTableScrolling) {
                            return false;
                          }
                          if (notification is ScrollEndNotification) {
                            _snapToCloset();
                            // _updateVisibleDate();
                            _isHeaderScrolling = false;
                            return true;
                          }
                          _isHeaderScrolling = true;
                          dayScrollController.jumpTo(
                              _dayHeadingScrollController.position.pixels);
                          return false;
                        },
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: _dayHeadingScrollController,
                          itemExtent: columnWidth,
                          itemCount: dateRange.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context, int index) =>
                              HeaderCell(
                            dateTime: dateRange[index],
                            columnWidth: columnWidth,
                            headerCellBuilder: widget.headerCellBuilder,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                height: 2,
              ),
              Expanded(
                child: ListView(
                  controller: timeScrollController,
                  children: <Widget>[
                    Builder(builder: (BuildContext context) {
                      final double height = getTimelineHeight(widget.timelines,
                          controller.cellHeight, controller.breakHeight);
                      return SizedBox(
                        height: height,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (_isHeaderScrolling) {
                              return false;
                            }

                            if (notification is ScrollEndNotification) {
                              _snapToCloset();

                              _isTableScrolling = false;
                              return true;
                            }
                            _isTableScrolling = true;
                            _dayHeadingScrollController
                                .jumpTo(dayScrollController.position.pixels);
                            return true;
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: controller.timelineWidth,
                                child: Column(
                                  children: <Widget>[
                                    // SizedBox(height: controller.cellHeight / 2),
                                    for (Period item in widget.timelines)
                                      HourCell<T>(
                                        backgroundColor: widget.backgroundColor,
                                        controller: controller,
                                        period: item,
                                        hourLabelBuilder:
                                            widget.hourLabelBuilder,
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  // cacheExtent: 10000.0,

                                  itemCount: dateRange.length,
                                  itemExtent: columnWidth,
                                  controller: dayScrollController,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final DateTime date = dateRange[index];

                                    final DateTime now = DateTime.now();
                                    final bool isToday =
                                        DateUtils.isSameDay(date, now);
                                    final bool showIndicator =
                                        widget.showNowIndicator && isToday;

                                    return StreamBuilder<
                                            List<CalendarEvent<T>>>(
                                        stream: eventNotifier.stream,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<
                                                    List<CalendarEvent<T>>>
                                                snapshot) {
                                          final List<CalendarEvent<T>> events =
                                              items
                                                  .where((CalendarEvent<T>
                                                          event) =>
                                                      DateUtils.isSameDay(date,
                                                          event.startTime))
                                                  .toList();
                                          final List<List<CalendarEvent<T>>>
                                              eventList = getEventList(events);
                                          return SizedBox(
                                            width: columnWidth,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: <Widget>[
                                                Column(
                                                  children: <Widget>[
                                                    for (Period period
                                                        in widget.timelines)
                                                      TimeTableCell<T>(
                                                          columnWidth:
                                                              columnWidth,
                                                          period: period,
                                                          cellBuilder: widget
                                                              .cellBuilder,
                                                          breakHeight:
                                                              controller
                                                                  .breakHeight,
                                                          cellHeight: controller
                                                              .cellHeight,
                                                          dateTime: date,
                                                          onTap: (DateTime
                                                                  dateTime,
                                                              Period p1,
                                                              CalendarEvent<T>?
                                                                  p2) {
                                                            appLog('data');
                                                            widget.onTap!(
                                                                dateTime,
                                                                p1,
                                                                p2);
                                                          },
                                                          onAcceptWithDetails:
                                                              (DragTargetDetails<
                                                                      CalendarEvent<
                                                                          T>>
                                                                  details) {
                                                            final CalendarEvent<
                                                                    T> event =
                                                                details.data;
                                                            final DateTime
                                                                newStartTime =
                                                                DateTime(
                                                                    date.year,
                                                                    date.month,
                                                                    date.day,
                                                                    period
                                                                        .startTime
                                                                        .hour,
                                                                    period
                                                                        .startTime
                                                                        .minute);
                                                            final DateTime
                                                                newEndTime =
                                                                DateTime(
                                                                    date.year,
                                                                    date.month,
                                                                    date.day,
                                                                    period
                                                                        .endTime
                                                                        .hour,
                                                                    period
                                                                        .endTime
                                                                        .minute);

                                                            final CalendarEvent<
                                                                T> newEvent = CalendarEvent<
                                                                    T>(
                                                                startTime:
                                                                    newStartTime,
                                                                endTime:
                                                                    newEndTime,
                                                                eventData: event
                                                                    .eventData);

                                                            widget.onEventDragged!(
                                                                details.data,
                                                                newEvent,
                                                                period);
                                                          },
                                                          onWillAccept:
                                                              (CalendarEvent<T>?
                                                                          data,
                                                                      Period
                                                                          period) =>
                                                                  widget.onWillAccept(
                                                                      data!,
                                                                      period))
                                                  ],
                                                ),
                                                for (final List<
                                                        CalendarEvent<T>> events
                                                    in eventList)
                                                  for (final CalendarEvent<
                                                      T> event in events)
                                                    Builder(builder:
                                                        (BuildContext context) {
                                                      final double top =
                                                          getEventMarginFromTop(
                                                              widget.timelines,
                                                              controller
                                                                  .cellHeight,
                                                              controller
                                                                  .breakHeight,
                                                              event.startTime);
                                                      final double bottom =
                                                          getEventMarginFromBottom(
                                                              widget.timelines,
                                                              controller
                                                                  .cellHeight,
                                                              controller
                                                                  .breakHeight,
                                                              event.endTime);

                                                      final double maxWidth =
                                                          columnWidth;
                                                      final double eventWidth =
                                                          maxWidth /
                                                              events.length;
                                                      final int index =
                                                          events.indexOf(event);
                                                      return Positioned(
                                                        width: maxWidth -
                                                            index * eventWidth,
                                                        left:
                                                            eventWidth * index,
                                                        top: top,
                                                        bottom: bottom,
                                                        child:
                                                            TimeTableEvent<T>(
                                                          isDraggable:
                                                              isDragEnable(
                                                                  event),
                                                          onAcceptWithDetails:
                                                              (DragTargetDetails<
                                                                      CalendarEvent<
                                                                          T>>
                                                                  details) {
                                                            final CalendarEvent<
                                                                    T>
                                                                myEvents =
                                                                details.data;
                                                            final DateTime
                                                                newStartTime =
                                                                DateTime(
                                                                    date.year,
                                                                    date.month,
                                                                    date.day,
                                                                    event
                                                                        .startTime
                                                                        .hour,
                                                                    event
                                                                        .startTime
                                                                        .minute);
                                                            final DateTime newEndTime =
                                                                DateTime(
                                                                    date.year,
                                                                    date.month,
                                                                    date.day,
                                                                    event
                                                                        .endTime
                                                                        .hour,
                                                                    event
                                                                        .endTime
                                                                        .minute);
                                                            myEvents
                                                              ..startTime =
                                                                  newStartTime
                                                              ..endTime =
                                                                  newEndTime;
                                                            final int index =
                                                                items.indexOf(
                                                                    details
                                                                        .data);

                                                            items
                                                              ..removeAt(index)
                                                              ..insert(index,
                                                                  myEvents);

                                                            widget.onEventDragged!(
                                                                details.data,
                                                                myEvents,
                                                                null);
                                                          },
                                                          onWillAccept:
                                                              (CalendarEvent<T>?
                                                                      data) =>
                                                                  true,
                                                          columnWidth:
                                                              columnWidth,
                                                          event: event,
                                                          itemBuilder: (CalendarEvent<
                                                                      T>
                                                                  p0) =>
                                                              widget.itemBuilder!(
                                                                  p0,
                                                                  columnWidth),
                                                        ),
                                                      );
                                                    }),
                                                if (showIndicator)
                                                  StreamBuilder<DateTime>(
                                                      stream: Stream<DateTime>.periodic(
                                                          const Duration(
                                                              seconds: 60),
                                                          (int count) =>
                                                              DateTime.now()
                                                                  .add(const Duration(
                                                                      minutes:
                                                                          1))),
                                                      builder: (BuildContext
                                                                  context,
                                                              AsyncSnapshot<
                                                                      DateTime>
                                                                  snapshot) =>
                                                          TimeIndicator<T>(
                                                              controller:
                                                                  controller,
                                                              columnWidth:
                                                                  columnWidth,
                                                              nowIndicatorColor:
                                                                  nowIndicatorColor,
                                                              timelines: widget
                                                                  .timelines)),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        );
      });

  bool _isSnapping = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.linearToEaseOut;

  Future<dynamic> _snapToCloset() async {
    if (_isSnapping || !widget.snapToDay) {
      return;
    }

    _isSnapping = true;
    await Future<dynamic>.microtask(() => null);
    final double snapPosition =
        ((dayScrollController.offset) / columnWidth).round() * columnWidth;
    await dayScrollController.animateTo(
      snapPosition,
      duration: _animationDuration,
      curve: _animationCurve,
    );
    await _dayHeadingScrollController.animateTo(
      snapPosition,
      duration: _animationDuration,
      curve: _animationCurve,
    );
    _isSnapping = false;
  }

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
    final double datePosition =
        (date.difference(controller.start).inDays) * columnWidth;
    final double hourPosition = getTimeIndicatorFromTop(
        widget.timelines, controller.cellHeight, controller.breakHeight);
    final double height = getTimelineHeight(
        widget.timelines, controller.cellHeight, controller.breakHeight);

    final double maxScroll = timeScrollController.position.maxScrollExtent;
    final double scrollTo = hourPosition * maxScroll / height;
    log('height $height hour $hourPosition max $maxScroll scrollTo $scrollTo');
    await dayScrollController
        .animateTo(
      datePosition,
      duration: animationDuration,
      curve: animationCurve,
    )
        .then((dynamic value) async {
      await Future<void>.delayed(const Duration(milliseconds: 150))
          .then((void value) => timeScrollController.animateTo(
                scrollTo,
                duration: animationDuration,
                curve: animationCurve,
              ));
    });
  }
}
