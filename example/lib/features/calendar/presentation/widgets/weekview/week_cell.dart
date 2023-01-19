import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:flutter/material.dart';

///week cell for the week view
class WeekCell extends StatelessWidget {
  ///initilize the week view
  const WeekCell(
      {required this.periodModel,
      required this.breakHeight,
      required this.cellHeight,
      super.key});

  ///cell height and break height of the cell
  final double cellHeight, breakHeight;

  ///Period of the slot
  final PeriodModel periodModel;

  @override
  Widget build(BuildContext context) => Container(
      height: periodModel.isCustomeSlot ? breakHeight : cellHeight,
      decoration: BoxDecoration(
          border: Border.all(color: grey),
          color: periodModel.isAfterSchool || periodModel.isBeforeSchool
              ? Colors.transparent
              : periodModel.isCustomeSlot
                  ? lightGrey
                  : Colors.transparent));
}
