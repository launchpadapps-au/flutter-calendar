import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/app_log.dart';
import 'package:flutter_calendar/src/core/constants.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// The [SlScheduleView] widget displays calendar like view of the events
/// that scrolls
class SlScheduleView<T> extends StatefulWidget {
  /// initialize schedule for the calendar
  const SlScheduleView({
    required this.timelines,
    required this.onWillAccept,
    required this.cellBuilder,
    this.emptyMonthBuilder,
    this.enableEmptyBuilder = false,
    this.emptyTodayTitle,
    this.onDateChanged,
    this.onVisibleDateChanged,
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
    this.showOnlyEventDates = false,
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

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime dateTime)? emptyMonthBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime dateTime)? emptyTodayTitle;

  /// Snap to hour column. Default is `true`.
  final bool snapToDay;

  ///show only event dates
  final bool showOnlyEventDates;

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

  final bool Function(CalendarEvent<T>? event, DateTime dateTime) onWillAccept;

  ///function will handle if event is draggable
  final bool Function(CalendarEvent<T> event)? isCellDraggable;

  ///bool isDraggable
  final bool isDraggable;

  ///background color
  final Color backgroundColor;

  ///bool enable empty builder
  final bool enableEmptyBuilder;

  ///hegiht of cell
  final double heightOfTheCell;

  ///provide callabck when date changed

  final Function(DateTime dateTime)? onDateChanged;

  ///provide callabck when date changed if type if infinite scrolling

  final Function(DateTimeRange dateTimeRange)? onVisibleDateChanged;

  @override
  State<SlScheduleView<T>> createState() => _SlScheduleViewState<T>();
}

class _SlScheduleViewState<T> extends State<SlScheduleView<T>> {
  final ScrollController scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
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
  DateTime dateForHeader = DateTime.now();
  DateTime dateTime = DateTime.now();
  IndexedScrollController indexdController =
      IndexedScrollController(initialIndex: 75);
  late int diff;
  @override
  void initState() {
    controller = widget.controller ?? controller;
    diff = controller.start.difference(dateTime).inDays;
    indexdController = IndexedScrollController(initialIndex: diff);
    setState(() {});
    indexdController.addListener(() {
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
    if (!controller.infiniteScrolling) {
      itemPositionsListener.itemPositions.addListener(() {
        final Iterable<ItemPosition> items =
            itemPositionsListener.itemPositions.value;
        if (items.isNotEmpty) {
          /// Declaring a variable called var.
          DateTime dateTime = dateRange[items.first.index];
          if (dateTime.year == dateForHeader.year &&
              dateTime.month == dateForHeader.month &&
              dateTime.day == dateForHeader.day) {
          } else {
            dateTime = dateForHeader;
            if (!isScrolling) {
              // widget.onDateChanged!(dateTime);
            }
          }
        }
      });
    }
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

  @override
  void dispose() {
    if (_listenerId != null) {
      controller.removeListener(_listenerId!);
    }
    scrollController.dispose();
    indexdController.dispose();
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
      appLog('date changed');
      final int index = dateTime.difference(controller.start).inDays;
      appLog('Initial Scroll index $index');
      indexdController = IndexedScrollController(
          initialIndex: controller.start.difference(dateTime).inDays);
      setState(() {});
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
      emptyIndex = null;
      eventNotifier.sink.add(items);
      appLog('adding events  ${items.length}');
    }

    if (event is RemoveEventFromCalendar<T>) {
      if (items.isNotEmpty) {
        for (final CalendarEvent<T> element in event.events) {
          if (items.contains(element)) {
            items.remove(element);
          }
        }
        emptyIndex = null;
        eventNotifier.sink.add(items);
        appLog('total events  ${items.length}');
      }
    }
    if (event is UpdateEventInCalendar<T>) {
      appLog('updating calendar');

      if (items.contains(event.oldEvent)) {
        final int index = items.indexOf(event.oldEvent);
        items
          ..removeAt(index)
          ..insert(index, event.newEvent);
      } else {
        appLog('old event is not present in the list');
      }
      emptyIndex = null;
      eventNotifier.sink.add(items);
      appLog('total events  ${items.length}');
    }
    if (event is TimeTableSave) {
      ///impliment timetable sabe
    }
    if (event is TimetableJumpToRequested) {
      appLog('jumping to ${event.date}');
      await _jumpTo(event.date);
    }
    if (event is TimetableCellSizeChanged) {
      setState(() {});
    }
    if (mounted) {
      setState(() {});
    }
  }

  double maxColumn = 5;

  bool isSavingTimeTable = false;
  int? emptyIndex;
  bool isScrolling = false;
  final Map<int, GlobalKey<RectGetterState>> _keys =
      <int, GlobalKey<RectGetterState>>{};

  /// Make the entire ListView have the ability to get rect.
  GlobalKey<RectGetterState> listViewKey = RectGetter.createGlobalKey();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      key: _key,
      builder: (BuildContext context, BoxConstraints constraints) => Container(
            color: widget.backgroundColor,
            child: StreamBuilder<List<CalendarEvent<T>>>(
                stream: eventNotifier.stream,
                builder: (BuildContext context,
                        AsyncSnapshot<List<CalendarEvent<T>>> snapshot) =>
                    !controller.infiniteScrolling
                        ? ScrollablePositionedList.separated(
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
                            padding: EdgeInsets.zero,
                            minCacheExtent: 0,
                            itemCount: dateRange.length,
                            physics: isSavingTimeTable
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(
                                      height: 3,
                                    ),
                            itemBuilder: (BuildContext context, int index) {
                              final DateTime date = dateRange[index];
                              dateForHeader = date;

                              final bool isToday =
                                  DateUtils.isSameDay(date, DateTime.now());

                              final List<CalendarEvent<T>> events = items
                                  .where((CalendarEvent<T> event) =>
                                      DateUtils.isSameDay(
                                          date, event.startTime))
                                  .toList();

                              return buildView(date, events, isToday: isToday);
                            })
                        : NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.runtimeType.toString() ==
                                  'ScrollEndNotification') {
                                onScrollEndNotification();
                              }

                              return false;
                            },
                            child: RectGetter(
                              key: listViewKey,
                              child: IndexedListView.separated(
                                  controller: indexdController,
                                  padding: EdgeInsets.zero,
                                  cacheExtent: widget.enableEmptyBuilder
                                      ? items.isEmpty
                                          ? 15
                                          : 0
                                      : 0,
                                  emptyItemBuilder:
                                      (BuildContext context, int index) {
                                    final DateTime date = controller.start
                                        .add(Duration(days: index));
                                    emptyIndex ??= index;
                                    if (widget.enableEmptyBuilder) {
                                      if (widget.onDateChanged != null) {
                                        widget.onDateChanged!(date);
                                      }
                                    }
                                    if (date.day == 1) {
                                      if (index != emptyIndex) {
                                        emptyIndex = index;
                                        return const SizedBox.shrink();
                                      } else if (widget.emptyMonthBuilder !=
                                          null) {
                                        emptyIndex = index;
                                        return widget.emptyMonthBuilder!(date);
                                      }
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                    return null;
                                  },
                                  maxItemCount: widget.enableEmptyBuilder
                                      ? items.isEmpty
                                          ? 0
                                          : null
                                      : null,
                                  minItemCount: widget.enableEmptyBuilder
                                      ? items.isEmpty
                                          ? 0
                                          : null
                                      : null,
                                  physics: isSavingTimeTable
                                      ? const NeverScrollableScrollPhysics()
                                      : null,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(
                                            height: 3,
                                          ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final DateTime date = controller.start
                                        .add(Duration(days: index));
                                    dateForHeader = date;

                                    final bool isToday = DateUtils.isSameDay(
                                        date, DateTime.now());

                                    final List<CalendarEvent<T>> events = items
                                        .where((CalendarEvent<T> event) =>
                                            DateUtils.isSameDay(
                                                date, event.startTime))
                                        .toList();

                                    _keys[index] = RectGetter.createGlobalKey();
                                    return RectGetter(
                                      key: _keys[index]!,
                                      child: buildView(date, events,
                                          isToday: isToday),
                                    );
                                  }),
                            ),
                          )),
          ));

  List<int> getVisible() {
    /// First, get the rect of ListView, and then traver the _keys
    /// get rect of each item by keys in _keys, and if this rect in the range of ListView's rect,
    /// add the index into result list.
    final Rect? rect = RectGetter.getRectFromKey(listViewKey);
    final List<int> _items = <int>[];

    _keys.forEach((dynamic index, dynamic key) {
      final Rect? itemRect = RectGetter.getRectFromKey(key);
      if (itemRect != null &&
          !(itemRect.top > rect!.bottom || itemRect.bottom < rect.top)) {
        _items.add(index + diff);
      } else {
        _items.remove(key);
      }
    });

    /// so all visible item's index are in this _items.
    _items.sort(
      (int a, int b) => a.compareTo(b),
    );

    return _items;
  }

  void onScrollEndNotification() {
    final List<int> index = getVisible();
    final DateTime start = controller.start;

    final DateTime s = start.add(Duration(days: index.first - diff));
    final DateTime e = start.add(Duration(days: index.last - diff));
    if (widget.onVisibleDateChanged != null) {
      widget.onVisibleDateChanged!(DateTimeRange(start: s, end: e));
    }
  }

  Widget buildView(DateTime date, List<CalendarEvent<T>> events,
          {required bool isToday}) =>
      items.isEmpty && widget.enableEmptyBuilder
          ? ListTile(
              leading: widget.headerCellBuilder!(date),
              title: widget.emptyTodayTitle == null
                  ? const Text('Nothing planed for today')
                  : widget.emptyTodayTitle!(date),
            )
          : ListTile(
              onTap: () {
                if (events.isEmpty) {
                  widget.onTap!(date, null);
                }
              },
              key: Key(date.toString().substring(0, 10)),
              leading: widget.headerCellBuilder!(date),
              title: events.isEmpty
                  ? DragTarget<CalendarEvent<T>>(
                      onWillAccept: (CalendarEvent<T>? data) =>
                          widget.onWillAccept(data, date),
                      onAcceptWithDetails:
                          (DragTargetDetails<CalendarEvent<T>> details) {
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

                        event
                          ..startTime = newStartTime
                          ..endTime = newEndTime;

                        final int index = items.indexOf(details.data);

                        items
                          ..removeAt(index)
                          ..insert(index, event);
                        eventNotifier.sink.add(items);

                        widget.onEventDragged!(details.data, event);
                      },
                      builder: (BuildContext content, List<Object?> obj,
                              List<dynamic> data) =>
                          widget.cellBuilder(date))
                  : Column(
                      children: events
                          .map((CalendarEvent<T> e) => DragTarget<
                                  CalendarEvent<T>>(
                              onWillAccept: (CalendarEvent<T>? data) =>
                                  widget.onWillAccept(data, date),
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

                                event
                                  ..startTime = newStartTime
                                  ..endTime = newEndTime;

                                final int index = items.indexOf(details.data);

                                items
                                  ..removeAt(index)
                                  ..insert(index, event);
                                eventNotifier.sink.add(items);
                                widget.onEventToEventDragged!(
                                    e, details.data, event, null);
                              },
                              builder: (BuildContext content, List<Object?> obj,
                                  List<dynamic> data) {
                                appLog('');
                                return Draggable<CalendarEvent<T>>(
                                    ignoringFeedbackSemantics: false,
                                    data: e,
                                    maxSimultaneousDrags: maxDrag(e),
                                    childWhenDragging: widget.cellBuilder(date),
                                    feedback:
                                        Material(child: widget.itemBuilder!(e)),
                                    child: GestureDetector(
                                        onTap: () {
                                          if (widget.onTap != null) {
                                            widget.onTap!(
                                                date, <CalendarEvent<T>>[e]);
                                          }
                                        },
                                        child: widget.itemBuilder!(e)));
                              }))
                          .toList()),
            );

  int maxDrag(CalendarEvent<T> e) => widget.isCellDraggable == null
      ? 1
      : widget.isCellDraggable!(e)
          ? 1
          : 0;

  Future<dynamic> _jumpTo(DateTime date) async {
    if (controller.infiniteScrolling) {
      isScrolling = true;
      await indexdController
          .animateToIndex(date.difference(controller.start).inDays,
              curve: animationCurve)
          .then((dynamic value) {
        isScrolling = false;
      });
    } else {
      try {
        isScrolling = true;
        final DateTime d = dateRange.firstWhere(
            (DateTime element) => DateUtils.isSameDay(date, element));
        final int index = dateRange.indexOf(d);
        await itemScrollController
            .scrollTo(
                index: index,
                duration: animationDuration,
                curve: animationCurve)
            .then((dynamic value) {
          isScrolling = false;
        });
      } on Exception {
        appLog('');
      }
    }
  }
}
