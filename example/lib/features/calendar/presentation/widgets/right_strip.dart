import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_event_state.dart';
import 'package:edgar_planner_calendar_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///right strip for the tablet view
class RightStrip extends StatelessWidget {
  /// initialize the constructor
  const RightStrip({Key? key, this.width = 48, this.height = 60})
      : super(key: key);

  ///const double width
  final double width;

  ///const double height
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 50),
        width: width,
        child: BlocConsumer<TimeTableCubit, TimeTableState>(
          listener: (BuildContext context, TimeTableState state) {},
          builder: (BuildContext context, TimeTableState state) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            final CalendarViewType viewType = cubit.viewType;
            final Term crTerm = cubit.term;
            return Column(
              children: <Widget>[
                const Divider(height: 2.5, thickness: 2.5),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).todo,
                  onTap: () {
                    cubit.nativeCallBack.sendShowTodos();
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).day,
                  onTap: () {
                    if (viewType != CalendarViewType.dayView) {
                      cubit
                        ..setDate(cubit.date)
                        ..changeViewType(CalendarViewType.dayView);
                    }
                  },
                  selected: viewType == CalendarViewType.dayView,
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).week,
                  onTap: () {
                    if (viewType != CalendarViewType.weekView) {
                      cubit
                        ..setDate(cubit.date)
                        ..changeViewType(CalendarViewType.weekView);
                    }
                  },
                  selected: viewType == CalendarViewType.weekView,
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).month,
                  onTap: () {
                    if (viewType != CalendarViewType.monthView) {
                      final TimeTableCubit cubit =
                          BlocProvider.of<TimeTableCubit>(context);
                      cubit
                        ..changeViewType(CalendarViewType.monthView)
                        ..setMonthFromDate(cubit.date);
                    }
                  },
                  selected: viewType == CalendarViewType.monthView,
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term1,
                  selected: viewType == CalendarViewType.termView &&
                      crTerm.type == 'term1',
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    BlocProvider.of<TimeTableCubit>(context).setTerm('term1');
                    // final DateTime firstDate = term.startDate;
                    // final DateTime lastDate = term.endDate;

                    // BlocProvider.of<TimeTableCubit>(context)
                    //     .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  selected: viewType == CalendarViewType.termView &&
                      crTerm.type == 'term2',
                  title: S.of(context).term2,
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    BlocProvider.of<TimeTableCubit>(context).setTerm('term2');
                    // final DateTime firstDate = term.startDate;
                    // final DateTime lastDate = term.endDate;

                    // BlocProvider.of<TimeTableCubit>(context)
                    //     .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term3,
                  selected: viewType == CalendarViewType.termView &&
                      crTerm.type == 'term3',
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    BlocProvider.of<TimeTableCubit>(context).setTerm('term3');
                    // final DateTime firstDate = term.startDate;
                    // final DateTime lastDate = term.endDate;

                    // BlocProvider.of<TimeTableCubit>(context)
                    //     .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term4,
                  selected: viewType == CalendarViewType.termView &&
                      crTerm.type == 'term4',
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    BlocProvider.of<TimeTableCubit>(context).setTerm('term4');
                    // final DateTime firstDate = term.startDate;
                    // final DateTime lastDate = term.endDate;

                    // BlocProvider.of<TimeTableCubit>(context)
                    //     .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).drive,
                  onTap: () {
                    BlocProvider.of<TimeTableCubit>(context)
                        .nativeCallBack
                        .sendOpenDriveToNativeApp();
                  },
                )),
              ],
            );
          },
        ),
      );
}

///sideButton of the strips
class RightSideButton extends StatelessWidget {
  ///initialize side button
  const RightSideButton(
      {required this.title, this.selected = false, Key? key, this.onTap})
      : super(key: key);

  ///onTap callBack
  final Function? onTap;

  ///Title
  final String title;

  /// true if selected
  final bool selected;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: selected ? grey : Colors.transparent,
            border: Border.all(color: lightGrey),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
        child: RotatedBox(
            quarterTurns: 1,
            child: Center(
                child: Text(
              title,
              style: context.stripsTheme
                  .copyWith(color: selected ? Colors.black : null),
            ))),
      ));
}
