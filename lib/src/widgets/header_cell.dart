import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/core/text_styles.dart';
import 'package:intl/intl.dart';

///headerCell widget build the label for the header of the timetable
class HeaderCell extends StatelessWidget {
  ///initialized headerCell
  const HeaderCell({
    required this.dateTime,
    required this.columnWidth,
    Key? key,
    this.headerCellBuilder,
  }) : super(key: key);

  /// Renders for the header that provides the [DateTime] for the day
  final Widget Function(DateTime)? headerCellBuilder;

  /// A variable that is used to store the dateTime.
  final DateTime dateTime;

  /// The width of the column.
  final double columnWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
      width: columnWidth,
      child: headerCellBuilder != null
          ? headerCellBuilder!(dateTime)
          : Center(
              child: Text(
                DateFormat('MMM\nd').format(dateTime),
                style: context.headline1,
                textAlign: TextAlign.center,
              ),
            ));
}
