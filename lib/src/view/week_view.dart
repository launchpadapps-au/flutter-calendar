import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/constants.dart';
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
    this.onWillAcceptForEvent,
    this.onDateChanged,
    this.columnWidth,
    this.size,
    this.backgroundColor = Colors.transparent,
    Key? key,
    this.onEventDragged,
    this.onEventToEventDragged,
    this.controller,
    this.cellBuilder,
    this.headerCellBuilder,
    this.isCellDraggable,
    this.itemBuilder,
    this.fullWeek = false,
    this.autoScrollDate,
    this.autoScrollDay = DateTime.monday,
    this.headerHeight = 45,
    this.hourLabelBuilder,
    this.nowIndicatorColor,
    this.showNowIndicator = true,
    this.showActiveDateIndicator = true,
    this.cornerBuilder,
    this.snapToDay = true,
    this.onTap,
    this.headerDivideThickness = 2,
  }) : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController<T>? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(Period, DateTime dateTime)? cellBuilder;

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

  ///auto scroll to today. default is true
  final DateTime? autoScrollDate;

  ///auto scroll to today. default is monday,if date is note preset in view then
  ///it will scroll to nearest day
  final int? autoScrollDay;

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

  ///return existing ,old and new event when used drag and drop
  ///the event on the existing event
  final Function(
      CalendarEvent<T> existing,
      CalendarEvent<T> old,
      CalendarEvent<T> newEvent,
      Period? periodModel,
      DateTime dateTime)? onEventToEventDragged;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final bool Function(CalendarEvent<T> event, Period period, DateTime dateTime)
      onWillAccept;

  ///it will use to determine wether event will accept event or not
  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final bool Function(CalendarEvent<T> draggeed, CalendarEvent<T> existing,
      DateTime dateTime)? onWillAcceptForEvent;

  ///function will handle if event is draggable
  final bool Function(CalendarEvent<T> event)? isCellDraggable;

  ///provide callabck when date changed

  final Function(DateTime dateTime)? onDateChanged;

  ///background color
  final Color backgroundColor;

  ///Size of the view
  final Size? size;

  ///header divider thickness
  final double headerDivideThickness;

  @override
  State<SlWeekView<T>> createState() => _SlWeekViewState<T>();
}

class _SlWeekViewState<T> extends State<SlWeekView<T>> {
  final ScrollController timeScrollController = ScrollController();
  double columnWidth = 50;
  TimetableController<T> controller = TimetableController<T>();

  PageController headerController = PageController();
  PageController dayScrolController = PageController();
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  Color get nowIndicatorColor =>
      widget.nowIndicatorColor ?? Theme.of(context).indicatorColor;
  int? _listenerId;

  List<DateTime> dateRange = <DateTime>[];
  DateTime now = DateTime.now();

  /// Timetable items to display in the timetable
  List<CalendarEvent<T>> items = <CalendarEvent<T>>[];
  StreamController<List<CalendarEvent<T>>> eventNotifier =
      StreamController<List<CalendarEvent<T>>>.broadcast();
  static DateTime dateForHeader = DateTime.now();
  DateTime dateTime = DateTime.now();
  IndexedScrollController indexdController = IndexedScrollController();
  IndexedScrollController indexdHeaderController = IndexedScrollController();

  @override
  void initState() {
    controller = widget.controller ?? controller;
    indexdController = IndexedScrollController(
        initialIndex: controller.start.difference(dateTime).inDays);
    indexdHeaderController = IndexedScrollController(
        initialIndex: controller.start.difference(dateTime).inDays);
    setState(() {});

    dayScrolController.addListener(() {
      if (dateTime.year == dateForHeader.year &&
          dateTime.month == dateForHeader.month &&
          dateTime.day == dateForHeader.day) {
      } else {
        dateTime = dateForHeader;
        if (!isScrolling) {
          widget.onDateChanged!(dateTime);
        }
      }
    });

    _listenerId = controller.addListener(_eventHandler);
    if (controller.events.isNotEmpty) {
      items = controller.events;
      items.sort((CalendarEvent<T> a, CalendarEvent<T> b) =>
          a.startTime.compareTo(b.startTime));
      eventNotifier.sink.add(items);
    }
    columnWidth = widget.columnWidth ?? columnWidth;
    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) => adjustColumnWidth());
    initDate();
    super.initState();
  }

  int initialPage = 0;

  int currentPage = 0;

  ///get initial list of dates
  void initDate() {
    dateRange = getDateRange(controller.start, controller.end,
        fullWeek: widget.fullWeek);
    dateForHeader = dateRange[0];

    if (widget.autoScrollDate != null) {
      now = widget.autoScrollDate!;

      if (controller.start.isBefore(now) && controller.end.isAfter(now)) {
        if (widget.fullWeek) {
          initialPage = dateRange.indexOf(DateUtils.dateOnly(now));
          currentPage = initialPage;
          dateForHeader = dateRange[initialPage];
        } else if (now.weekday < DateTime.saturday) {
          initialPage = dateRange.indexOf(DateUtils.dateOnly(now));
          currentPage = initialPage;
          dateForHeader = dateRange[initialPage];
        } else if (now.weekday == DateTime.saturday) {
          initialPage = dateRange.indexOf(
              DateUtils.dateOnly(now.subtract(const Duration(days: 1))));
          currentPage = initialPage;
          dateForHeader = dateRange[initialPage];
          onDateChange(dateForHeader);
        } else if (now.weekday == DateTime.sunday) {
          initialPage = dateRange.indexOf(
              DateUtils.dateOnly(now.subtract(const Duration(days: 2))));
          currentPage = initialPage;
          dateForHeader = dateRange[initialPage];
          onDateChange(dateForHeader);
        }

        setState(() {});
      }
    }

    if (widget.size != null) {
      isMobile = widget.size!.width < 550;
    }
    final double viewport = getViewPortSize(controller.maxColumn,
        isMobile: isMobile, fullWeek: widget.fullWeek);

    appLog('Viewport: $viewport');
    appLog('size ${widget.size}');
    appLog('column width $columnWidth');
    appLog('initial Page $initialPage');
    appLog('max Page ${dateRange.length}');
    dayScrolController =
        PageController(initialPage: initialPage, viewportFraction: viewport);
    headerController =
        PageController(initialPage: initialPage, viewportFraction: viewport);
    dateForHeader = dateRange[initialPage];

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_listenerId != null) {
      controller.removeListener(_listenerId!);
    }
    indexdController.dispose();
    indexdHeaderController.dispose();
    timeScrollController.dispose();
    dayScrolController.dispose();
    headerController.dispose();
    eventNotifier.close();
    super.dispose();
  }

  Future<void> _eventHandler(TimetableControllerEvent event) async {
    appLog('No of events${widget.controller!.events.length}');
    if (event is TimetableJumpToRequested) {
      appLog('jumping to ${event.date}');
      await _jumpTo(event.date);
    } else if (event is TimetableVisibleDateChanged) {
      appLog('visible data changed');
      await adjustColumnWidth();
      indexdController = IndexedScrollController(
          initialIndex: controller.start.difference(dateTime).inDays);
      indexdHeaderController = IndexedScrollController(
          initialIndex: controller.start.difference(dateTime).inDays);
      // await _jumpTo(
      //     DateTime(prev.year, prev.month, prev.day, now.hour, now.minute));
      return;
    } else if (event is TimetableDateChanged) {
      appLog('date changed');
      appLog('date changed');
      final int index = dateTime.difference(controller.start).inDays;
      appLog('Initial Scroll index $index');
      indexdController = IndexedScrollController(
          initialIndex: controller.start.difference(dateTime).inDays);
      setState(() {});
      initDate();
    } else if (event is TimetableMaxColumnsChanged) {
      appLog('max column changed');
      await adjustColumnWidth();
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
      appLog('adding events  ${items.length}');
    } else if (event is RemoveEventFromCalendar<T>) {
      if (items.isNotEmpty) {
        for (final CalendarEvent<T> element in event.events) {
          if (items.contains(element)) {
            items.remove(element);
          }
        }
        eventNotifier.sink.add(items);
        appLog('total events  ${items.length}');
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
    } else if (event is TimetableCellSizeChanged) {
      setState(() {});
    } else if (event is TimeTableSave) {}
    if (mounted) {
      setState(() {});
    }
  }

  bool isMobile = true;

  Future<dynamic> adjustColumnWidth() async {
    final RenderBox? box =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    if (box.hasSize) {
      final Size size = widget.size ?? box.size;
      // size = widget.size ?? size;

      final double layoutWidth = size.width;
      isMobile = layoutWidth < 550;
      final double width = layoutWidth < 550
          ? ((layoutWidth - controller.timelineWidth) / controller.columns)
          : (layoutWidth - controller.timelineWidth) / controller.maxColumn;
      if (width != columnWidth) {
        columnWidth = width;
        final double viewport = getViewPortSize(controller.maxColumn,
            isMobile: isMobile, fullWeek: widget.fullWeek);

        appLog('Viewport 1: $viewport');
        appLog('size ${widget.size}');
        appLog('column width $columnWidth');
        appLog('initial Page $initialPage');

        dayScrolController = PageController(
            initialPage: initialPage, viewportFraction: viewport);
        headerController = PageController(
            initialPage: initialPage, viewportFraction: viewport);
        dateForHeader = dateRange[initialPage];
        await Future<dynamic>.microtask(() => null);
        setState(() {});
      }
    }
  }

  bool isScrolling = false;

  bool isDragEnable(CalendarEvent<T> event) =>
      widget.isCellDraggable == null || widget.isCellDraggable!(event);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints contraints) {
        adjustColumnWidth();
        final Size size = widget.size ?? contraints.biggest;
        final double height = getTimelineHeight(
            widget.timelines, controller.cellHeight, controller.breakHeight);
        return Container(
          color: widget.backgroundColor,
          width: size.width,
          height: size.height,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: widget.headerHeight,
                width: size.width,
                child: Row(
                  children: <Widget>[
                    CornerCell<T>(
                        controller: controller,
                        cornerBuilder: widget.cornerBuilder,
                        headerHeight: widget.headerHeight),
                    SizedBox(
                      width: size.width - controller.timelineWidth,
                      height: widget.headerHeight,
                      child: widget.columnWidth != null
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemExtent: columnWidth,
                              controller: headerController,
                              itemCount: dateRange.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) =>
                                  HeaderCell(
                                    dateTime: dateRange[index],
                                    columnWidth: columnWidth,
                                    headerCellBuilder: widget.headerCellBuilder,
                                  ))
                          : PageView.builder(
                              controller: headerController,
                              itemCount: dateRange.length,
                              pageSnapping: widget.snapToDay,
                              onPageChanged: (int value) {
                                if (widget.onDateChanged != null) {
                                  final int dif = isMobile ? 1 : 2;
                                  if (value > currentPage) {
                                    dateForHeader = dateRange[value + dif];
                                  } else {
                                    dateForHeader = dateRange[value - dif];
                                  }
                                  currentPage = value;
                                  onDateChange(dateForHeader);
                                }
                              },
                              itemBuilder: (BuildContext context, int index) =>
                                  HeaderCell(
                                    dateTime: dateRange[index],
                                    columnWidth: columnWidth,
                                    headerCellBuilder: widget.headerCellBuilder,
                                  )),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: widget.headerDivideThickness,
                height: widget.headerDivideThickness,
              ),
              SizedBox(
                width: size.width,
                height: size.height -
                    widget.headerHeight -
                    widget.headerDivideThickness,
                child: SingleChildScrollView(
                  controller: timeScrollController,
                  child: SizedBox(
                      height: height,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            height: height,
                            width: controller.timelineWidth,
                            child: Column(
                              children: <Widget>[
                                // SizedBox(height: controller.cellHeight / 2),
                                for (Period item in widget.timelines)
                                  HourCell<T>(
                                    backgroundColor: widget.backgroundColor,
                                    controller: controller,
                                    period: item,
                                    hourLabelBuilder: widget.hourLabelBuilder,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height,
                            width: size.width - controller.timelineWidth,
                            child: NotificationListener<ScrollNotification>(
                              onNotification:
                                  (ScrollNotification notification) {
                                headerController
                                    .jumpTo(notification.metrics.pixels);

                                return false;
                              },
                              child: widget.columnWidth != null
                                  ? ListView.builder(
                                      itemExtent: columnWidth,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: dateRange.length,
                                      controller: dayScrolController,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final DateTime date = dateRange[index];
                                        final DateTime now = DateTime.now();
                                        final bool isToday =
                                            DateUtils.isSameDay(date, now);
                                        final bool showIndicator =
                                            widget.showNowIndicator && isToday;

                                        return buildView(date,
                                            showIndicator: showIndicator);
                                      },
                                    )
                                  : PageView.builder(
                                      itemCount: dateRange.length,
                                      controller: dayScrolController,
                                      pageSnapping: widget.snapToDay,
                                      onPageChanged: (int value) {
                                        if (widget.onDateChanged != null) {
                                          final int dif = isMobile ? 1 : 2;
                                          if (value > currentPage) {
                                            dateForHeader =
                                                dateRange[value + dif];
                                          } else {
                                            dateForHeader =
                                                dateRange[value - dif];
                                          }
                                          currentPage = value;
                                          onDateChange(dateForHeader);
                                        }
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final DateTime date = dateRange[index];
                                        final DateTime now = DateTime.now();
                                        final bool isToday =
                                            DateUtils.isSameDay(date, now);
                                        final bool showIndicator =
                                            widget.showNowIndicator && isToday;

                                        return buildView(date,
                                            showIndicator: showIndicator);
                                      },
                                    ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        );
      });

  Widget buildView(DateTime date, {required bool showIndicator}) =>
      StreamBuilder<List<CalendarEvent<T>>>(
          stream: eventNotifier.stream,
          builder: (BuildContext context,
              AsyncSnapshot<List<CalendarEvent<T>>> snapshot) {
            final List<CalendarEvent<T>> events = items
                .where((CalendarEvent<T> event) =>
                    DateUtils.isSameDay(date, event.startTime))
                .toList();
            final List<List<CalendarEvent<T>>> eventList = getEventList(events);
            return SizedBox(
              width: columnWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      for (Period period in widget.timelines)
                        TimeTableCell<T>(
                            columnWidth: columnWidth,
                            period: period,
                            cellBuilder: widget.cellBuilder,
                            breakHeight: controller.breakHeight,
                            cellHeight: controller.cellHeight,
                            dateTime: date,
                            onTap: (DateTime dateTime, Period p1,
                                CalendarEvent<T>? p2) {
                              appLog('data');
                              widget.onTap!(dateTime, p1, p2);
                            },
                            onAcceptWithDetails:
                                (DragTargetDetails<CalendarEvent<T>> details) {
                              final CalendarEvent<T> event = details.data;
                              final DateTime newStartTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  period.startTime.hour,
                                  period.startTime.minute);
                              final DateTime newEndTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  period.endTime.hour,
                                  period.endTime.minute);

                              event
                                ..startTime = newStartTime
                                ..endTime = newEndTime;

                              final int index = items.indexOf(details.data);

                              items
                                ..removeAt(index)
                                ..insert(index, event);
                              eventNotifier.sink.add(items);

                              widget.onEventDragged!(
                                  details.data, event, period);
                            },
                            onWillAccept:
                                (CalendarEvent<T>? data, Period period) =>
                                    widget.onWillAccept(data!, period, date))
                    ],
                  ),
                  for (final List<CalendarEvent<T>> events in eventList)
                    for (final CalendarEvent<T> event in events)
                      Builder(builder: (BuildContext context) {
                        final double top = getEventMarginFromTop(
                            widget.timelines,
                            controller.cellHeight,
                            controller.breakHeight,
                            event.startTime);
                        final double bottom = getEventMarginFromBottom(
                            widget.timelines,
                            controller.cellHeight,
                            controller.breakHeight,
                            event.endTime);

                        final double maxWidth = columnWidth;
                        final double eventWidth = maxWidth / events.length;
                        final int index = events.indexOf(event);
                        return Positioned(
                          width: maxWidth - index * eventWidth,
                          left: eventWidth * index,
                          top: top,
                          bottom: bottom,
                          child: TimeTableEvent<T>(
                            isDraggable: isDragEnable(event),
                            onAcceptWithDetails:
                                (DragTargetDetails<CalendarEvent<T>> details) {
                              final CalendarEvent<T> myEvents = details.data;
                              final DateTime start = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  event.startTime.hour,
                                  event.startTime.minute);
                              final DateTime end = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  event.endTime.hour,
                                  event.endTime.minute);
                              myEvents
                                ..startTime = start
                                ..endTime = end;
                              final int index = items.indexOf(details.data);

                              items
                                ..removeAt(index)
                                ..insert(index, myEvents);
                              eventNotifier.sink.add(items);

                              widget.onEventToEventDragged!(
                                  event, details.data, myEvents, null, date);
                            },
                            onWillAccept: (CalendarEvent<T>? data) {
                              if (widget.onWillAcceptForEvent != null) {
                                appLog('Event to event drag in day');
                                return widget.onWillAcceptForEvent!(
                                    data!, event, date);
                              } else {
                                return true;
                              }
                            },
                            columnWidth: columnWidth,
                            event: event,
                            itemBuilder: (CalendarEvent<T> p0) =>
                                widget.itemBuilder!(
                                    p0, maxWidth - index * eventWidth),
                          ),
                        );
                      }),
                  if (showIndicator)
                    StreamBuilder<DateTime>(
                        stream: Stream<DateTime>.periodic(
                            const Duration(seconds: 60),
                            (int count) =>
                                DateTime.now().add(const Duration(minutes: 1))),
                        builder: (BuildContext context,
                                AsyncSnapshot<DateTime> snapshot) =>
                            TimeIndicator<T>(
                                controller: controller,
                                columnWidth: columnWidth,
                                nowIndicatorColor: nowIndicatorColor,
                                timelines: widget.timelines)),
                ],
              ),
            );
          });

  ///jump to given date
  Future<dynamic> _jumpTo(DateTime date) async {
    if (dayScrolController.hasClients) {
      isScrolling = true;
      final double hourPosition = getTimeIndicatorFromTop(
          widget.timelines, controller.cellHeight, controller.breakHeight);
      final double height = getTimelineHeight(
          widget.timelines, controller.cellHeight, controller.breakHeight);

      final double maxScroll = timeScrollController.position.maxScrollExtent;
      final double scrollTo = hourPosition * maxScroll / height;
      appLog('height $height hour $hourPosition '
          'max $maxScroll scrollTo $scrollTo');

      try {
        if (date.isAfter(controller.start) && date.isBefore(controller.end)) {
          final DateTime dateOnly = DateUtils.dateOnly(date);
          if (dateRange.contains(dateOnly)) {
            isScrolling = true;
            final int index = dateRange.indexOf(dateOnly);
            await (dayScrolController.animateToPage(index,
                    curve: animationCurve, duration: animationDuration))
                .then((dynamic value) {
              isScrolling = false;
            });
          }
        }
      } on Exception catch (e) {
        appLog(e.toString());
      }
    }
  }

  /// proivde callback when date changed
  void onDateChange(DateTime dateTime) {
    if (widget.onDateChanged != null) {
      widget.onDateChanged!(dateTime);
    }
  }
}

///Scrolll config for the date
class DateScrollConfig {
  ///initialize the config
  DateScrollConfig(this.dateTime, this.nearDay);

  ///retur the now date with monday
  factory DateScrollConfig.now() =>
      DateScrollConfig(DateTime.now(), DateTime.monday);

  ///on this date view will be auto sroll
  DateTime dateTime;

  ///if date is not present in the list then it will scroll to nearest day
  int nearDay;
}
