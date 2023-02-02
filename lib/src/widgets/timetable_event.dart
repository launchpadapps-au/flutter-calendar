import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/app_log.dart';
import 'package:flutter_calendar/src/core/colors.dart';
import 'package:flutter_calendar/src/core/text_styles.dart';

///General time table for testing
class TimeTableEvent<T> extends StatefulWidget {
  /// initialized timeTableEvent
  const TimeTableEvent({
    required this.columnWidth,
    required this.event,
    required this.onWillAccept,
    required this.onAcceptWithDetails,
    this.initialHeight,
    this.toHeightChanged,
    this.onAccept,
    this.isDraggable = true,
    this.onLeave,
    this.onMove,
    this.itemBuilder,
    Key? key,
  }) : super(key: key);

  ///event
  final CalendarEvent<T> event;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(CalendarEvent<T>)? itemBuilder;

  ///column width
  final double columnWidth;

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
  final DragTargetWillAccept<CalendarEvent<T>> onWillAccept;

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

  /// Not doing anything. It is just a placeholder.
  final bool isDraggable;

  ///double toHeight
  final Function(double)? toHeightChanged;

  ///double initialHeight
  final double? initialHeight;

  @override
  State<TimeTableEvent<T>> createState() => _TimeTableEventState<T>();
}

class _TimeTableEventState<T> extends State<TimeTableEvent<T>> {
  bool isSlotAvailable = false;

  @override
  Widget build(BuildContext context) => DragTarget<CalendarEvent<T>>(
        builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
        ) =>
            Draggable<CalendarEvent<T>>(
          data: widget.event,
          maxSimultaneousDrags: widget.isDraggable ? 1 : 0,
          ignoringFeedbackSemantics: false,
          feedback: SizedBox(
              width: widget.columnWidth,
              height: widget.initialHeight,
              child: BuildEvent<T>(
                  event: widget.event,
                  columnWidth: widget.columnWidth,
                  itemBuilder: widget.itemBuilder)),
          childWhenDragging: Container(
              decoration: BoxDecoration(
                  color: transparent,
                  border: Border.all(width: 2, color: transparent),
                  borderRadius: BorderRadius.circular(6))),
          child: BuildEvent<T>(
              event: widget.event,
              columnWidth: widget.columnWidth,
              itemBuilder: widget.itemBuilder),
        ),
        onAcceptWithDetails: widget.onAcceptWithDetails,
        onWillAccept: (CalendarEvent<T>? data) => widget.onWillAccept(data),
        onAccept: (CalendarEvent<T> data) {
          appLog(data.toMap.toString());
        },
        onLeave: (CalendarEvent<T>? value) {},
        onMove: (DragTargetDetails<CalendarEvent<T>> value) {},
      );

// DragTarget<CalendarEvent<T>>(
//       builder: (
//         BuildContext context,
//         List<dynamic> accepted,
//         List<dynamic> rejected,
//       ) =>
//           Draggable<CalendarEvent<T>>(
//         // Data is the value this Draggable
//         // stores.
//         data: widget.event,
//         maxSimultaneousDrags: widget.isDraggable ? 1 : 0,
//         ignoringFeedbackSemantics: false,

//         feedback: Container(
//             width: widget.columnWidth,
//             height: widget.initialHeight,
//             child: BuildEvent<T>(
//                 event: widget.event,
//                 columnWidth: widget.columnWidth,
//                 itemBuilder: widget.itemBuilder)),
//         childWhenDragging: Container(
//             decoration: BoxDecoration(
//                 color: transparent,
//                 border: Border.all(width: 2, color: transparent),
//                 borderRadius: BorderRadius.circular(6))),
//         child: BuildEvent<T>(
//             event: widget.event,
//             columnWidth: widget.columnWidth,
//             itemBuilder: widget.itemBuilder),
//       ),
//       onAcceptWithDetails: (DragTargetDetails<CalendarEvent<T>> details) {
//         widget.onAcceptWithDetails(details);
//       },
//       onWillAccept: (CalendarEvent<T>? data) => widget.onWillAccept(data),
//       onAccept: (CalendarEvent<dynamic> data) {},
//       onLeave: (CalendarEvent<dynamic>? value) {},
//       onMove: (DragTargetDetails<CalendarEvent<T>> value) {
//         // appLog('On moved');
//       },
//     );
}

///build event widget
class BuildEvent<T> extends StatelessWidget {
  ///
  const BuildEvent({
    required this.event,
    required this.columnWidth,
    this.itemBuilder,
    Key? key,
  }) : super(key: key);

  ///event
  final CalendarEvent<T> event;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(CalendarEvent<T>)? itemBuilder;

  ///column width
  final double columnWidth;

  @override
  Widget build(BuildContext context) => itemBuilder != null
      ? Card(
          color: transparent,
          margin: const EdgeInsets.all(0),
          borderOnForeground: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          child: itemBuilder!(event))
      : Container(
          width: columnWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          child: Text(
            '${dateFormat.format(event.startTime)}'
            '- ${dateFormat.format(event.endTime)}',
            style: context.subtitle1,
          ),
        );
}
