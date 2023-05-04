import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/period_model.dart';
import 'package:flutter/material.dart';

///hour lable for the month view
class MonthHourLable extends StatelessWidget {
  ///initilize the widget
  const MonthHourLable({required this.periodModel, super.key});

  ///Period of the slot
  final PeriodModel periodModel;

  @override
  Widget build(BuildContext context) {
    final TimeOfDay start = periodModel.startTime;

    final TimeOfDay end = periodModel.endTime;
    return Container(
      child: periodModel.isCustomeSlot
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(periodModel.title ?? '', style: context.subtitle),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(start.format(context).substring(0, 5),
                    style: context.subtitle),
                const SizedBox(
                  height: 8,
                ),
                Text(end.format(context).substring(0, 5),
                    style: context.subtitle),
              ],
            ),
    );
  }
}
