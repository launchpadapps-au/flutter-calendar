import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/get_notes.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/widgets/monthview/add_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///month cell for the month view
class MonthCell extends StatelessWidget {
  ///initilize the week view
  const MonthCell({
    required this.size,
    required this.calendarDay,
    required this.onTap,
    required this.showAddNotePupup,
    super.key,
  });

  ///cell and break height of the cell
  final Size size;

  ///calenfar day fro the cell
  final CalendarDay calendarDay;

  ///pass true if you wanan show pink popup for the add note
  ///default will be false
  final bool showAddNotePupup;

  ///provide calalback user tap on the cell
  final Function(CalendarDay dateTime, List<CalendarEvent<Note>>) onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          if (showAddNotePupup && !calendarDay.deadCell) {
            showAlignedDialog<dynamic>(
              context: context,
              avoidOverflow: true,
              barrierColor: Colors.transparent,
              builder: (BuildContext context) => AddNote(
                dateTime: calendarDay.dateTime,
              ),
            ).then((dynamic value) {
              if (value != null && value) {
                onTap(calendarDay, <CalendarEvent<Note>>[]);
              }
            });
          } else {
            onTap(calendarDay, <CalendarEvent<Note>>[]);
          }
        },
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
              color: Colors.transparent),
        ),
      );
}
