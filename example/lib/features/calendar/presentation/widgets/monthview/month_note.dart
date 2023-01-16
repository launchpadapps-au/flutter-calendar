import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/assets_path.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/note_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///it will render ui for notes in month view
class MonthNote extends StatelessWidget {
  ///initilize the week event
  const MonthNote({
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
  final Function(DateTime dateTime, List<CalendarEvent<Note>>) onTap;

  ///list of event
  final List<CalendarEvent<Note>> item;

  ///provide callaback when user tap on more events
  final Function(List<CalendarEvent<Note>> item, Offset globalPosition)?
      onMoreTap;

  ///size of cell
  final Size size;

  /// pass true if is draggable
  final bool isDraggable;
  @override
  Widget build(BuildContext context) => item.isEmpty
      ? const SizedBox.shrink()
      : Builder(builder: (BuildContext context) {
          const int heightFraction = 30 + 8;
          final int maxchild = (size.height - heightFraction) ~/ 28;
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
                              height: showFullSize
                                  ? size.height - heightFraction
                                  : 28,
                              width: size.width - 8,
                              child: showMore &&
                                      showitem.indexOf(e) == (maxchild - 1)
                                  ? Row(
                                      children: <Widget>[
                                        Builder(
                                            builder: (BuildContext context) {
                                          final double width = size.width -
                                              43 -
                                              heightFraction -
                                              16;
                                          final int index = showitem.indexOf(e);
                                          return width.isNegative
                                              ? const SizedBox.shrink()
                                              : SmallEventTile(
                                                  event: e,
                                                  crossAxisAlignment:
                                                      showFullSize
                                                          ? CrossAxisAlignment
                                                              .start
                                                          : CrossAxisAlignment
                                                              .center,
                                                  onTap: onTap,
                                                  index: index,
                                                  width: width,
                                                );
                                        }),
                                        GestureDetector(
                                          onTapDown: (TapDownDetails details) {
                                            showAlignedDialog<dynamic>(
                                                context: context,
                                                avoidOverflow: true,
                                                builder:
                                                    (BuildContext context) =>
                                                        NoteDialog(
                                                          dateTime: item
                                                              .first.startTime,
                                                          notes: item
                                                              .skip(
                                                                  item.length -
                                                                      moreCount)
                                                              .take(moreCount)
                                                              .toList(),
                                                          onTap: onTap,
                                                        ),
                                                barrierColor:
                                                    Colors.transparent);
                                          },
                                          child: Text(
                                            ' +$moreCount',
                                            style: context.moreCount,
                                          ),
                                        )
                                      ],
                                    )
                                  : SmallEventTile(
                                      onTap: onTap,
                                      crossAxisAlignment: showFullSize
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.center,
                                      event: e,
                                      index: showitem.indexOf(e),
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
  final Function(DateTime dateTime, List<CalendarEvent<Note>>) onTap;

  ///bool isDraggable
  final bool isDraggable;

  ///cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;
///index of the event

  final int index;

  @override
  Widget build(BuildContext context) => Draggable<CalendarEvent<Note>>(
        feedback: Card(child: buildTile(context)),
        maxSimultaneousDrags: isDraggable ? 1 : 0,
        data: event,
        childWhenDragging: const SizedBox.shrink(),
        child: buildTile(context),
      );

  ///render the tile
  Widget buildTile(BuildContext context) => GestureDetector(
        onTap: () =>
            onTap(event.eventData!.startDate, <CalendarEvent<Note>>[event]),
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: index * 100),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            width: width,
            padding: const EdgeInsets.all(4),
            height: tileHeight,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4), color: blue),
            child: Row(
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
          ),
        ),
      );
}
