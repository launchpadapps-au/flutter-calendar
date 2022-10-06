import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:edgar_planner_calendar_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///right strip for the tablet view
class RightStrip extends StatelessWidget {
  /// initialize the constructor
  const RightStrip(
      {required this.termModel, Key? key, this.width = 48, this.height = 60})
      : super(key: key);

  ///const double width
  final double width;

  ///const double height
  final double height;

  ///Term Model
  final TermModel termModel;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: BlocBuilder<TimeTableCubit, TimeTableState>(
          builder: (BuildContext context, TimeTableState state) {
            final TimeTableCubit cubit =
                BlocProvider.of<TimeTableCubit>(context);
            final DateTime startDate = cubit.startDate;
            final CalendarViewType viewType = cubit.viewType;
            return Column(
              children: <Widget>[
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).day,
                  onTap: () {
                    if (viewType != CalendarViewType.dayView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.dayView);
                    }
                  },
                  selected: viewType == CalendarViewType.dayView,
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).week,
                  onTap: () {
                    if (viewType != CalendarViewType.weekView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.weekView);
                    }
                  },
                  selected: viewType == CalendarViewType.weekView,
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).month,
                  onTap: () {
                    if (viewType != CalendarViewType.monthView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.monthView);
                    }
                  },
                  selected: viewType == CalendarViewType.monthView,
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term1,
                  selected: viewType == CalendarViewType.termView &&
                      startDate.month ==
                          termModel.terms.term1Date.startDate.month,
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    final Term term = termModel.terms.term1Date;
                    final DateTime firstDate = term.startDate;
                    final DateTime lastDate = term.endDate;

                    BlocProvider.of<TimeTableCubit>(context)
                        .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  selected: viewType == CalendarViewType.termView &&
                      startDate.month ==
                          termModel.terms.term2Date.startDate.month,
                  title: S.of(context).term2,
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    final Term term = termModel.terms.term2Date;
                    final DateTime firstDate = term.startDate;
                    final DateTime lastDate = term.endDate;

                    BlocProvider.of<TimeTableCubit>(context)
                        .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term3,
                  selected: viewType == CalendarViewType.termView &&
                      startDate.month ==
                          termModel.terms.term3Date.startDate.month,
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    final Term term = termModel.terms.term3Date;
                    final DateTime firstDate = term.startDate;
                    final DateTime lastDate = term.endDate;

                    BlocProvider.of<TimeTableCubit>(context)
                        .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term4,
                  selected: viewType == CalendarViewType.termView &&
                      startDate.month ==
                          termModel.terms.term4Date.startDate.month,
                  onTap: () {
                    if (viewType != CalendarViewType.termView) {
                      BlocProvider.of<TimeTableCubit>(context)
                          .changeViewType(CalendarViewType.termView);
                    }
                    final Term term = termModel.terms.term4Date;
                    final DateTime firstDate = term.startDate;
                    final DateTime lastDate = term.endDate;

                    BlocProvider.of<TimeTableCubit>(context)
                        .changeDate(firstDate, lastDate);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).records,
                  onTap: () {
                    BlocProvider.of<TimeTableCubit>(context)
                        .nativeCallBack
                        .sendShowRecordToNativeApp();
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
