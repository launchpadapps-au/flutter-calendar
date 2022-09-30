import 'package:edgar_planner_calendar_flutter/core/utils.dart' as utils;
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///render event for the planner
class ScheduleViewEventTile extends StatelessWidget {
  ///pass calendar event
  const ScheduleViewEventTile({
    required this.item,
    required this.cellHeight,
    Key? key,
  }) : super(key: key);

  ///CalendarEvent object
  final CalendarEvent<EventData> item;

  ///double cell height
  final double cellHeight;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        height: 51,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: item.eventData!.color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.circle,
                        color: Colors.black,
                        size: 10,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Flexible(
                        child: Text(
                          item.eventData!.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              height: 1.2,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      // const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    utils.getFormattedTime(item.eventData!.period, context),
                    style: const TextStyle(
                        height: 1.2, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
            item.eventData!.freeTime ? const SizedBox.shrink() : const Spacer(),
            Flexible(
              child: Text(
                item.eventData!.description,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    height: 1.2, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}
