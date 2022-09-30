import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_calendar/src/core/text_styles.dart';

///Hour Cell widget build the widget for the hour label
class HourCell extends StatelessWidget {
  /// initialized hourCell
  const HourCell(
      {required this.controller,
      required this.period,
      this.backgroundColor = Colors.transparent,
      Key? key,
      this.hourLabelBuilder})
      : super(key: key);

  ///timetable  controller
  final TimetableController controller;

  ///period of the even
  final Period period;

  /// Renders hour label given [TimeOfDay] for each hour
  final Widget Function(Period period)? hourLabelBuilder;

  ///Color background color
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final TimeOfDay start = TimeOfDay(
      hour: period.startTime.hour,
      minute: period.startTime.minute,
    );

    final TimeOfDay end = TimeOfDay(
      hour: period.endTime.hour,
      minute: period.endTime.minute,
    );
    return Container(
        color: backgroundColor,
        height: period.isBreak ? controller.breakHeight : controller.cellHeight,
        child: Center(
            child: hourLabelBuilder != null
                ? hourLabelBuilder!(period)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        start.format(context),
                        style: context.subtitle1,
                      ),
                      Text(end.format(context), style: context.subtitle1),
                    ],
                  )));
  }
}
