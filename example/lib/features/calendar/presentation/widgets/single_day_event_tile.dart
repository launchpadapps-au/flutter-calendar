import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/url.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///it will render calendar view
class SingleDayEventTile extends StatelessWidget {
  ///pass calendar event
  const SingleDayEventTile({
    required this.item,
    required this.breakHeight,
    required this.cellHeight,
    required this.cellWidth,
    this.border,
    this.isDraggable = true,
    this.margin = EdgeInsets.zero,
    Key? key,
  }) : super(key: key);

  ///calendar event
  final CalendarEvent<EventData> item;

  ///height of the cell
  final double cellHeight;

  ///cell width
  final double cellWidth;

  ///height of the cell
  final double breakHeight;

  ///bool isDraggable;
  final bool isDraggable;

  ///margin of the event ,respect to the Size cell
  final EdgeInsets margin;

  /// border of the event
  final Border? border;
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool small = width < 10;

    return Container(
      decoration: item.eventData!.isDutyTime
          ? BoxDecoration(
              border: const Border(left: BorderSide(color: textGrey, width: 8)),
              color: item.eventData!.color)
          : BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: border,
              color: item.eventData!.color),
      margin: EdgeInsets.all(item.eventData!.isDutyTime ? 0 : 4),
      width: cellWidth,
      // height: item.eventData!.period.isBreak ? breakHeight : cellHeight,
      padding: item.eventData!.isDutyTime
          ? EdgeInsets.zero
          : const EdgeInsets.only(left: 6, right: 18, top: 6, bottom: 6),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(item.eventData!.isDutyTime ? 0 : 6),
        child: Container(
          padding: EdgeInsets.all(item.eventData!.isDuty ? 0 : 8),
          // height: item.eventData!.period.isBreak ? breakHeight :
          // cellHeight,

          child: item.eventData!.isDutyTime
              ? SizedBox(
                  height: breakHeight,
                  child: Center(
                      child: Text(
                    item.eventData!.title,
                    style: context.eventTitle,
                  )),
                )
              : small
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.circle,
                                  color: Colors.black,
                                  size: 6,
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
                              ],
                            ),
                            !item.eventData!.freeTime
                                ? const SizedBox(
                                    height: 6,
                                  )
                                : const SizedBox.shrink(),
                            item.eventData!.freeTime
                                ? const SizedBox.shrink()
                                : Flexible(
                                    child: Text(
                                      item.eventData!.location ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: context.eventTitle,
                                    ),
                                  ),
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
                                  launchLink(item.eventData!.eventLinks);
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20)),
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
        ),
      ),
    );
  }
}
