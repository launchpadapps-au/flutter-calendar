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
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            height: 51,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: item.eventData!.color),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: constraints.biggest.width - 126 - 26,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            height: 10 * MediaQuery.of(context).textScaleFactor,
                            child: const Center(
                              child: Icon(
                                Icons.circle,
                                color: Colors.black,
                                size: 6,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            child: Text(
                              item.eventData!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ),

                          // const Spacer(),
                        ],
                      ),
                    ),
                    // item.eventData!.freeTime ? const SizedBox.shrink() :
                    //const Spacer(),
                    Flexible(
                      child: Text(
                        item.eventData!.location ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            height: 1.2,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 6,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 100,
                        child: Text(
                          utils.getFormattedTime(
                              Period(
                                  startTime:
                                      TimeOfDay.fromDateTime(item.startTime),
                                  endTime:
                                      TimeOfDay.fromDateTime(item.endTime)),
                              context),
                          style: const TextStyle(
                              height: 1.2,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      item.eventData!.extraCurricular == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                item.eventData!.extraCurricular!,
                                width: 20,
                                height: 20,
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ));
}
