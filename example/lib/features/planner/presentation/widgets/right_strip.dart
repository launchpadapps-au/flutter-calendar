import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/data/models/term_model.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_event_state.dart';
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
        child: BlocConsumer<PlannerCubit, PlannerState>(
          listener: (BuildContext context, PlannerState state) {},
          builder: (BuildContext context, PlannerState state) {
            final PlannerCubit cubit = BlocProvider.of<PlannerCubit>(context);
            final CalendarViewType viewType = cubit.viewType;
            final Term crTerm = cubit.term ?? cubit.termModel.terms.term1Date;
            return Column(
              children: <Widget>[
                const Divider(height: 2.5, thickness: 2.5),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).todo,
                  onTap: () {
                    cubit.nativeCallBack.showTodos();
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).day,
                  onTap: () {
                    if (viewType != CalendarViewType.dayView) {
                      cubit
                        ..changeViewType(CalendarViewType.dayView)
                        ..onDateChange(cubit.date, jump: true);
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
                        ..changeViewType(CalendarViewType.weekView)
                        ..onDateChange(cubit.date, jump: true);
                    }
                  },
                  selected: viewType == CalendarViewType.weekView,
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).month,
                  onTap: () {
                    if (viewType != CalendarViewType.monthView) {
                      final PlannerCubit cubit =
                          BlocProvider.of<PlannerCubit>(context);
                      cubit
                        ..changeViewType(CalendarViewType.monthView,
                            jump: false)
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
                    final PlannerCubit cubit =
                        BlocProvider.of<PlannerCubit>(context);
                    if (viewType != CalendarViewType.termView) {
                      cubit.changeViewType(CalendarViewType.termView,
                          jump: false);
                    }
                    cubit.fetchNotes(cubit.termModel.terms.term1Date);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  selected: viewType == CalendarViewType.termView &&
                      crTerm.type == 'term2',
                  title: S.of(context).term2,
                  onTap: () {
                    final PlannerCubit cubit =
                        BlocProvider.of<PlannerCubit>(context);
                    if (viewType != CalendarViewType.termView) {
                      cubit.changeViewType(CalendarViewType.termView,
                          jump: false);
                    }
                    cubit.fetchNotes(cubit.termModel.terms.term2Date);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term3,
                  selected: viewType == CalendarViewType.termView &&
                      crTerm.type == 'term3',
                  onTap: () {
                    final PlannerCubit cubit =
                        BlocProvider.of<PlannerCubit>(context);
                    if (viewType != CalendarViewType.termView) {
                      cubit.changeViewType(CalendarViewType.termView,
                          jump: false);
                    }
                    cubit.fetchNotes(cubit.termModel.terms.term3Date);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).term4,
                  selected: viewType == CalendarViewType.termView &&
                      crTerm.type == 'term4',
                  onTap: () {
                    final PlannerCubit cubit =
                        BlocProvider.of<PlannerCubit>(context);
                    if (viewType != CalendarViewType.termView) {
                      cubit.changeViewType(CalendarViewType.termView,
                          jump: false);
                    }
                    cubit.fetchNotes(cubit.termModel.terms.term4Date);
                  },
                )),
                Expanded(
                    child: RightSideButton(
                  title: S.of(context).drive,
                  onTap: () {
                    BlocProvider.of<PlannerCubit>(context)
                        .nativeCallBack
                        .openDrive();
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
