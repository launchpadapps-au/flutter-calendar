import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';

///header widget for the week view
class WeekHeader extends StatelessWidget {
  ///initialize widget
  const WeekHeader({required this.date, required this.isMobile, super.key});

  ///pass true if mobile
  final bool isMobile;

  ///datetime for date
  final DateTime date;

  @override
  Widget build(BuildContext context) =>
      isMobile
          ? Container(
        color: white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              DateFormat('E').format(date).toUpperCase(),
              style: context.hourLabelMobile.copyWith(
                color: isSameDate(date) ? primaryPink : textBlack,
              ),
            ),
            Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.5),
                    color:
                    isSameDate(date) ? primaryPink : Colors.transparent),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: context.headline2Fw500.copyWith(
                        fontSize: isMobile ? 16 : 24,
                        color: isSameDate(date) ? Colors.white : null),
                  ),
                )),
            const SizedBox(
              height: 2,
            ),
          ],
        ),
      )
          :

      /// Creating a container widget.
      Container(
        color: white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              DateFormat('E').format(date).toUpperCase(),
              style: context.subtitle,
            ),
            Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.5),
                    color:
                    isSameDate(date) ? primaryPink : Colors.transparent),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: context.headline1WithNotoSans.copyWith(
                        color: isSameDate(date) ? Colors.white : null),
                  ),
                )),
            const SizedBox(
              height: 2,
            ),
          ],
        ),
      );
}
