import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:flutter/material.dart';

///draw grey border

class CellBorder extends StatelessWidget {
  ///CellBorder
  const CellBorder({
    required this.cellHeight,
    this.borderRadius = 6,
    this.borderWidth = 0.5,
    this.borderColor,
    this.color,
    this.border,
    Key? key,
  }) : super(key: key);

  /// cell height
  final double cellHeight;

  ///border radius
  final double borderRadius;

  ///border width
  final double borderWidth;

  ///border color
  final Color? borderColor;

  ///background color of the cell

  final Color? color;

  ///custom border
  final Border? border;

  @override
  Widget build(BuildContext context) => Container(
        height: cellHeight,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius:
                border == null ? BorderRadius.circular(borderRadius) : null,
            border: border ??
                Border.all(
                    color: borderColor ?? Colors.grey.withOpacity(0.5),
                    width: borderWidth),
            color: color ?? lightGrey),
      );
}
