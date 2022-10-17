import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/utils.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

///left strip for the tablet view
class LeftStrip extends StatelessWidget {
  /// initialize the constructor
  const LeftStrip({Key? key, this.width = 48, this.height = 60})
      : super(key: key);

  ///const double width
  final double width;

  ///const double height
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 48,
        child: BlocConsumer<TimeTableCubit, TimeTableState>(
          listener: (BuildContext context, TimeTableState state) {},
          builder: (BuildContext context, TimeTableState state) {
            final int month =
                BlocProvider.of<TimeTableCubit>(context).date.month;
            final int year = BlocProvider.of<TimeTableCubit>(context).date.year;
            return Column(
              children: getMonth()
                  .map((DateTime e) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final DateTime firstDate = DateTime(year, e.month);
                            final DateTime lastDate =
                                DateTime(year, e.month + 1)
                                    .subtract(const Duration(days: 1));

                            BlocProvider.of<TimeTableCubit>(context)
                                .setMonth(firstDate, lastDate);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: e.month == month
                                    ? grey
                                    : Colors.transparent,
                                border: Border.all(color: lightGrey),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8))),
                            child: RotatedBox(
                                quarterTurns: 3,
                                child: Center(
                                    child: Text(
                                  DateFormat('MMM').format(e),
                                  style: context.stripsTheme.copyWith(
                                      color: e.month == month
                                          ? Colors.black
                                          : null),
                                ))),
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      );
}
