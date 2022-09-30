import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/models/resize_model.dart';
import 'package:flutter_calendar/src/widgets/cell.dart';
import 'package:flutter_calendar/src/widgets/hour_cell.dart';
import 'package:flutter_calendar/src/widgets/resizable_cell.dart';
import 'package:flutter_calendar/src/widgets/time_indicator.dart';
import 'package:flutter_calendar/src/widgets/timetable_event.dart';

import '../core/app_log.dart';

/// The [NewSlDayView] widget displays calendar like view of the events
/// that scrolls
class NewSlDayView<T> extends StatefulWidget {
  /// initialize DayView for the calendar
  const NewSlDayView({
    required this.timelines,
    required this.onWillAccept,
    Key? key,
    this.onEventDragged,
    this.controller,
    this.cellBuilder,
    this.headerCellBuilder,
    this.items = const <CalendarEvent<Never>>[],
    this.itemBuilder,
    this.fullWeek = false,
    this.headerHeight = 45,
    this.hourLabelBuilder,
    this.nowIndicatorColor,
    this.showNowIndicator = true,
    this.cornerBuilder,
    this.snapToDay = true,
    this.isCellDraggable,
    this.initialHeight,
    this.onTap,
  }) : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(Period)? cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(DateTime)? headerCellBuilder;

  /// Timetable items to display in the timetable
  final List<CalendarEvent<T>> items;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(
    CalendarEvent<T>,
  )? itemBuilder;

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

  ///function will handle initial height of the event
  final double Function(CalendarEvent<T> event)? initialHeight;

  @override
  State<NewSlDayView<T>> createState() => _NewSlDayViewState<T>();
}

class _NewSlDayViewState<T> extends State<NewSlDayView<T>> {
  double columnWidth = 50;
  TimetableController controller = TimetableController();
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  Color get nowIndicatorColor =>
      widget.nowIndicatorColor ?? Theme.of(context).indicatorColor;
  int? _listenerId;

  List<DateTime> dateRange = <DateTime>[];

  @override
  void initState() {
    controller = widget.controller ?? controller;
    _listenerId = controller.addListener(_eventHandler);
    if (widget.items.isNotEmpty) {
      widget.items.sort((CalendarEvent<T> a, CalendarEvent<T> b) =>
          a.startTime.compareTo(b.startTime));
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
    super.dispose();
  }

  Future<void> _eventHandler(TimetableControllerEvent event) async {
    if (event is TimetableJumpToRequested) {
      await _jumpTo(event.date);
    }

    if (event is TimetableVisibleDateChanged) {
      appLog('visible data changed');
      await adjustColumnWidth();
      //add jump
      return;
    }

    if (event is TimeTableRefresh) {
      log('reloading timetable');
      notifier.value = !notifier.value;
    }
    if (event is TimetableDateChanged) {
      appLog('date changed');
      initDate();
    }
    if (event is TimetableMaxColumnsChanged) {
      appLog('max column changed');
      await adjustColumnWidth();
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
          (element.isBreak ? controller.breakHeight : controller.cellHeight);
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

  ValueNotifier<bool> notifier = ValueNotifier<bool>(false);
  bool isDragEnable(CalendarEvent<T> event) =>
      widget.isCellDraggable == null || widget.isCellDraggable!(event);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;

        return SizedBox(
          height: getTimelineHeight(
              widget.timelines, controller.cellHeight, controller.breakHeight),
          child: PageView.builder(
              controller: pageController,
              padEnds: false,
              onPageChanged: (int value) {
                dateForHeader = dateRange[value];
                headerDateNotifier.value = dateForHeader;
              },
              itemCount: dateRange.length,
              itemBuilder: (BuildContext context, int index) {
                final DateTime date = dateRange[index];
                final List<CalendarEvent<T>> events = widget.items
                    .where((CalendarEvent<T> event) =>
                        DateUtils.isSameDay(date, event.startTime))
                    .toList()
                  ..sort((CalendarEvent<T> a, CalendarEvent<T> b) =>
                      a.startTime.compareTo(b.startTime));
                final DateTime now = DateTime.now();
                final bool isToday = DateUtils.isSameDay(date, now);
                return ValueListenableBuilder<bool>(
                    valueListenable: notifier,
                    builder: (BuildContext context, bool value,
                            Widget? child) =>
                        ListView(
                          children: <Widget>[
                            ValueListenableBuilder<DateTime>(
                                valueListenable: headerDateNotifier,
                                builder: (BuildContext context, DateTime value,
                                        Widget? child) =>
                                    SizedBox(
                                        height: controller.headerHeight,
                                        child: widget.headerCellBuilder!(
                                            dateForHeader))),
                            const Divider(
                              thickness: 2,
                              height: 2,
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: controller.timelineWidth,
                                  height: getTimelineHeight(
                                      widget.timelines,
                                      controller.cellHeight,
                                      controller.breakHeight),
                                  child: Column(
                                    children: <Widget>[
                                      for (Period item in widget.timelines)
                                        HourCell(
                                          controller: controller,
                                          period: item,
                                          hourLabelBuilder:
                                              widget.hourLabelBuilder,
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: size.width - controller.timelineWidth,
                                  height: getTimelineHeight(
                                      widget.timelines,
                                      controller.cellHeight,
                                      controller.breakHeight),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          for (Period period
                                              in widget.timelines)
                                            TimeTableCell<T>(
                                                columnWidth: size.width,
                                                cellBuilder: widget.cellBuilder,
                                                period: period,
                                                isDragEnable: !period.isBreak,
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
                                                  appLog('New period:'
                                                      '${period.toMap}');
                                                  appLog('Dragged '
                                                      'event'
                                                      '${details.data.toMap}');
                                                  final CalendarEvent<T> event =
                                                      details.data;
                                                  final DateTime newStartTime =
                                                      DateTime(
                                                          date.year,
                                                          date.month,
                                                          date.day,
                                                          period.startTime.hour,
                                                          period.startTime
                                                              .minute);
                                                  final DateTime newEndTime =
                                                      DateTime(
                                                          date.year,
                                                          date.month,
                                                          date.day,
                                                          period.endTime.hour,
                                                          period
                                                              .endTime.minute);

                                                  final CalendarEvent<T>
                                                      newEvent =
                                                      CalendarEvent<T>(
                                                          startTime:
                                                              newStartTime,
                                                          endTime: newEndTime,
                                                          eventData:
                                                              event.eventData);

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
                                      for (final CalendarEvent<T> event
                                          in events)
                                        FutureBuilder<ResizeModel>(
                                            future: getParameterForResize(
                                                widget.timelines,
                                                controller.cellHeight,
                                                controller.breakHeight,
                                                event.startTime,
                                                event.endTime),
                                            builder: (
                                              BuildContext context,
                                              AsyncSnapshot<ResizeModel>
                                                  snapshot,
                                            ) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                final ResizeModel resizeModel =
                                                    snapshot.data!;

                                                double height =
                                                    getTimelineHeight(
                                                        widget.timelines,
                                                        controller.cellHeight,
                                                        controller.breakHeight);
                                                final double top =
                                                    resizeModel.top;
                                                final double bottom =
                                                    resizeModel.bottom;

                                                height = height - bottom - top;
                                                final double maxVertical =
                                                    resizeModel.isNextPeriodAvl
                                                        ? top +
                                                            height +
                                                            resizeModel
                                                                .maxDargOffset
                                                        : top + height;

                                                final double minVertical =
                                                    resizeModel
                                                            .isPreviousPeriodAvl
                                                        ? top -
                                                            resizeModel
                                                                .minDragOffset
                                                        : top;

                                                log('Top : $top '
                                                    'Bottom : $bottom '
                                                    'Height :$height '
                                                    'Min Resize: $minVertical '
                                                    'Max Resize: $maxVertical');
                                                return ResizableCell(
                                                  isResizable: widget
                                                      .isCellDraggable!(event),
                                                  width: size.width - 60,
                                                  top: top,
                                                  height: height,
                                                  left: 0,
                                                  maxVertical: maxVertical,
                                                  minVertical: minVertical,
                                                  child: TimeTableEvent<T>(
                                                    initialHeight: height,
                                                    isDraggable:
                                                        isDragEnable(event),
                                                    onAcceptWithDetails:
                                                        (DragTargetDetails<
                                                                CalendarEvent<
                                                                    T>>
                                                            details) {
                                                      final CalendarEvent<T>
                                                          myEvents =
                                                          details.data;
                                                      final DateTime newTime =
                                                          DateTime(
                                                              date.year,
                                                              date.month,
                                                              date.day,
                                                              event.startTime
                                                                  .hour,
                                                              event.startTime
                                                                  .minute);
                                                      final DateTime
                                                          newEndTime = DateTime(
                                                              date.year,
                                                              date.month,
                                                              date.day,
                                                              event
                                                                  .endTime.hour,
                                                              event.endTime
                                                                  .minute);
                                                      myEvents
                                                        ..startTime = newTime
                                                        ..endTime = newEndTime;
                                                      widget.onEventDragged!(
                                                          details.data,
                                                          myEvents);
                                                    },
                                                    onWillAccept:
                                                        (CalendarEvent<T>?
                                                                data) =>
                                                            false,
                                                    columnWidth: size.width -
                                                        controller
                                                            .timelineWidth,
                                                    event: event,
                                                    itemBuilder:
                                                        widget.itemBuilder,
                                                  ),
                                                );
                                              }
                                              return Positioned(
                                                width: size.width - 60,
                                                top: getEventMarginFromTop(
                                                    widget.timelines,
                                                    controller.cellHeight,
                                                    controller.breakHeight,
                                                    event.startTime),
                                                bottom:
                                                    getEventMarginFromBottom(
                                                        widget.timelines,
                                                        controller.cellHeight,
                                                        controller.breakHeight,
                                                        event.endTime),
                                                child: TimeTableEvent<T>(
                                                  isDraggable:
                                                      isDragEnable(event),
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
                                                  itemBuilder:
                                                      widget.itemBuilder,
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
                                                TimeIndicator(
                                                    controller: controller,
                                                    columnWidth:
                                                        size.width - 60,
                                                    nowIndicatorColor:
                                                        nowIndicatorColor,
                                                    timelines:
                                                        widget.timelines)),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ));
              }),
        );
      });

  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.linear;

  ///jump to given date
  Future<dynamic> _jumpTo(DateTime date) async {
    if (pageController.hasClients) {
      try {
        final DateTime objectOfDate = dateRange.firstWhere((DateTime now) =>
            now.year == date.year &&
            now.month == date.month &&
            now.day == date.day);

        final int index = dateRange.indexOf(objectOfDate);
        await pageController.animateToPage(index,
            duration: _animationDuration, curve: _animationCurve);
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}
