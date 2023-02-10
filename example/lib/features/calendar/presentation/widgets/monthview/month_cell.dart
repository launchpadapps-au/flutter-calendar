import 'package:flutter/material.dart';

///month cell for the month view
class MonthCell extends StatelessWidget {
  ///initilize the week view
  const MonthCell({
    required this.size,
    super.key,
  });

  ///cell and break height of the cell
  final Size size;

  @override
  Widget build(BuildContext context) => Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
            color: Colors.transparent),
      );
}
