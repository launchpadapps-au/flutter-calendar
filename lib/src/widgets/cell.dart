import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/app_log.dart';

/// A cell that is used to render the time table.

class TimeTableCell<T> extends StatelessWidget {
  /// initialized the timetable cell for the calendar views
  const TimeTableCell({
    required this.columnWidth,
    required this.period,
    required this.breakHeight,
    required this.cellHeight,
    required this.dateTime,
    required this.onTap,
    required this.onWillAccept,
    required this.onAcceptWithDetails,
    this.isDragEnable = true,
    this.onAccept,
    this.onLeave,
    this.onMove,
    this.cellBuilder,
    Key? key,
  }) : super(key: key);

  /// Renders for the cells the represent each hour that provides
  /// that [DateTime] for that hour
  final Widget Function(Period)? cellBuilder;

  ///column Width
  final double columnWidth;

  ///period
  final Period period;

  ///breakHeight
  final double breakHeight;

  ///cellHeight
  final double cellHeight;

  ///dateTime of the cell
  final DateTime dateTime;

  ///onTap callback function
  final Function(DateTime dateTime, Period, CalendarEvent<T>?)? onTap;

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
  final bool Function(CalendarEvent<T>, Period) onWillAccept;

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

  ///bool true if drag Enable

  final bool isDragEnable;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          appLog('OnTap');
          onTap!(dateTime, period, null);
        },
        child: DragTarget<CalendarEvent<T>>(
          builder: (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ) =>
              SizedBox(
            // color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            //     .withOpacity(1.0),
            // color: Colors.blue,
            width: columnWidth,
            height: period.isCustomeSlot ? breakHeight : cellHeight,
            child: Center(
              child: cellBuilder != null
                  ? cellBuilder!(period)
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                    ),
            ),
          ),
          onAcceptWithDetails: onAcceptWithDetails,
          onWillAccept: (CalendarEvent<T>? data) {
            appLog('Cell  Dragged:${data!.toMap}');
            if (isDragEnable) {
              return onWillAccept(data, period);
            }
            return false;
          },
          onAccept: (CalendarEvent<T> data) {
            appLog(data.toMap.toString());
          },
          onLeave: (CalendarEvent<T>? value) {},
          onMove: (DragTargetDetails<CalendarEvent<T>> value) {},
        ),
      );
}
