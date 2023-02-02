import 'package:edgar_planner_calendar_flutter/core/themes/fonts.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:edgar_planner_calendar_flutter/features/calendar/presentation/pages/calendar_view.dart';
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
  Widget build(BuildContext context) => BlocProvider<TimeTableCubit>(
        create: (BuildContext context) => TimeTableCubit(),
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
          home: const CalendarView(),
        ),
      );
}

// class ListApp extends StatefulWidget {
//   const ListApp({super.key});

//   @override
//   State<ListApp> createState() => _ListAppState();
// }

// class _ListAppState extends State<ListApp> {
//   IndexedScrollController indexedScrollController =
// IndexedScrollController();
//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('title'),
//         ),
//         floatingActionButton: FloatingActionButton(onPressed: () {
//           getApplicationDocumentsDirectory().then((Directory value) {
//             logInfo(value.path);
//           });
//         }),
//         backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
//         body: IndexedListView.builder(
//           controller: indexedScrollController,
//           scrollDirection: Axis.horizontal,
//           itemBuilder: (BuildContext context, int index) => Container(
//             width: MediaQuery.of(context).size.width / 3,
//             child: Card(
//               margin: EdgeInsets.zero,
//               child: Center(child: Text('Item $index')),
//             ),
//           ),
//         ),
//       );
// }
