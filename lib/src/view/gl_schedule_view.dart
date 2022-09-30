import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/app_log.dart';

/// The [GlScheduleView] widget displays calendar like view of the events
/// that scrolls
class GlScheduleView<T> extends StatefulWidget {
  /// initialize schedule for the calendar
  const GlScheduleView({
    required this.timelines,
    required this.onWillAccept,
    required this.cellBuilder,
    Key? key,
    this.onEventDragged,
    this.isCellDraggable,
    this.controller,
    this.headerCellBuilder,
    this.items = const <CalendarEvent<Never>>[],
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
    this.onTap,
  }) : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(DateTime) cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(DateTime)? headerCellBuilder;

  /// Timetable items to display in the timetable
  final List<CalendarEvent<T>> items;

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

  /// The [GlScheduleView] widget displays calendar like view
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
  final DragTargetWillAccept<CalendarEvent<T>> onWillAccept;

  ///function will handle if event is draggable
  final bool Function(CalendarEvent<T> event)? isCellDraggable;

  ///bool isDraggable
  final bool isDraggable;

  @override
  State<GlScheduleView<T>> createState() => _GlScheduleViewState<T>();
}

class _GlScheduleViewState<T> extends State<GlScheduleView<T>> {
  final ScrollController _dayScrollController = ScrollController();
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
    getDate(controller.start, controller.end, 1);
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
    _dayScrollController.dispose();
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
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) {
        adjustColumnWidth();
        return ListView.separated(
            controller: _dayScrollController,
            padding: EdgeInsets.zero,
            itemCount: dateRange.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(
                  height: 3,
                ),
            itemBuilder: (BuildContext context, int index) {
              final DateTime date = dateRange[index];
              final List<CalendarEvent<T>> events = widget.items
                  .where((CalendarEvent<T> event) =>
                      DateUtils.isSameDay(date, event.startTime))
                  .toList();
              return events.isEmpty
                  ? const SizedBox.shrink()
                  : ListTile(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!(date, events);
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
                                final CalendarEvent<T> event = details.data;
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

                                widget.onEventDragged!(details.data, newEvent);
                              },
                              builder: (BuildContext content, List<Object?> obj,
                                      List<dynamic> data) =>
                                  widget.cellBuilder(date))
                          : Column(
                              children: events
                                  .map((CalendarEvent<T> e) =>
                                      Draggable<CalendarEvent<T>>(
                                          ignoringFeedbackSemantics: false,
                                          data: e,
                                          maxSimultaneousDrags:
                                              widget.isCellDraggable == null
                                                  ? 1
                                                  : widget.isCellDraggable!(e)
                                                      ? 1
                                                      : 0,
                                          childWhenDragging:
                                              widget.cellBuilder(date),
                                          feedback: Material(
                                              child: widget.itemBuilder!(e)),
                                          child: widget.itemBuilder!(e)))
                                  .toList()),
                    );
            });
      });

  // bool _isSnapping = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.linear;

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
    final int index = dateRange.indexOf(dateRange.firstWhere(
        (DateTime element) =>
            element.year == date.year &&
            element.month == date.month &&
            element.day == date.day));
    final double datePosition = 65.0 + 3 * (index + 1);
    if (_dayScrollController.hasClients) {
      await Future.wait<void>(<Future<void>>[
        _dayScrollController.animateTo(
          datePosition,
          duration: _animationDuration,
          curve: _animationCurve,
        ),
      ]);
    }
  }

  void getDate(DateTime firstDate, DateTime endDate, int firstDay) {
    final List<DateTime> dates = <DateTime>[];
    if (firstDate.weekday == firstDay) {
    } else {
      final int dif = firstDate.weekday - firstDay;

      for (int i = firstDate.weekday; i > firstDay; i--) {
        dates.add(firstDate.subtract(Duration(days: -dif)));
      }
    }
    final int diff = endDate.difference(firstDate).inDays;

    for (int i = 0; i < diff; i++) {
      final DateTime date = firstDate.add(Duration(days: i));

      dateRange.add(date);
    }
    final int newDiff = 7 - dateRange.last.weekday;
    for (int i = 0; i < newDiff; i++) {
      final DateTime date = endDate.add(Duration(days: i));

      dateRange.add(date);
    }
    log('Gl Length ${dateRange.length}');
  }
}

///week for schedule view
class Week {
  ///initialized
  Week(this.firstDate, this.lastDate, this.availableDate);

  ///first date
  DateTime firstDate;

  ///last date
  DateTime lastDate;

  ///dates of the week
  List<DateTime> availableDate;
}
