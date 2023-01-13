import 'package:edgar_planner_calendar_flutter/features/export/presentation/pages/export_setting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

///appbar for the calendar
class CalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  ///initialize the widset
  const CalendarAppBar({
    super.key,
  });

  @override
  State<CalendarAppBar> createState() => _CalendarAppBarState();

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}

class _CalendarAppBarState extends State<CalendarAppBar> {
  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () async {
              //   final List<PlannerEvent> events = dummyEventData;
              //   timeTableController.addEvent(
              //     events,
              //   );
            },
          ),
          IconButton(
              icon: const Icon(
                Icons.calendar_month,
                color: Colors.black,
              ),
              onPressed: () {}),
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
