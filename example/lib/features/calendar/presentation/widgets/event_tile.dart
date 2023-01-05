import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/url.dart';
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
            // Row(
            //   mainAxisSize: item.eventData!.isDutyTime
            //       ? MainAxisSize.max
            //       : MainAxisSize.min,
            //   mainAxisAlignment: item.eventData!.isDutyTime
            //       ? MainAxisAlignment.center
            //       : MainAxisAlignment.start,
            //   children: <Widget>[
            //     item.eventData!.isDutyTime
            //         ? const SizedBox.shrink()
            //         : Container(
            //             margin: const EdgeInsets.only(bottom: 2),
            //             height: 10 * MediaQuery.of(context).textScaleFactor,
            //             child: const Center(
            //               child: Icon(
            //                 Icons.circle,
            //                 color: Colors.black,
            //                 size: 6,
            //               ),
            //             ),
            //           ),
            //     item.eventData!.isDutyTime
            //         ? const SizedBox.shrink()
            //         : const SizedBox(
            //             width: 4,
            //           ),
            //     Flexible(
            //       child: Text(
            //         item.eventData!.title,
            //         style: context.subtitle,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: width - 24 - 28,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.circle,
                                color: Colors.black,
                                size: 6,
                              ),
                            ),
                            const SizedBox(
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
                          ]),
                    ),
                    !item.eventData!.freeTime
                        ? const SizedBox(
                            height: 6,
                          )
                        : const SizedBox.shrink(),
                    item.eventData!.freeTime
                        ? const SizedBox.shrink()
                        : Text(
                            item.eventData!.location ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: context.eventTitle,
                          ),
                  ],
                ),
                item.eventData!.extraCurricular == null
                    ? const SizedBox.shrink()
                    : Image.network(
                        item.eventData!.extraCurricular!,
                        width: 24,
                        height: 24,
                      )
              ],
            ),
            // item.eventData!.freeTime || item.eventData!.isDutyTime
            //     ? const SizedBox.shrink()
            //     : Flexible(
            //         child: Text(
            //           item.eventData!.location ?? '',
            //           overflow: TextOverflow.ellipsis,
            //           style: context.subtitle,
            //         ),
            //       ),
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
      );
}
