import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/assets_path.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///it will render ui for notes for  exporitng month view
class ExportMonthNote extends StatelessWidget {
  ///initilize the week event
  const ExportMonthNote({
    required this.item,
    required this.cellHeight,
    required this.breakHeight,
    required this.size,
    required this.isDraggable,
    required this.onTap,
    required this.calendarDay,
    this.onMoreTap,
    super.key,
  });

  ///cell and break height
  final double cellHeight, breakHeight;

  ///provide calalback user tap on the cell
  final Function(CalendarDay dateTime, List<CalendarEvent<Note>>) onTap;

  ///list of event
  final List<CalendarEvent<Note>> item;

  ///provide callaback when user tap on more events
  final Function(List<CalendarEvent<Note>> item, Offset globalPosition)?
      onMoreTap;

  ///size of cell
  final Size size;

  /// pass true if is draggable
  final bool isDraggable;

  ///Calendar Day of the event
  final CalendarDay calendarDay;

  @override
  Widget build(BuildContext context) => item.isEmpty
      ? const SizedBox.shrink()
      : Builder(builder: (BuildContext context) {
        const  double tileHeight = 46;
          const int heightFraction = 30 + 8;
          final int maxchild = (size.height - heightFraction) ~/ tileHeight;
          final List<CalendarEvent<Note>> showitem =
              item.take(maxchild).toList();

          bool showMore = item.length > maxchild;
          final int moreCount = item.length - showitem.length;
          if (moreCount == 0) {
            showMore = false;
          }
          final bool showFullSize = showitem.length == 1;
          return Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: heightFraction - 8,
                  ),
                  Column(
                    children: showitem
                        .map((CalendarEvent<Note> e) => SizedBox(
                              width: size.width,
                              child: showMore &&
                                      showitem.indexOf(e) == (maxchild - 1)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Builder(
                                            builder: (BuildContext context) {
                                          final double width = size.width - 8;
                                          final int index = showitem.indexOf(e);
                                          return SmallEventTile(
                                            event: e,
                                            calendarDay: calendarDay,
                                            tileHeight: tileHeight,
                                            crossAxisAlignment: showFullSize
                                                ? CrossAxisAlignment.start
                                                : CrossAxisAlignment.center,
                                            onTap: onTap,
                                            index: index,
                                            width: width,
                                          );
                                        }),
                                        Text(
                                          ' +$moreCount more',
                                          style: context.moreCount,
                                        )
                                      ],
                                    )
                                  : SmallEventTile(
                                      onTap: onTap,
                                      calendarDay: calendarDay,
                                      crossAxisAlignment: showFullSize
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.center,
                                      event: e,
                                      index: showitem.indexOf(e),
                                      tileHeight: tileHeight,
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
      required this.onTap,
      required this.index,
      required this.calendarDay,
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
  final CalendarEvent<Note> event;

  ///provide calalback user tap on the cell
  final Function(CalendarDay calendarDay, List<CalendarEvent<Note>>) onTap;

  ///bool isDraggable
  final bool isDraggable;

  ///cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  ///index of the event

  final int index;

  ///Calendar Day of the event
  final CalendarDay calendarDay;
  @override
  Widget build(BuildContext context) => Draggable<CalendarEvent<Note>>(
        feedback: Card(child: buildTile(context, calendarDay)),
        maxSimultaneousDrags: isDraggable ? 1 : 0,
        data: event,
        childWhenDragging: const SizedBox.shrink(),
        child: buildTile(context, calendarDay),
      );

  ///render the tile
  Widget buildTile(BuildContext context, CalendarDay calendarDay) =>
      GestureDetector(
        onTap: () => onTap(calendarDay, <CalendarEvent<Note>>[event]),
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: index * 100),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            width: width,
            padding: const EdgeInsets.all(4),
            height: tileHeight,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4), color: blueGrey),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: crossAxisAlignment,
                  children: <Widget>[
                    Padding(
                        padding: crossAxisAlignment == CrossAxisAlignment.start
                            ? const EdgeInsets.only(top: 4)
                            : EdgeInsets.zero,
                        child: Image.asset(
                          AssetPath.notes,
                          width: 8,
                          height: 8,
                          errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) =>
                              const SizedBox.shrink(),
                        )),
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
                Text(
                  event.eventData!.title,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      color: white, fontSize: 14, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
        ),
      );
}
