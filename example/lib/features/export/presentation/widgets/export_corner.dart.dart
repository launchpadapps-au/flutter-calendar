 
import 'package:flutter/material.dart';
  
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
///Export cell for the week view
class ExportCorner extends StatelessWidget {
  ///initilize the week view
  const ExportCorner({super.key});

  @override
  Widget build(BuildContext context) => Container(
          decoration: BoxDecoration(
        border: Border.all(
          color: textGrey,
          width: 0.5,
        ),
      ));
}
