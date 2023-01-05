import 'package:flutter/material.dart';

///size of the papper
class PapperSize {
  ///return a4 size paper
 static Size get a4 => const Size(210, 297);

  ///return a3 size paper
static  Size get a3 => const Size(297, 420);

  ///return a2 size paper
 static Size get a2 => const Size(420, 594);

  ///return a1 size paper
 static Size get a1 => const Size(594, 841);
}
