import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///linear indicator for the view
class LinearIndicator extends StatelessWidget {
  ///initialize the indicator
  const LinearIndicator({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PlannerCubit, PlannerState>(
          listener: (BuildContext context, PlannerState state) {},
          builder: (BuildContext context, PlannerState state) =>
              AnimatedCrossFade(
                  firstChild: const LinearProgressIndicator(
                    color: primaryPink,
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState:
                      BlocProvider.of<PlannerCubit>(context).isLoading
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 400)));
}
