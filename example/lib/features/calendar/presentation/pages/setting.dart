import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_event_state.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/method_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

///setting Drawer
class SettingDrawer extends StatefulWidget {
  ///setting drawer
  const SettingDrawer({
    required this.endDate,
    required this.startDate,
    required this.onDateChange,
    this.isMobile = false,
    Key? key,
  }) : super(key: key);

  ///start date
  final DateTime startDate;

  /// end date
  final DateTime endDate;

  /// give callback when date changed

  ///bool isMobile
  final bool isMobile;

  ///onDateChange function will called on date changed
  final Function(DateTime startDate, DateTime endDate) onDateChange;

  @override
  State<SettingDrawer> createState() => _SettingDrawerState();
}

class _SettingDrawerState extends State<SettingDrawer> {
  late DateTime startDate, endDate;

  @override
  void initState() {
    startDate = widget.startDate;
    endDate = widget.endDate;
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isMobile = size.width < mobileThreshold;
    return BlocBuilder<TimeTableCubit, TimeTableState>(
      builder: (BuildContext context, TimeTableState state) => BlocProvider.of<
                  TimeTableCubit>(context)
              .standAlone
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: size.height,
                  color: Colors.white,
                  width: isMobile ? size.width * 0.85 : size.width * .5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Calendar View'),
                      Wrap(
                        runSpacing: mainMargin,
                        spacing: mainMargin,
                        children: <Widget>[
                          ElevatedButton(
                              child: const Text('Day view'),
                              onPressed: () {
                                BlocProvider.of<TimeTableCubit>(context)
                                    .changeViewType(CalendarViewType.dayView);
                                TimeTableCubit.mockObject.invokeMethod(
                                    ReceiveMethods.jumpToCurrentDate, null);
                              }),
                          ElevatedButton(
                            child: const Text('Week view'),
                            onPressed: () {
                              BlocProvider.of<TimeTableCubit>(context)
                                  .changeViewType(CalendarViewType.weekView);
                              TimeTableCubit.mockObject.invokeMethod(
                                  ReceiveMethods.jumpToCurrentDate, null);
                            },
                          ),
                          ElevatedButton(
                              child: const Text('Schedule view'),
                              onPressed: () {
                                BlocProvider.of<TimeTableCubit>(context)
                                    .changeViewType(
                                        CalendarViewType.scheduleView);
                                TimeTableCubit.mockObject.invokeMethod(
                                    ReceiveMethods.jumpToCurrentDate, null);
                              }),
                          isMobile
                              ? const SizedBox.shrink()
                              : ElevatedButton(
                                  child: const Text('Month view'),
                                  onPressed: () {
                                    BlocProvider.of<TimeTableCubit>(context)
                                        .changeViewType(
                                            CalendarViewType.monthView);
                                  },
                                ),
                          isMobile
                              ? const SizedBox.shrink()
                              : ElevatedButton(
                                  child: const Text('Term view'),
                                  onPressed: () {
                                    BlocProvider.of<TimeTableCubit>(context)
                                        .changeViewType(
                                            CalendarViewType.termView);
                                  },
                                ),
                          // ElevatedButton(
                          //     child: const Text('Gl Schedule view'),
                          //     onPressed: () {
                          //       BlocProvider.of<TimeTableCubit>(context)
                          //   .changeViewType(CalendarViewType.glScheduleView);
                          //     }),
                        ],
                      ),
                      const SizedBox(
                        height: mainMargin,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text('Calendar Dates'),
                        ],
                      ),
                      const SizedBox(
                        height: mainMargin,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            child: Text(startDate.toString().substring(0, 10)),
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: startDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2200))
                                  .then((DateTime? value) {
                                if (value != null) {
                                  setState(() {
                                    startDate = value;
                                    widget.onDateChange(startDate, endDate);
                                  });
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            width: mainMargin,
                          ),
                          ElevatedButton(
                            child: Text(endDate.toString().substring(0, 10)),
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: endDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2200))
                                  .then((DateTime? value) {
                                if (value != null) {
                                  setState(() {
                                    endDate = value;
                                    widget.onDateChange(startDate, endDate);
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
