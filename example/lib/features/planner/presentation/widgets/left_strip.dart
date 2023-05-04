import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/utils/utils.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 50),
        width: 48,
        child: BlocConsumer<PlannerCubit, PlannerState>(
          listener: (BuildContext context, PlannerState state) {},
          builder: (BuildContext context, PlannerState state) =>
              Builder(builder: (BuildContext context) {
            DateTime date = BlocProvider.of<PlannerCubit>(context).date;
            if (state is MonthUpdated) {
              date = state.startDate;
            }
            final int month = date.month;
            final int year = date.year;
            return Column(
              children: <Widget>[
                const Divider(height: 2, thickness: 2),
                Expanded(
                  child: Column(
                    children: getMonth()
                        .map((DateTime e) => Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final PlannerCubit cubit =
                                      BlocProvider.of<PlannerCubit>(context);
                                  final DateTime firstDate =
                                      DateTime(year, e.month);
                                  final DateTime lastDate =
                                      DateTime(year, e.month + 1)
                                          .subtract(const Duration(days: 1));
                                  if (cubit.viewType ==
                                      CalendarViewType.monthView) {
                                    cubit.fetchNotes(Term(
                                        startDate: firstDate,
                                        endDate: lastDate));
                                  } else {
                                    cubit
                                      ..changeViewType(
                                          CalendarViewType.monthView)
                                      ..fetchNotes(Term(
                                          startDate: firstDate,
                                          endDate: lastDate));
                                  }
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
                  ),
                ),
              ],
            );
          }),
        ),
      );
}
