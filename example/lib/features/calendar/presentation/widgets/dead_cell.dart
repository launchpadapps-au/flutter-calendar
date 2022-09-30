import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/constants.dart';
import 'package:flutter/material.dart';

///it will draw dead cell with angled strips in month and term view
class DeadCell extends StatelessWidget {
  ///DeadCell
  const DeadCell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ClipRRect(
        child: Transform.scale(
          scale: 10,
          child: RotationTransition(
            turns: const AlwaysStoppedAnimation<double>(45 / 360),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 60,
                  itemBuilder: (BuildContext context, int index) =>
                      const Divider(
                        height: subMargin / 10,
                        thickness: 1.65 / 10,
                        color: grey,
                      )),
            ),
          ),
        ),
      );
}
