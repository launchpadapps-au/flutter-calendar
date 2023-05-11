import 'package:edgar_planner_calendar_flutter/core/themes/fonts.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/planner/presentation/pages/planner_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';

import 'generated/l10n.dart';

///logger object for the app
final Logger log = Logger('edgar-planner');

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((LogRecord record) {
    debugPrint(record.message);
  });
  runApp(const MyApp());
}

/// root app of the module
class MyApp extends StatelessWidget {
  ///
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider<PlannerCubit>(
        create: (BuildContext context) => PlannerCubit(),
        lazy: false,
        child: MaterialApp(
          theme: ThemeData(fontFamily: Fonts.sofiaPro),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: <PointerDeviceKind>{
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad
            },
          ),
          home: const PlannerView(),
        ),
      );
}
