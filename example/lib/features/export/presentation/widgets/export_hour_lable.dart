 
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:flutter/material.dart';

///Export hour lable for the week view
class ExportHourLable extends StatelessWidget {
  ///initilize the widget
  const ExportHourLable(
      {required this.periodModel,
      required this.timelineWidth,
      required this.breakHeight,
      required this.cellHeight,
      required this.isMobile,
      super.key});

  ///pass true if mobile
  final bool isMobile;

  ///Period of the slot
  final PeriodModel periodModel;

  ///width of the timeline
  final double timelineWidth;

  ///cell and break height
  final double cellHeight, breakHeight;
  @override
  Widget build(BuildContext context) {
    final TimeOfDay start = periodModel.startTime;

    final TimeOfDay end = periodModel.endTime;
    return Container(
      height: periodModel.isCustomeSlot ? breakHeight : cellHeight,
      width: timelineWidth,
      decoration: BoxDecoration(
        color: white,
        border: Border.all(
          color: textGrey,
          width: 0.5,
        ),
      ),
      child: periodModel.isAfterSchool || periodModel.isBeforeSchool
          ? const SizedBox.shrink()
          : periodModel.isCustomeSlot
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(periodModel.title ?? '',
                        style: isMobile
                            ? context.hourLabelMobile
                            : context.hourLabelTablet),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(start.format(context).substring(0, 5),
                        style: isMobile
                            ? context.hourLabelMobile
                            : context.hourLabelTablet),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(end.format(context).substring(0, 5),
                        style: isMobile
                            ? context.hourLabelMobile
                            : context.hourLabelTablet),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    // Text(period.id,
                    //     style: isMobile
                    //         ? context.hourLabelMobile
                    //         : context.hourLabelTablet),
                  ],
                ),
    );
  }
}
