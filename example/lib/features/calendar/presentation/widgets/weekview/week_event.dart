import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/url.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///event tile for the week
class WeekEvent extends StatelessWidget {
  ///initilize the week event
  const WeekEvent(
      {required this.item,
      required this.cellHeight,
      required this.breakHeight,
      required this.width,
      required this.periods,
      super.key,
      this.onTap});

  ///event object during week
  final CalendarEvent<EventData> item;

  ///list of periods
  final List<Period> periods;

  ///cell and break height
  final double cellHeight, breakHeight;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, Period?, CalendarEvent<EventData>?)? onTap;

  ///widht of event
  final double width;

  @override
  Widget build(BuildContext context) {
    PeriodModel? periodModel;

    try {
      final Period p = periods
          .firstWhere((Period element) => element.id == item.eventData!.slots);
      periodModel = p as PeriodModel;
    } on Exception {
      periodModel = null;
    }

    Color dutyColor = item.eventData!.color;
    Color borderColor = textGrey;
    if (periodModel != null) {
      if (periodModel.isAfterSchool || periodModel.isBeforeSchool) {
        dutyColor = lightPink;
        borderColor = lightPinkBorder;
      }
    }
    final double margin = item.eventData!.isDutyTime ? 0 : 4;
    final double padding = item.eventData!.isDutyTime ? 0 : 8;
    final double borderRadius = item.eventData!.isDutyTime ? 0 : 4;
    final double borderWidth = item.eventData!.isDutyTime ? 8 : 0;
    final double tileWidth = width - 2 * margin - 2 * padding;
    final bool hideIcon =
        item.eventData!.extraCurricular == null || tileWidth < 34;

    final bool hideCercle = tileWidth < 10;
    return InkWell(
        onTap: () {
          onTap!(item.startTime, null, item);
        },
        child: Container(
          width: width,
          height: cellHeight,
          margin: EdgeInsets.all(margin),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
              color: dutyColor,
              border: item.eventData!.isDutyTime
                  ? Border(
                      left: BorderSide(color: borderColor, width: borderWidth))
                  : null,
              borderRadius: item.eventData!.isDutyTime
                  ? null
                  : BorderRadius.circular(borderRadius)),
          child: item.eventData!.isDuty
              ? SizedBox(
                  height: breakHeight,
                  child: Center(
                      child: Text(
                    item.eventData!.title,
                    style: context.subtitle,
                  )),
                )
              : Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                hideCercle
                                    ? const SizedBox.shrink()
                                    : const Padding(
                                        padding: EdgeInsets.only(top: 3),
                                        child: Icon(
                                          Icons.circle,
                                          color: Colors.black,
                                          size: 6,
                                        ),
                                      ),
                                hideCercle
                                    ? const SizedBox.shrink()
                                    : const SizedBox(
                                        width: 4,
                                      ),
                                Flexible(
                                  child: Text(
                                    item.eventData!.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.eventTitle,
                                  ),
                                ),
                              ],
                            ),
                            item.eventData!.freeTime
                                ? const SizedBox.shrink()
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                          item.eventData!.location ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.eventTitle,
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        )),
                        hideIcon
                            ? const SizedBox.shrink()
                            : Image.network(
                                item.eventData!.extraCurricular!,
                                width: 24,
                                height: 24,
                                errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) =>
                                    const SizedBox.shrink(),
                              )
                      ],
                    ),
                    item.eventData!.freeTime || item.eventData!.isDutyTime
                        ? const SizedBox.shrink()
                        : const Spacer(),
                    item.eventData!.freeTime ||
                            item.eventData!.eventLinks == null ||
                            item.eventData!.eventLinks.toString() == ''
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: () {
                              launchLink(item.eventData!.eventLinks, context);
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                  child: Text(
                                    '${item.eventData!.eventLinks}',
                                    overflow: TextOverflow.ellipsis,
                                    style: context.subtitle,
                                  ),
                                )),
                          )
                  ],
                ),
        ));
  }
}
