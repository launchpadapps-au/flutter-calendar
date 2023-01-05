import 'package:edgar_planner_calendar_flutter/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

///view header for export
class ExportHeader extends StatelessWidget {
  ///initilize the header
  const ExportHeader({required this.date, super.key});

  ///date for the header
  final DateTime date;

  @override
  Widget build(BuildContext context) => Container(
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: textGrey)),
      child: Center(
        child: Text(
            '${DateFormat('EEE').format(date).toUpperCase()}'
            ' • ${date.day}${DateFormat(' MMM').format(date)}',
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600, fontSize: 16, color: darkestGrey)),
      ));
}
