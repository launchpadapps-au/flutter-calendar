import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/url.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/period_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///event tile for the week
class WeekEvent extends StatefulWidget {
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
  State<WeekEvent> createState() => _WeekEventState();
}

class _WeekEventState extends State<WeekEvent> {
  double margin = 4;
  double padding = 8;
  double borderRadius = 4;
  double borderWidth = 0;
  Color borderColor = textGrey;
  late Color dutyColor;
  late double tileWidth;
  late bool hideIcon;

  late bool hideCircle;

  void setUI() {
    PeriodModel? periodModel;

    try {
      final Period p = widget.periods.firstWhere(
          (Period element) => element.id == widget.item.eventData!.slots);
      periodModel = p as PeriodModel;
    } on StateError {
      periodModel = null;
    }

    dutyColor = widget.item.eventData!.color;
    borderColor = textGrey;
    if (periodModel != null) {
      if (periodModel.isAfterSchool || periodModel.isBeforeSchool) {
        dutyColor = lightPink;
        borderColor = lightPinkBorder;
      }
    }
    margin = widget.item.eventData!.isDutyTime ? 0 : 4;
    padding = widget.item.eventData!.isDutyTime ? 0 : 8;
    borderRadius = widget.item.eventData!.isDutyTime ? 0 : 4;
    borderWidth = widget.item.eventData!.isDutyTime ? 8 : 0;
    tileWidth = widget.width - 2 * margin - 2 * padding;
    hideIcon = widget.item.eventData!.extraCurricular == null || tileWidth < 34;

    hideCircle = tileWidth < 10;
    setState(() {
      
    });
  }

  @override
  void initState() {
    setUI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () {
        widget.onTap!(widget.item.startTime, null, widget.item);
      },
      child: Container(
        width: widget.width,
        height: widget.cellHeight,
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: dutyColor,
            border: widget.item.eventData!.isDutyTime
                ? Border(
                    left: BorderSide(color: borderColor, width: borderWidth))
                : null,
            borderRadius: widget.item.eventData!.isDutyTime
                ? null
                : BorderRadius.circular(borderRadius)),
        child: widget.item.eventData!.isDuty
            ? SizedBox(
                height: widget.breakHeight,
                child: Center(
                    child: Text(
                  widget.item.eventData!.title,
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
                              hideCircle
                                  ? const SizedBox.shrink()
                                  : const Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Icon(
                                        Icons.circle,
                                        color: Colors.black,
                                        size: 6,
                                      ),
                                    ),
                              hideCircle
                                  ? const SizedBox.shrink()
                                  : const SizedBox(
                                      width: 4,
                                    ),
                              Flexible(
                                child: Text(
                                  widget.item.eventData!.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.eventTitle,
                                ),
                              ),
                            ],
                          ),
                          widget.item.eventData!.freeTime
                              ? const SizedBox.shrink()
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        widget.item.eventData!.location ?? '',
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
                              widget.item.eventData!.extraCurricular!,
                              width: 24,
                              height: 24,
                           
                              errorBuilder: (BuildContext context, Object error,
                                      StackTrace? stackTrace) =>
                                  const SizedBox.shrink(),
                            )
                    ],
                  ),
                  widget.item.eventData!.freeTime ||
                          widget.item.eventData!.isDutyTime
                      ? const SizedBox.shrink()
                      : const Spacer(),
                  widget.item.eventData!.freeTime ||
                          widget.item.eventData!.eventLinks == null ||
                          widget.item.eventData!.eventLinks.toString() == ''
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: () {
                            launchLink(
                                widget.item.eventData!.eventLinks, context);
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
                                  '${widget.item.eventData!.eventLinks}',
                                  overflow: TextOverflow.ellipsis,
                                  style: context.subtitle,
                                ),
                              )),
                        )
                ],
              ),
      ));
}