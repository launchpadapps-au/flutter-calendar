import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/cell_border.dart';
import 'package:flutter/material.dart';

///day cell for the week view
class DayCell extends StatelessWidget {
  ///initilize the week view
  const DayCell(
      {required this.periodModel,
      required this.breakHeight,
      required this.cellHeight,
      required this.isMobile,
      super.key});

      ///height and width of the cell
  final double cellHeight, breakHeight;

  ///Period of the slot
  final PeriodModel periodModel;

  ///pass true if mobile
  final bool isMobile;

  @override
  Widget build(BuildContext context) => CellBorder(
      borderWidth: 1,
      borderRadius: 0,
      color: periodModel.isAfterSchool || periodModel.isBeforeSchool
          ? Colors.transparent
          : periodModel.isCustomeSlot
              ? isMobile
                  ? lightGrey
                  : grey
              : Colors.transparent,
      borderColor: grey,
      border: !periodModel.isCustomeSlot
          ? null
          : Border(
              left: isMobile ||
                      periodModel.isAfterSchool ||
                      periodModel.isBeforeSchool
                  ? const BorderSide(
                      color: grey,
                    )
                  : const BorderSide(
                      color: textGrey,
                      width: 5,
                    ),
              top: const BorderSide(
                color: grey,
              ),
              right: const BorderSide(
                color: grey,
              ),
              bottom: const BorderSide(
                color: grey,
              )),
      cellHeight: periodModel.isCustomeSlot ? breakHeight : cellHeight);
}
