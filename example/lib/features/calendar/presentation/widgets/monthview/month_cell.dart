import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:flutter/material.dart';

///month cell for the month view
class MonthCell extends StatelessWidget {
  ///initilize the week view
  const MonthCell(
      {required this.periodModel,
      required this.breakHeight,
      required this.cellHeight,
      super.key});
      ///cell and break height of the cell
  final double cellHeight, breakHeight;

  ///Period of the slot
  final PeriodModel periodModel;

  @override
  Widget build(BuildContext context) => Container(
        height: periodModel.isCustomeSlot ? breakHeight : cellHeight,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
            color: periodModel.isCustomeSlot
                ? Colors.grey.withOpacity(0.2)
                : Colors.transparent),
      );
}
