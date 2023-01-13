 
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_events_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///MonthEventCell for the month view
class ExportMonthEvent extends StatelessWidget {
  ///initilize the week event
  const ExportMonthEvent({
    required this.item,
    required this.cellHeight,
    required this.breakHeight,
    required this.size,
    required this.isDraggable,
    required this.onTap,
    this.onMoreTap,
    super.key,
  });

  ///cell and break height
  final double cellHeight, breakHeight;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, List<CalendarEvent<EventData>>) onTap;

  ///list of event
  final List<CalendarEvent<EventData>> item;

  ///provide callaback when user tap on more events
  final Function(List<CalendarEvent<EventData>> item, Offset globalPosition)?
      onMoreTap;

  ///size of cell
  final Size size;

  /// pass true if is draggable
  final bool isDraggable;
  @override
  Widget build(BuildContext context) => item.isEmpty
      ? const SizedBox.shrink()
      : Builder(builder: (BuildContext context) {
          final int maxchild = (size.height - 38) ~/ 28;
          final List<CalendarEvent<EventData>> showitem =
              item.take(maxchild).toList();

          bool showMore = item.length > maxchild;
          final int moreCount = item.length - showitem.length;
          if (moreCount == 0) {
            showMore = false;
          }
          return Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: showitem
                        .map((CalendarEvent<EventData> e) => SizedBox(
                              height: 28,
                              width: size.width - 8,
                              child: showMore &&
                                      showitem.indexOf(e) == (maxchild - 1)
                                  ? Row(
                                      children:<Widget> [
                                        SmallEventTile(
                                          event: e,
                                          width: size.width - 43 - 38 - 16,
                                        ),
                                        GestureDetector(
                                          onTapDown: (TapDownDetails details) {
                                            if (onMoreTap != null) {
                                              onMoreTap!(
                                                  item
                                                      .skip(showitem.length)
                                                      .take(item.length)
                                                      .toList(),
                                                  details.globalPosition);
                                            }
                                          },
                                          child: Text(' +$moreCount'),
                                        )
                                      ],
                                    )
                                  : SmallEventTile(
                                      event: e,
                                      width: size.width - 8,
                                    ),
                            ))
                        .toList(),
                  )
                ],
              ),
            ),
          );
        });
}

///small even tile
class SmallEventTile extends StatelessWidget {
  ///small event constructor
  const SmallEventTile(
      {required this.event,
      required this.width,
      this.tileHeight = 24,
      Key? key,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.isDraggable = false})
      : super(key: key);

  ///heigh of the tile
  final double tileHeight;

  ///double width
  final double width;

  ///Calendar event
  final CalendarEvent<EventData> event;

  ///bool isDraggable
  final bool isDraggable;

  ///cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Draggable<CalendarEvent<EventData>>(
        feedback: Card(child: buildTile(context)),
        maxSimultaneousDrags: isDraggable ? 1 : 0,
        data: event,
        childWhenDragging: const SizedBox.shrink(),
        child: buildTile(context),
      );

  ///render the tile
  Widget buildTile(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        width: width,
        padding: const EdgeInsets.all(4),
        height: tileHeight,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(4), color: blue),
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          children: <Widget>[
            Image.asset(
              'assets/notes.png',
              width: 8,
              height: 8,
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: Text(
                event.eventData!.title,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(color: white, fontSize: 14),
              ),
            ),
          ],
        ),
      );
}
