import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/callbacks/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/export_setting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///appbar for the calendar
class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  ///initialize the widset
  const CalendarAppBar({
    required this.headerDateNotifier,
    required this.scaffoldKey,
    super.key,
  });

  ///scaffold keyy for opning drawer
  final GlobalKey<ScaffoldState> scaffoldKey;

  ///notifier for the header date
  final ValueNotifier<DateTime> headerDateNotifier;

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
              ),
              onPressed: () {
                final CalendarViewType view =
                    BlocProvider.of<PlannerCubit>(context).viewType;

                if (view == CalendarViewType.dayView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.previousDay, null);
                } else if (view == CalendarViewType.weekView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.previousWeek, null);
                } else if (view == CalendarViewType.monthView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.previousMonth, null);
                } else if (view == CalendarViewType.termView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.previousTerm, null);
                }
              },
            ),
            ValueListenableBuilder<DateTime>(
                valueListenable: headerDateNotifier,
                builder:
                    (BuildContext context, DateTime value, Widget? child) =>
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            BlocProvider.of<PlannerCubit>(context)
                                .date
                                .toString()
                                .substring(0, 10),
                            style: context.termPlannerTitle,
                          ),
                        )),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
              onPressed: () {
                final CalendarViewType view =
                    BlocProvider.of<PlannerCubit>(context).viewType;

                if (view == CalendarViewType.dayView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.nextDay, null);
                } else if (view == CalendarViewType.weekView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.nextWeek, null);
                } else if (view == CalendarViewType.monthView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.nextMonth, null);
                } else if (view == CalendarViewType.termView) {
                  PlannerCubit.mockObject
                      .invokeMethod(ReceiveMethods.nextTerm, null);
                }
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            scaffoldKey.currentState!.openEndDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.undo,
                color: Colors.black,
              ),
              onPressed: () {
                PlannerCubit.mockObject
                    .invokeMethod(ReceiveMethods.resetEvent, null);
              }),
          IconButton(
              icon: const Icon(
                Icons.calendar_month,
                color: Colors.black,
              ),
              onPressed: () {
                PlannerCubit.mockObject
                    .invokeMethod(ReceiveMethods.jumpToCurrentDate, null);
              }),
          IconButton(
              icon: const Icon(
                Icons.file_download,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) =>
                          const ExportSettingView(),
                    ));
              }),
        ],
      );
}
