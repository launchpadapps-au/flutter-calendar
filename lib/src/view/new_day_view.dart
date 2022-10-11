import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/core/constants.dart';
import 'package:flutter_calendar/src/widgets/hour_cell.dart';
import 'package:flutter_calendar/src/widgets/time_indicator.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/widgets/cell.dart';
import 'package:flutter_calendar/src/widgets/timetable_event.dart';

import '../core/app_log.dart';

/// The [NewSlDayView] widget displays calendar like view of the events
/// that scrolls
class NewSlDayView<T> extends StatefulWidget {
  /// initialize DayView for the calendar
  const NewSlDayView({
    required this.timelines,
    required this.onWillAccept,
    required this.onImageCapture,
    this.backgroundColor = Colors.transparent,
    Key? key,
    this.onEventDragged,
    this.controller,
    this.cellBuilder,
    this.headerCellBuilder,
    this.itemBuilder,
    this.fullWeek = false,
    this.headerHeight = 45,
    this.hourLabelBuilder,
    this.nowIndicatorColor,
    this.headerTitleBuilder,
    this.headerDecoration,
    this.showNowIndicator = true,
    this.cornerBuilder,
    this.snapToDay = true,
    this.isCellDraggable,
    this.infiteScrolling = false,
    this.onDateChanged,
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
  /// First [CalendarEvent<T>] is event object for render
  /// Second [int] is index of event if multiple event has same timeslot
  /// Third [int] is no of events if multiple event has same timeslot
  /// Third [double] width of current event ,can be use as refrence to render /
  /// multiple event in single timeslot
  final Widget Function(
      CalendarEvent<T> event, int index, int length, double width)? itemBuilder;

  /// Renders hour label given [TimeOfDay] for each hour
  final Widget Function(Period period)? hourLabelBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current)? cornerBuilder;

  /// Renders widget on the right side of the date
  final Widget Function(DateTime current)? headerTitleBuilder;

  /// decoration of the heade
  final BoxDecoration Function(DateTime current)? headerDecoration;

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

  ///OnTap callback
  final Function(DateTime dateTime, Period, CalendarEvent<T>?)? onTap;

  /// The [NewSlDayView] widget displays calendar like view
  /// of the events that scrolls

  /// list of the timeline
  final List<Period> timelines;

  ///return new and okd event
  final Function(CalendarEvent<T> old, CalendarEvent<T> newEvent)?
      onEventDragged;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final Function(CalendarEvent<T>, DateTime, Period) onWillAccept;

  ///function will handle if event is draggable
  final bool Function(CalendarEvent<T> event)? isCellDraggable;

  ///callback on when image capture
  final Function(Uint8List data) onImageCapture;

  ///background color
  final Color backgroundColor;

  ///bool infinate scrolling
  final bool infiteScrolling;

  ///give new day when day is scrolled
  final Function(DateTime dateTime)? onDateChanged;
  @override
  State<NewSlDayView<T>> createState() => _NewSlDayViewState<T>();
}

class _NewSlDayViewState<T> extends State<NewSlDayView<T>> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => adjustColumnWidth());
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
    dateForHeader = dateRange[0];
    if (mounted) {
      setState(() {});
    }
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
    pageController.dispose();
    eventNotifier.close();
    super.dispose();
  }

  Future<void> _eventHandler(TimetableControllerEvent event) async {
    if (event is TimetableJumpToRequested) {
      log('jumping to current date');
      await _jumpTo(event.date);
    }

    if (event is TimetableVisibleDateChanged) {
      appLog('visible data changed');
      await adjustColumnWidth();
      //add jump
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
    if (event is TimeTableSave) {
      ///implimet timetable save
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
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  PageController pageController = PageController();

  static DateTime dateForHeader = DateTime.now();
  ValueNotifier<DateTime> headerDateNotifier =
      ValueNotifier<DateTime>(dateForHeader);

  List<Key> eventKeys = <Key>[];

  Map<Key, double> eventMargin = <Key, double>{};
  bool isSavingTimeTable = false;
  ScrollController timeScrollController = ScrollController();

  // static const int maxPage = 10000;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;

        return Container(
          color: widget.backgroundColor,
          width: isSavingTimeTable ? size.width * dateRange.length : size.width,
          height: getTimelineHeight(
              widget.timelines, controller.cellHeight, controller.breakHeight),
          child: PageView.builder(
              controller: pageController,
              physics: isSavingTimeTable
                  ? const NeverScrollableScrollPhysics()
                  : null,
              onPageChanged: (int index) {
                final DateTime date = widget.infiteScrolling
                    ? controller.start.add(Duration(days: index))
                    : dateRange[index];
                dateForHeader = date;

                headerDateNotifier.value = dateForHeader;
                if (widget.onDateChanged != null) {
                  widget.onDateChanged!(date);
                }
              },
              itemCount: widget.infiteScrolling ? null : dateRange.length,
              itemBuilder: (BuildContext context, int index) {
                log('$index');
                final DateTime date = widget.infiteScrolling
                    ? controller.start.add(Duration(days: index))
                    : dateRange[index];

                final DateTime now = DateTime.now();
                final bool isToday = DateUtils.isSameDay(date, now);

                return ListView(
                  // physics: const NeverScrollableScrollPhysics(),
                  controller: timeScrollController,
                  children: <Widget>[
                    ValueListenableBuilder<DateTime>(
                        valueListenable: headerDateNotifier,
                        builder: (BuildContext context, DateTime value,
                                Widget? child) =>
                            DecoratedBox(
                              decoration: widget.headerDecoration == null
                                  ? const BoxDecoration()
                                  : widget.headerDecoration!(dateForHeader),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: controller.timelineWidth,
                                    height: controller.headerHeight,
                                    child: widget
                                        .headerCellBuilder!(dateForHeader),
                                  ),
                                  widget.headerTitleBuilder == null
                                      ? const SizedBox.shrink()
                                      : SizedBox(
                                          width: size.width -
                                              controller.timelineWidth,
                                          height: controller.headerHeight,
                                          child: widget.headerTitleBuilder!(
                                              dateForHeader),
                                        )
                                ],
                              ),
                            )),
                    const Divider(
                      thickness: 2,
                      height: 2,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: controller.timelineWidth,
                          height: getTimelineHeight(widget.timelines,
                              controller.cellHeight, controller.breakHeight),
                          child: Column(
                            children: <Widget>[
                              for (Period item in widget.timelines)
                                HourCell<T>(
                                  controller: widget.controller!,
                                  period: item,
                                  hourLabelBuilder: widget.hourLabelBuilder,
                                ),
                            ],
                          ),
                        ),
                        StreamBuilder<List<CalendarEvent<T>>>(
                            stream: eventNotifier.stream,
                            builder: (BuildContext context,
                                    AsyncSnapshot<List<CalendarEvent<T>>>
                                        snapshot) =>
                                Builder(builder: (BuildContext context) {
                                  final List<CalendarEvent<T>> events = items
                                      .where((CalendarEvent<T> event) =>
                                          DateUtils.isSameDay(
                                              date, event.startTime))
                                      .toList();
                                  final List<List<CalendarEvent<T>>> eventList =
                                      getEventList(events);
                                  final double height = getTimelineHeight(
                                      widget.timelines,
                                      controller.cellHeight,
                                      controller.breakHeight);
                                  return SizedBox(
                                    width:
                                        size.width - controller.timelineWidth,
                                    height: height,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            for (Period period
                                                in widget.timelines)
                                              TimeTableCell<T>(
                                                  columnWidth: size.width,
                                                  cellBuilder:
                                                      widget.cellBuilder,
                                                  period: period,
                                                  isDragEnable:
                                                      !period.isCustomeSlot,
                                                  breakHeight:
                                                      controller.breakHeight,
                                                  cellHeight:
                                                      controller.cellHeight,
                                                  dateTime: date,
                                                  onTap: (DateTime dateTime,
                                                      Period p1,
                                                      CalendarEvent<T>? p2) {
                                                    appLog('data');

                                                    widget.onTap!(
                                                        dateTime, p1, p2);
                                                  },
                                                  onAcceptWithDetails:
                                                      (DragTargetDetails<
                                                              CalendarEvent<T>>
                                                          details) {
                                                    final CalendarEvent<T>
                                                        event = details.data;
                                                    final DateTime
                                                        newStartTime = DateTime(
                                                            date.year,
                                                            date.month,
                                                            date.day,
                                                            period
                                                                .startTime.hour,
                                                            period.startTime
                                                                .minute);
                                                    final DateTime newEndTime =
                                                        DateTime(
                                                            date.year,
                                                            date.month,
                                                            date.day,
                                                            period.endTime.hour,
                                                            period.endTime
                                                                .minute);

                                                    final CalendarEvent<T>
                                                        newEvent =
                                                        CalendarEvent<T>(
                                                            startTime:
                                                                newStartTime,
                                                            endTime: newEndTime,
                                                            eventData: event
                                                                .eventData);
                                                    items
                                                      ..remove(details.data)
                                                      ..add(newEvent);
                                                    eventNotifier.sink
                                                        .add(items);
                                                    widget.onEventDragged!(
                                                        details.data, newEvent);
                                                  },
                                                  onWillAccept:
                                                      (CalendarEvent<T>? data,
                                                          Period period) {
                                                    appLog('Dragged event'
                                                        '${data!.toMap}');
                                                    return widget.onWillAccept(
                                                        data, date, period);
                                                  })
                                          ],
                                        ),
                                        for (final List<CalendarEvent<T>> events
                                            in eventList)
                                          for (final CalendarEvent<T> event
                                              in events)
                                            Builder(builder:
                                                (BuildContext context) {
                                              final double top =
                                                  getEventMarginFromTop(
                                                      widget.timelines,
                                                      controller.cellHeight,
                                                      controller.breakHeight,
                                                      event.startTime);
                                              final double bottom =
                                                  getEventMarginFromBottom(
                                                      widget.timelines,
                                                      controller.cellHeight,
                                                      controller.breakHeight,
                                                      event.endTime);
                                              final double initialHeight =
                                                  height - bottom - top;

                                              final double maxWidth =
                                                  size.width - 60;
                                              final double eventWidth =
                                                  maxWidth / events.length;
                                              final int index =
                                                  events.indexOf(event);
                                              return Positioned(
                                                width: maxWidth -
                                                    index * eventWidth,
                                                left: eventWidth * index,
                                                top: top,
                                                bottom: bottom,
                                                child: TimeTableEvent<T>(
                                                  isDraggable: widget
                                                              .isCellDraggable ==
                                                          null ||
                                                      widget.isCellDraggable!(
                                                          event),
                                                  initialHeight: initialHeight,
                                                  onAcceptWithDetails:
                                                      (DragTargetDetails<
                                                              CalendarEvent<T>>
                                                          details) {
                                                    final CalendarEvent<T>
                                                        myEvents = details.data;
                                                    final DateTime
                                                        newStartTime = DateTime(
                                                            date.year,
                                                            date.month,
                                                            date.day,
                                                            event
                                                                .startTime.hour,
                                                            event.startTime
                                                                .minute);
                                                    final DateTime newEndTime =
                                                        DateTime(
                                                            date.year,
                                                            date.month,
                                                            date.day,
                                                            event.endTime.hour,
                                                            event.endTime
                                                                .minute);
                                                    myEvents
                                                      ..startTime = newStartTime
                                                      ..endTime = newEndTime;
                                                    items
                                                      ..remove(details.data)
                                                      ..add(myEvents);
                                                    eventNotifier.sink
                                                        .add(items);
                                                    widget.onEventDragged!(
                                                        details.data, myEvents);
                                                  },
                                                  onWillAccept:
                                                      (CalendarEvent<T>?
                                                              data) =>
                                                          false,
                                                  columnWidth: size.width -
                                                      controller.timelineWidth,
                                                  event: event,
                                                  itemBuilder: (CalendarEvent<T>
                                                          p0) =>
                                                      widget.itemBuilder!(
                                                          p0,
                                                          index,
                                                          events.length,
                                                          size.width -
                                                              controller
                                                                  .timelineWidth),
                                                ),
                                              );
                                            }),
                                        if (widget.showNowIndicator && isToday)
                                          StreamBuilder<DateTime>(
                                              stream: Stream<DateTime>.periodic(
                                                  const Duration(seconds: 60),
                                                  (int count) => DateTime.now()
                                                      .add(const Duration(
                                                          minutes: 1))),
                                              builder: (BuildContext context,
                                                      AsyncSnapshot<DateTime>
                                                          snapshot) =>
                                                  TimeIndicator<T>(
                                                      controller: controller,
                                                      columnWidth:
                                                          size.width - 60,
                                                      nowIndicatorColor:
                                                          nowIndicatorColor,
                                                      timelines:
                                                          widget.timelines)),
                                      ],
                                    ),
                                  );
                                }))
                      ],
                    )
                  ],
                );
              }),
        );
      });

  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.linear;

  ///jump to given date
  Future<dynamic> _jumpTo(DateTime date) async {
    if (widget.infiteScrolling) {
      final int diff = date.difference(controller.start).inDays;

      // final hourPosition =
      //     ((date.hour) * controller.cellHeight) - (controller.cellHeight / 2);
      await Future.wait<dynamic>(<Future<dynamic>>[
        pageController.animateToPage(diff,
            duration: _animationDuration, curve: _animationCurve)
      ]);
    } else {
      if (pageController.hasClients) {
        try {
          final DateTime objectOfDate = dateRange.firstWhere((DateTime now) =>
              now.year == date.year &&
              now.month == date.month &&
              now.day == date.day);

          final int index = dateRange.indexOf(objectOfDate);
          final double hourPosition = getTimeIndicatorFromTop(
              widget.timelines, controller.cellHeight, controller.breakHeight);
          final double height = getTimelineHeight(
              widget.timelines, controller.cellHeight, controller.breakHeight);

          final double maxScroll =
              timeScrollController.position.maxScrollExtent;
          final double scrollTo = hourPosition * maxScroll / height;
          log('height $height hour $hourPosition '
              'max $maxScroll scrollTo $scrollTo');

          await pageController
              .animateToPage(index,
                  duration: animationDuration, curve: animationCurve)
              .then((void value) async {
            await Future<void>.delayed(const Duration(milliseconds: 150))
                .then((void value) => timeScrollController.animateTo(
                      scrollTo,
                      duration: animationDuration,
                      curve: animationCurve,
                    ));
          });
        } on Exception catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }
}
