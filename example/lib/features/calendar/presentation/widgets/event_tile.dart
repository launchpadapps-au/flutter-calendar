import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///render event for the planner
class EventTile extends StatelessWidget {
  ///pass calendar event
  const EventTile({
    required this.item,
    required this.width,
    required this.height,
    Key? key,
  }) : super(key: key);

  ///CalendarEvent object
  final CalendarEvent<EventData> item;

  ///double width
  final double width, height;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.all(item.eventData!.isDutyTime ? 0 : 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: item.eventData!.isDutyTime
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: item.eventData!.isDutyTime
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: item.eventData!.isDutyTime
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                item.eventData!.isDutyTime
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.circle,
                        color: Colors.black,
                        size: 4,
                      ),
                item.eventData!.isDutyTime
                    ? const SizedBox.shrink()
                    : const SizedBox(
                        width: 4,
                      ),
                Flexible(
                  child: Text(
                    item.eventData!.title,
                    style: context.subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            item.eventData!.freeTime || item.eventData!.isDutyTime
                ? const SizedBox.shrink()
                : Flexible(
                    child: Text(
                      item.eventData!.location ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: context.subtitle,
                    ),
                  ),
            // Text(
            //   item.eventData!.period.id,
            //   overflow: TextOverflow.ellipsis,
            //   style: context.subtitle,
            // ),
            item.eventData!.freeTime || item.eventData!.isDutyTime
                ? const SizedBox.shrink()
                : const Spacer(),
            item.eventData!.freeTime ||
                    item.eventData!.eventLinks == null ||
                    item.eventData!.eventLinks.toString() == ''
                ? const SizedBox.shrink()
                : Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${item.eventData!.eventLinks}',
                      overflow: TextOverflow.ellipsis,
                      style: context.subtitle,
                    ))
          ],
        ),
      );
}
