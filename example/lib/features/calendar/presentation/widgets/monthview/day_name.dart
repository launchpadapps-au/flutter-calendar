import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart';
import 'package:flutter/material.dart';

///render dayName for the month view and tern view
class DayName extends StatelessWidget {
  ///dayName constructor
  const DayName({required this.index, Key? key}) : super(key: key);

  /// index of the day
  final int index;

  @override
  Widget build(BuildContext context) =>
      Column(
        children: <Widget>[
          Expanded(
            child: Container(
                height: 15,
                decoration: const BoxDecoration(color: lightGrey),
                child: Center(
                  child: Text(' ${getWeekDay(index)}',
                      style: context.headline1WithNotoSans),
                )),
          )
        ],
      );
}
