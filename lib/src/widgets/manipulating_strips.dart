import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/widgets/resizable_cell.dart';

///ball for drag
class ManipulatingStrip extends StatefulWidget {
  ///initialize the app
  const ManipulatingStrip({required this.onDrag, this.width = 30, super.key});

  ///double width
  final double width;

  ///onj drag method
  final Function onDrag;

  @override
  ManipulatingStripState createState() => ManipulatingStripState();
}

/// A stateful widget that is used to drag the ball.
class ManipulatingStripState extends State<ManipulatingStrip> {
  /// Declaring two variables, initX and initY, that are of type double.
  late double initX, initY;

  void _handleDrag(DragStartDetails details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  void _handleUpdate(DragUpdateDetails details) {
    final double dx = details.globalPosition.dx - initX;
    final double dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onPanStart: _handleDrag,
        onPanUpdate: _handleUpdate,
        child: Container(
          width: widget.width,
          height: ballDiameter,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
          ),
        ),
      );
}
