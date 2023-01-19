import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/month_note.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/note_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///it will render ui for notes in term view
class TermNote extends StatelessWidget {
  ///initilize the week event
  const TermNote({
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
          const int heightFraction = 20 + 8;
          final int maxchild = ((size.height - heightFraction) ~/ 28) * 2;
          final List<CalendarEvent<Note>> showitem =
              item.take(maxchild).toList();

          bool showMore = item.length > maxchild;
          final int moreCount = item.length - showitem.length;
          if (moreCount == 0) {
            showMore = false;
          }
          final bool showFullSize = showitem.length == 1;
          final List<SizedBox> list = showitem
              .map((CalendarEvent<Note> e) => SizedBox(
                  height: showFullSize ? size.height - heightFraction : 28,
                  width: showFullSize ? size.width - 8 : (size.width - 12) / 2,
                  child: Builder(builder: (BuildContext context) {
                    final double width = (size.width - 12) / 2;
                    return width.isNegative
                        ? const SizedBox.shrink()
                        : SmallEventTile(
                            event: e,
                            crossAxisAlignment: showFullSize
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            onTap: onTap,
                            index: showitem.indexOf(e),
                            width: width);
                  })))
              .toList();
          if (showMore) {
            list
              ..removeLast()
              ..add(SizedBox(
                  height: showFullSize ? size.height - heightFraction : 28,
                  width: showFullSize ? size.width - 8 : (size.width - 12) / 2,
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      showAlignedDialog<dynamic>(
                          context: context,
                          avoidOverflow: true,
                          builder: (BuildContext context) => NoteDialog(
                                dateTime: item.first.startTime,
                                notes: item
                                    .skip(item.length - moreCount)
                                    .take(moreCount)
                                    .toList(),
                                onTap: onTap,
                              ),
                          barrierColor: Colors.transparent);
                    },
                    child: Center(
                        child: Text(
                      ' +$moreCount',
                      style: context.moreCount,
                    )),
                  )));
          }
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
                  Wrap(
                    spacing: 3.5,
                    children: list,
                  )
                ],
              ),
            ),
          );
        });
}
