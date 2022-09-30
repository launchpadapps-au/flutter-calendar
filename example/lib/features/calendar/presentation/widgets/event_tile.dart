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
        margin: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.circle,
                  color: Colors.black,
                  size: 4,
                ),
                const SizedBox(
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
            item.eventData!.freeTime
                ? const SizedBox.shrink()
                : Flexible(
                    child: Text(
                      item.eventData!.description,
                      overflow: TextOverflow.ellipsis,
                      style: context.subtitle,
                    ),
                  ),
            item.eventData!.freeTime ? const SizedBox.shrink() : const Spacer(),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  item.eventData!.documents.first.documentName,
                  overflow: TextOverflow.ellipsis,
                  style: context.subtitle,
                ))

            // item.eventData!.freeTime
            //     ? const SizedBox.shrink()
            //     : item.eventData!.documents.isNotEmpty
            //         ? Wrap(
            //             runSpacing: 8,
            //             spacing: 8,
            //             children: <String>[
            //               item.eventData!.documents.first.documentName
            //             ]
            //                 .map((String e) => Container(
            //                     width: MediaQuery.of(context).size.width,
            //                     padding: const EdgeInsets.symmetric(
            //                         horizontal: 4, vertical: 2),
            //                     decoration: BoxDecoration(
            //                         color: Colors.white,
            //                         borderRadius: BorderRadius.circular(20)),
            //                     child: Text(
            //                       e,
            //                       style: context.subtitle,
            //                     )))
            //                 .toList())
            //         : const SizedBox.shrink(),
          ],
        ),
      );
}
