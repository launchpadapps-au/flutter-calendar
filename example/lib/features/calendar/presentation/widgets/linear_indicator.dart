import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///linear indicator for the view
class LinearIndicator extends StatelessWidget {
  ///initialize the indicator
  const LinearIndicator({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<TimeTableCubit, TimeTableState>(
          listener: (BuildContext context, TimeTableState state) {},
          builder: (BuildContext context, TimeTableState state) =>
              AnimatedCrossFade(
                  firstChild: const LinearProgressIndicator(
                    color: primaryPink,
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState:
                      BlocProvider.of<TimeTableCubit>(context).isLoading
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 400)));
}
