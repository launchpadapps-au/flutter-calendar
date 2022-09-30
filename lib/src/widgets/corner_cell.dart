import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

/// Rendeer corner celll,it place beside the header and above the timelines
class CornerCell extends StatelessWidget {
  /// initialized the corner cell
  const CornerCell(
      {required this.controller,
      required this.headerHeight,
      this.cornerBuilder,
      Key? key})
      : super(key: key);

  ///header height
  final double headerHeight;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(DateTime current)? cornerBuilder;

  ///timetable controller
  final TimetableController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: controller.timelineWidth,
        height: headerHeight,
        child: cornerBuilder != null
            ? cornerBuilder!(controller.visibleDateStart)
            : Center(
                child: Text(
                  '${controller.visibleDateStart.year}',
                  textAlign: TextAlign.center,
                ),
              ),
      );
}
