import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///op[en given url in browser
Future<void> launchLink(String link, BuildContext context) async {
  await BlocProvider.of<PlannerCubit>(context).nativeCallBack.openUrl(link);
  // final Uri url = Uri.parse(link);
  // if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //   ///can not lauch url
  //   logInfo('can not launch url');
  // }
}
