import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

/// Current time indicator widget
class TimeIndicator<T> extends StatelessWidget {
  ///initialized timeIndicator
  const TimeIndicator({
    required this.controller,
    required this.columnWidth,
    required this.nowIndicatorColor,
    required this.timelines,
    Key? key,
  }) : super(key: key);

  ///timetable controller
  final TimetableController<T> controller;

  ///column width
  final double columnWidth;

  ///color of the indicator
  final Color nowIndicatorColor;

  /// timeline of the calendar
  final List<Period> timelines;

  @override
  Widget build(BuildContext context) => Positioned(
        top: getTimeIndicatorFromTop(
            timelines, controller.cellHeight, controller.breakHeight),
        width: columnWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              color: nowIndicatorColor,
              height: 2,
              width: columnWidth + 1,
            ),
            Positioned(
              top: -8,
              left: -8,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: nowIndicatorColor),
                height: 16,
                width: 16,
              ),
            ),
          ],
        ),
      );
}
