import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/fonts.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart';
import 'package:flutter/material.dart';

///render dayName for the month view and tern view
class ExportMonthHeader extends StatelessWidget {
  ///dayName constructor
  const ExportMonthHeader({required this.index, required this.height, Key? key})
      : super(key: key);

  /// index of the day
  final int index;

  ///height of tile
  final double height;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Container(
              height: height,
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: textGrey)),
              child: Center(
                child: Text(' ${getWeekDay(index)}'.toUpperCase(),
                    style: const TextStyle(
                        fontFamily: Fonts.quickSand,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: darkestGrey)),
              ))
        ],
      );
}
