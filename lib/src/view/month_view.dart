// ignore_for_file: prefer_adjacent_string_concatenation

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/widgets/day_cell.dart';

import '../core/app_log.dart';

/// The [SlMonthView] widget displays calendar like view of the events
/// that scrolls
class SlMonthView<T> extends StatefulWidget {
  /// initialize monthView for the calendar
  const SlMonthView({
    required this.timelines,
    required this.onWillAccept,
    required this.onMonthChanged,
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
    this.isDraggable = false,
    this.isSwipeEnable = false,
    this.showNowIndicator = true,
    this.deadCellBuilder,
    this.snapToDay = true,
    this.onTap,
  }) : super(key: key);

  /// [TimetableController] is the controller that also initialize the timetable
  final TimetableController? controller;

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(Period)? cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(int)? headerCellBuilder;

  /// Timetable items to display in the timetable
  final List<CalendarEvent<T>> items;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(List<CalendarEvent<T>>, Size size)? itemBuilder;

  /// Renders hour label given [TimeOfDay] for each hour
  final Widget Function(Period period)? hourLabelBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current)? deadCellBuilder;

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

  @override
  State<SlMonthView<T>> createState() => _SlMonthViewState<T>();
}

class _SlMonthViewState<T> extends State<SlMonthView<T>> {
  double columnWidth = 50;
  TimetableController controller = TimetableController();
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  Color get nowIndicatorColor =>
      widget.nowIndicatorColor ?? Theme.of(context).indicatorColor;
  int? _listenerId;

  List<CalendarDay> dateRange = <CalendarDay>[];
  List<Month> monthRange = <Month>[];
  PageController pageController = PageController();

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
    log('Setting dates in month view');
    final int diff = controller.end.difference(controller.start).inDays;
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
    monthRange = getMonthRange(controller.start, controller.end);
    dateForHeader = dateRange[0].dateTime;
    setState(() {});
    controller.jumpTo(DateTime.now());
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
        dateRange.add(CalendarDay(dateTime: date));
      } else {
        if (date.weekday > 5) {
        } else {
          dateRange.add(CalendarDay(dateTime: date));
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

  DateTime dateForHeader = DateTime.now();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;
        final double cw = size.width / 7;
        final double columnHeight = (size.height - controller.headerHeight) / 5;
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
                child: PageView.builder(
                    controller: pageController,
                    padEnds: false,
                    physics: widget.isSwipeEnable
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    onPageChanged: (int value) {
                      dateForHeader = dateRange[value].dateTime;
                      setState(() {});
                      widget.onMonthChanged(monthRange[value]);
                    },
                    itemCount: monthRange.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Month month = monthRange[index];
                      List<CalendarDay> dates =
                          getDatesForMonth(month, monthRange, dateRange);
                      dates = addPaddingDate(dates);
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: dates.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: aspectRatio, crossAxisCount: 7),
                        itemBuilder: (BuildContext context, int index) {
                          final DateTime dateTime = dates[index].dateTime;
                          final List<CalendarEvent<T>> events = widget.items
                              .where((CalendarEvent<T> event) =>
                                  DateUtils.isSameDay(
                                      dateTime, event.startTime))
                              .toList();
                          return DayCell<T>(
                              calendarDay: dates[index],
                              columnWidth: columnWidth,
                              isDraggable: widget.isDraggable,
                              deadCellBuilder: widget.deadCellBuilder!,
                              itemBuilder: (List<CalendarEvent<T>> dayEvents) =>
                                  widget.itemBuilder!(dayEvents,
                                      Size(columnWidth, columnHeight)),
                              events: events,
                              breakHeight: controller.breakHeight,
                              cellHeight: controller.cellHeight,
                              dateTime: dateTime,
                              onTap: (DateTime date) {
                                if (widget.onTap != null) {
                                  widget.onTap!(date);
                                }
                              },
                              onWillAccept: (CalendarEvent<Object?> event,
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

                                widget.onEventDragged!(details.data, newEvent);
                              });
                        },
                      );
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
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
