import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/app_log.dart';
import 'package:flutter_calendar/src/core/colors.dart';
import 'package:flutter_calendar/src/core/text_styles.dart';

///DayCell for month and term view
class DayCell<T> extends StatelessWidget {
  /// initialized dayCell
  const DayCell({
    required this.columnWidth,
    required this.breakHeight,
    required this.cellHeight,
    required this.dateTime,
    required this.onTap,
    required this.onWillAccept,
    required this.onAcceptWithDetails,
    required this.calendarDay,
    required this.deadCellBuilder,
    this.dateBuilder,
    this.isDraggable = false,
    this.events,
    this.itemBuilder,
    this.onAccept,
    this.onLeave,
    this.onMove,
    this.cellBuilder,
    Key? key,
  }) : super(key: key);

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(DateTime)? cellBuilder;

  ///column Width
  final double columnWidth;

  ///DateTime date
  final DateTime dateTime;

  ///breakHeight
  final double breakHeight;

  ///cellHeight
  final double cellHeight;

  ///onTap callback function
  final Function(DateTime dateTime)? onTap;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAccept], but with information, including the data, in a
  /// [DragTargetDetails].
  final DragTargetAcceptWithDetails<CalendarEvent<T>> onAcceptWithDetails;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final Function(CalendarEvent<T>, Period) onWillAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAcceptWithDetails], but only includes the data.
  final DragTargetAccept<T>? onAccept;

  /// Called when a given piece of data being dragged over this target leaves
  /// the target.
  final DragTargetLeave<T>? onLeave;

  /// Called when a [Draggable] moves within this [DragTarget].
  ///
  /// Note that this includes entering and leaving the target.
  final DragTargetMove<T>? onMove;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(
    List<CalendarEvent<T>>,
  )? itemBuilder;

  ///rend card for cell that we added extra in the current view

  ///list of the event for day
  final List<CalendarEvent<T>>? events;

  ///bool isDraggable

  final bool isDraggable;

  ///calendar day
  final CalendarDay calendarDay;

  /// Renders upper right corner of the timetable cell
  final Widget Function(DateTime current)? dateBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current) deadCellBuilder;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          appLog('OnTap');
          if (onTap != null) {
            onTap!(dateTime);
          }
        },
        child: isDraggable
            ? DragTarget<CalendarEvent<T>>(
                builder: (
                  BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected,
                ) =>
                    buildCell(context),
                onAcceptWithDetails: onAcceptWithDetails,
                onWillAccept: (CalendarEvent<T>? data) => true,
                onAccept: (CalendarEvent<T> data) {
                  appLog(data.toMap.toString());
                },
                onLeave: (CalendarEvent<T>? value) {},
                onMove: (DragTargetDetails<CalendarEvent<T>> value) {},
              )
            : buildCell(context),
      );

  ///build cell
  Widget buildCell(BuildContext context) => Container(
      color: transparent,
      width: columnWidth,
      height: cellHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Column(
                children: <Widget>[
                  calendarDay.deadCell
                      ? deadCellBuilder(dateTime)
                      : const SizedBox.shrink(),
                ],
              )),
          dateBuilder == null
              ? Positioned(
                  top: 12,
                  right: 12,
                  child: Text(
                    dateTime.day.toString(),
                    style: context.headline1.copyWith(
                      color: calendarDay.deadCell ? greyColor : blackColor,
                      fontSize: 16,
                    ),
                  ))
              : Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: dateBuilder!(dateTime)),
          Center(
            child: cellBuilder != null
                ? cellBuilder!(dateTime)
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
          ),
          calendarDay.deadCell
              ? const SizedBox.shrink()
              : Positioned(child: itemBuilder!(events!))
        ],
      ));
}
