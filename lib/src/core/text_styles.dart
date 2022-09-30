import 'package:flutter/material.dart';

///common text styles
///This [TextTheme] doesn't use google font and flutter_screenUtils
///because we are using custom ui for calendar component
extension TextThemes on BuildContext {
  ///headline1
  TextStyle get headline1 => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  ///subtitle1
  TextStyle get subtitle1 => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  ///subtitle2
  TextStyle get subtitle2 => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  ///caption
  TextStyle get caption => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
}
