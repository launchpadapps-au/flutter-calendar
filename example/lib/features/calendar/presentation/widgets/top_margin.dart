 
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/bloc/time_table_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///linear indicator for the view
class TopMargin extends StatelessWidget {
  ///initialize the indicator
  const TopMargin({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<TimeTableCubit, TimeTableState>(
          listener: (BuildContext context, TimeTableState state) {},
          builder: (BuildContext context, TimeTableState state) => SizedBox(
                height: BlocProvider.of<TimeTableCubit>(context).topMargin,
              ));
}
