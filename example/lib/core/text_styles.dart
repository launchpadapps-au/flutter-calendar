import 'package:edgar_planner_calendar_flutter/core/themes/colors.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/constants.dart';
import 'package:edgar_planner_calendar_flutter/core/themes/fonts.dart';
import 'package:flutter/material.dart';

///common text styles
///This [TextTheme] doesn't use google font and flutter_screenUtils
///because we are using custom ui for calendar component
extension TextThemes on BuildContext {
  ///true if mobile size is less then 600
  bool get isMobile => MediaQuery.of(this).size.width < mobileThreshold;

  ///textStyle for hour label in mobile
  TextStyle get hourLabelMobile => const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w500, color: textGrey);

  ///textStyle for hour label in tablet
  TextStyle get hourLabelTablet => const TextStyle(
        fontSize: 14,
        color: textGrey,
        fontWeight: FontWeight.w600,
      );

  ///subtitle1
  TextStyle get headline1 => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  ///headline 1 with font weight 500
  TextStyle get headline1Fw500 => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  ///headline 1 with font weight 500
  TextStyle get headline2Fw500 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );

  ///headline1 with noto sans

  TextStyle get headline1WithNotoSans => const TextStyle(
        fontSize: 16,
        fontFamily: Fonts.notoSans,
        fontWeight: FontWeight.bold,
      );

  ///subtitle
  TextStyle get subtitle => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );

  ///subtitle1
  TextStyle get subtitle1 => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  ///subtitle2
  TextStyle get subtitle2 => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  ///caption
  TextStyle get eventTitle => const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w500, color: textBlack);

  ///texTheme for the term planner

  TextStyle get termPlannerTitle => const TextStyle(
      color: darkestGrey, fontSize: 12, fontWeight: FontWeight.w500);

  ///texTheme for the term planner

  TextStyle get termPlannerTitle2 => const TextStyle(
      color: darkestGrey, fontSize: 14, fontWeight: FontWeight.w500);

  ///texTheme for the side strips

  TextStyle get stripsTheme => const TextStyle(
      color: textGrey, fontSize: 14, fontWeight: FontWeight.w700);

  ///texTheme for title of the note popup

  TextStyle get popuptitle => const TextStyle(
      color: textGrey,
      fontFamily: Fonts.quickSand,
      fontSize: 16,
      fontWeight: FontWeight.w600);

  ///texTheme for traling of the note popup
  TextStyle get popupTrailing => const TextStyle(
      color: textBlack,
      fontFamily: Fonts.quickSand,
      fontSize: 16,
      fontWeight: FontWeight.w600);

  ///texTheme for the side strips

  TextStyle get moreCount => const TextStyle(
      color: textBlack, fontSize: 14, fontWeight: FontWeight.w700);
}
