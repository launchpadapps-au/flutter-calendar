import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/assets_path.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:intl/intl.dart';

///note dialog for the monthview
class NoteDialog extends StatelessWidget {
  ///initialize the note dialog
  const NoteDialog(
      {required this.dateTime,
      required this.notes,
      required this.onTap,
      required this.calendarDay,
      super.key});

  ///date time date
  final DateTime dateTime;

  ///list of the notes
  final List<CalendarEvent<Note>> notes;

  ///provide calalback user tap on the cell
  final Function(CalendarDay dateTime, List<CalendarEvent<Note>>) onTap;

  ///Calendar Day of the event
  final CalendarDay calendarDay;

  @override
  Widget build(BuildContext context) => Container(
        width: 233,
        height: 233,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(
                  4,
                  4,
                ),
                blurRadius: 14,
                spreadRadius: 2,
              ), //BoxShadow
              const BoxShadow(
                color: Colors.white,
              ), //BoxShadow]
            ]),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  DateFormat.E().format(dateTime).toUpperCase(),
                  style: context.popuptitle,
                ),
                Text(
                  DateFormat('d MMM yyyy').format(dateTime).toUpperCase(),
                  style: context.popupTrailing,
                )
              ],
            ),
            const SizedBox(
              height: 23,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) => buildTile(
                    notes[index].eventData!, calendarDay, notes[index]),
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                  height: 6,
                ),
              ),
            )
          ],
        ),
      );

  ///build note tile
  Widget buildTile(
          Note note, CalendarDay calendarDay, CalendarEvent<Note> event) =>
      GestureDetector(
        onTap: () => onTap(calendarDay, <CalendarEvent<Note>>[event]),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          height: 49,
          decoration: BoxDecoration(
              color: blueGrey, borderRadius: BorderRadius.circular(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image.asset(
                    AssetPath.notes,
                    width: 8,
                    height: 8,
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(color: white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                note.description,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(color: white, fontSize: 14),
              )
            ],
          ),
        ),
      );
}
