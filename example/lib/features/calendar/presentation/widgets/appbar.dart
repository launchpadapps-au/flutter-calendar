import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/method_name.dart';
import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/export_setting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///appbar for the calendar
class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  ///initialize the widset
  const CalendarAppBar({
    required this.viewTypeNotifer,
    required this.headerDateNotifier,
    required this.scaffoldKey,
    super.key,
  });

  ///notifer for the view
  final ValueNotifier<CalendarViewType> viewTypeNotifer;

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
                final CalendarViewType view = viewTypeNotifer.value;
                final TimeTableCubit cubit =
                    BlocProvider.of<TimeTableCubit>(context);
                if (view == CalendarViewType.dayView) {
                  cubit.mockObject
                      .invokeMethod(ReceiveMethods.previousDay, null);
                } else if (view == CalendarViewType.weekView) {
                  cubit.mockObject
                      .invokeMethod(ReceiveMethods.previousWeek, null);
                } else if (view == CalendarViewType.monthView) {
                  cubit.mockObject
                      .invokeMethod(ReceiveMethods.previousMonth, null);
                } else if (view == CalendarViewType.termView) {
                  cubit.mockObject
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
                            BlocProvider.of<TimeTableCubit>(context)
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
                final CalendarViewType view = viewTypeNotifer.value;
                final TimeTableCubit cubit =
                    BlocProvider.of<TimeTableCubit>(context);
                if (view == CalendarViewType.dayView) {
                  cubit.mockObject.invokeMethod(ReceiveMethods.nextDay, null);
                } else if (view == CalendarViewType.weekView) {
                  cubit.mockObject.invokeMethod(ReceiveMethods.nextWeek, null);
                } else if (view == CalendarViewType.monthView) {
                  cubit.mockObject.invokeMethod(ReceiveMethods.nextMonth, null);
                } else if (view == CalendarViewType.termView) {
                  cubit.mockObject.invokeMethod(ReceiveMethods.nextTerm, null);
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
                Icons.calendar_month,
                color: Colors.black,
              ),
              onPressed: () {
                BlocProvider.of<TimeTableCubit>(context)
                    .mockObject
                    .invokeMethod(ReceiveMethods.jumpToCurrentDate, null);
              }),
          IconButton(
              icon: const Icon(
                Icons.image,
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
