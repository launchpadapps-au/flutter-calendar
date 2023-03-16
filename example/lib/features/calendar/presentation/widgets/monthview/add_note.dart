import 'package:edgar_planner_calendar_flutter/core/text_styles.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/fonts.dart';
import 'package:flutter/material.dart';

///This widget will show pink popup for the add note
class AddNote extends StatelessWidget {
  ///initialize the add note
  const AddNote({required this.dateTime, super.key});

  ///date time of the popup
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.pop(context, true);
        },
        child: Container(
          height: 55,
          width: 144,
          decoration: BoxDecoration(
              color: lightPink,
              borderRadius: BorderRadius.circular(8),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(
                    4,
                    4,
                  ),
                  blurRadius: 14,
                  spreadRadius: 2,
                ), //BoxShadow
                const BoxShadow(
                  color: Colors.white,
                )
              ]), //B),
          child: Center(
              child: Text(
            '+ Add Note',
            style: context.popuptitle.copyWith(
                fontFamily: Fonts.sofiaPro,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          )),
        ),
      );
}
