import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart' as utils;
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
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
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 82;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      height: 60,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: item.eventData!.color),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: width - 126 - 40,
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
                        style: context.eventTitleMobile,
                      ),
                    ),

                    // const Spacer(),
                  ],
                ),
              ),
              // item.eventData!.freeTime ? const SizedBox.shrink() :
              //const Spacer(),
              SizedBox(
                width: width - 126 - 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        item.eventData!.location ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.eventTitleMobile,
                      ),
                    ),
                  ],
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
                  width: 125,
                  child: Text(
                    utils.getFormattedTime(
                        Period(
                            startTime: TimeOfDay.fromDateTime(item.startTime),
                            endTime: TimeOfDay.fromDateTime(item.endTime)),
                        context),
                    style: context.eventTitleMobile.copyWith(fontSize: 12),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Transform(
                  transform: Matrix4.translationValues(-3, 0, 0),
                  child: Text(
                    item.eventData!.extraCurricular!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
