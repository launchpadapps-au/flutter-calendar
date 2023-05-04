import 'package:edgar_planner_calendar_flutter/features/planner/data/models/get_events_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/widgets/monthview/small_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///MonthEventCell for the month view
class MonthEventCell extends StatelessWidget {
  ///initilize the week event
  const MonthEventCell({
    required this.item,
    required this.cellHeight,
    required this.breakHeight,
    required this.size,
    required this.isDraggable,
    required this.onTap,
    super.key,
  });

  ///cell and break height
  final double cellHeight, breakHeight;

  ///provide calalback user tap on the cell
  final Function(DateTime dateTime, List<CalendarEvent<EventData>>) onTap;

  ///list of event
  final List<CalendarEvent<EventData>> item;

  ///size of cell
  final Size size;

  /// pass true if is draggable
  final bool isDraggable;

  @override
  Widget build(BuildContext context) => item.isEmpty
      ? const SizedBox.shrink()
      : SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              if (item.length == 1)
                GestureDetector(
                  onTap: () {
                    onTap(item.first.eventData!.startDate,
                        <CalendarEvent<EventData>>[item.first]);
                  },
                  child: SmallEventTile(
                    event: item.first,
                    width: size.width,
                    isDraggable: isDraggable,
                  ),
                ),
              if (item.length == 2)
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        onTap(item.first.eventData!.startDate,
                            <CalendarEvent<EventData>>[item.first]);
                      },
                      child: SmallEventTile(
                        event: item.first,
                        isDraggable: isDraggable,
                        width: size.width,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onTap(item[1].eventData!.startDate,
                            <CalendarEvent<EventData>>[item[1]]);
                      },
                      child: SmallEventTile(
                        event: item[1],
                        isDraggable: isDraggable,
                        width: size.width,
                      ),
                    )
                  ],
                ),
              if (item.length > 2)
                SizedBox(
                  width: size.width,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          onTap(item.first.eventData!.startDate,
                              <CalendarEvent<EventData>>[item.first]);
                        },
                        child: SmallEventTile(
                          event: item.first,
                          width: size.width,
                          isDraggable: isDraggable,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          onTap(item[1].eventData!.startDate,
                              <CalendarEvent<EventData>>[item[1]]);
                        },
                        child: SmallEventTile(
                          event: item[1],
                          width: size.width,
                          isDraggable: isDraggable,
                        ),
                      ),
                      Row(children: <Widget>[
                        SizedBox(
                          width: size.width - 90,
                          child: GestureDetector(
                            onTap: () {
                              onTap(item[2].eventData!.startDate,
                                  <CalendarEvent<EventData>>[item[2]]);
                            },
                            child: SmallEventTile(
                                isDraggable: isDraggable,
                                event: item[2],
                                width: size.width - 60),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        GestureDetector(
                            onTap: () {
                              onTap(item.first.eventData!.startDate, item);
                            },
                            child: Text('+${item.skip(3).length}')),
                        const Spacer()
                      ])
                    ],
                  ),
                )
            ],
          ),
        );
}
