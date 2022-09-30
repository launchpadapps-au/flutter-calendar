import 'dart:developer';

import 'package:flutter/material.dart';

///
class MainWidget extends StatefulWidget {
  ///
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  @override
  Widget build(BuildContext context) => Stack(
        children: const <Widget>[
          Positioned(
            child: ResizableCell(
              width: 200,
              top: 0,
              height: 150,
              minVertical: 0,
              maxVertical: 350,
              left: 0,
              child: Text('Event 1'),
            ),
          ),
          Positioned(
            child: ResizableCell(
              width: 200,
              top: 350,
              height: 150,
              maxVertical: 500,
              minVertical: 350,
              left: 0,
              child: Text('Event 2'),
            ),
          ),
          Positioned(
            child: ResizableCell(
              width: 200,
              top: 500,
              minVertical: 500,
              maxVertical: 750,
              height: 150,
              left: 0,
              child: Text('Event 3'),
            ),
          ),
          Positioned(
            child: ResizableCell(
              width: 200,
              top: 750,
              height: 150,
              maxVertical: 900,
              minVertical: 750,
              left: 0,
              child: Text('Event 4'),
            ),
          )
        ],
      );
}

///resizable widget
class ResizableCell extends StatefulWidget {
  /// initialized
  const ResizableCell(
      {required this.child,
      required this.height,
      required this.width,
      required this.left,
      required this.top,
      required this.maxVertical,
      required this.minVertical,
      this.isResizable = true,
      super.key});

  /// The height of the container.
  final double height;

  /// A named parameter.
  final double width;

  /// Used to set the maximum height of the widget.

  final double maxVertical;

  /// Used to set the minimum height of the widget.
  final double minVertical;

  /// Used to set the top position of the widget.

  final double top;

  /// Used to set the left position of the widget.
  final double left;

  /// Used to set the child of the widget.
  final Widget child;

  ///bool isResizable
  final bool isResizable;

  @override
  ResizableCellState createState() => ResizableCellState();
}

///ball diameter
const double ballDiameter = 20;

///state of the widget
class ResizableCellState extends State<ResizableCell> {
  /// The height of the container.
  late double height;

  /// A named parameter.
  late double width;

  /// A variable that is used to store the top position of the widget.
  double top = 0;

  /// Used to set the top and left position of the widget.

  double left = 0;

  /// If the new height is greater than 0, set the height to the new height,
  /// otherwise set the height to 0.
  /// Args:
  ///   dx (double): The horizontal distance the pointer has moved since the
  /// last report.
  ///   dy (double): The vertical distance that the pointer has moved since the
  /// previous
  void onDrag(double dx, double dy) {
    final double newHeight = height + dy;
    final double newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });
  }
///initial height of rhe cell
  double initialHeight = 0;
  ///initial width of the cell
  double initialWidth = 0;
  ///initial top of the the cell
  double initialTop = 0;
  @override
  void initState() {
    height = widget.height;
    width = widget.width;
    initialHeight = height;
    initialWidth = width;
    log('setting $top $height');
    top = widget.top;
    initialTop = top;
    left = widget.left;
    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Positioned(
            top: top,
            left: left,
            right: 0,
            child: SizedBox(
              height: height,
              width: width,
              child: Center(child: widget.child),
            ),
          ),
          // top left

          // top middle
          !widget.isResizable
              ? const SizedBox.shrink()
              : Positioned(
                  top: top - ballDiameter / 2,
                  child: ManipulatingStrip(
                    width: width,
                    onDragEnd: (double p0) {
                      final double max = widget.minVertical;
                      final double maxDy = max - widget.height - widget.top;

                      final double dy = max - p0;

                      final double percentage = (dy / maxDy) * 100;
                      if (percentage > 100) {
                        height = initialHeight;
                        top = initialTop;
                        setState(() {
                          log('dragged : $percentage');
                        });
                      } else {
                        log('dragged : $percentage');
                      }
                    },
                    onDrag: (double dx, double dy) {
                      final double newHeight = height - dy;

                      setState(() {
                        final double newTop = top + dy;
                        if (newTop >= widget.minVertical) {
                          top = newTop;
                          height = newHeight > 0 ? newHeight : 0;
                        } else {
                          log('can not drag upward');
                        }
                      });
                    },
                  ),
                ),

          // center right

          // bottom center
          !widget.isResizable
              ? const SizedBox.shrink()
              : Positioned(
                  top: top + height - ballDiameter / 2,
                  child: ManipulatingStrip(
                    width: width,
                    onDragEnd: (double p0) {
                      final double max = widget.maxVertical;
                      final double maxDy = max - widget.height - widget.top;

                      final double dy = max - p0;

                      final double percentage = (dy / maxDy) * 100;
                      if (percentage < 35) {
                        height = initialHeight;
                        top = initialTop;
                        setState(() {
                          log('dragged : $percentage');
                        });
                      } else {
                        log('dragged : $percentage');
                      }
                    },
                    onDrag: (double dx, double dy) {
                      final double newHeight = height + dy;

                      setState(() {
                        if (newHeight <= (widget.maxVertical)) {
                          height = newHeight > 0 ? newHeight : 0;
                        } else {
                          log('can not drag lower');
                        }
                      });
                    },
                  ),
                ),
        ],
      );
}

/// It creates a stateful widget that can be dragged.
class ManipulatingStrip extends StatefulWidget {
  ///initialize the app
  const ManipulatingStrip(
      {required this.onDrag,
      required this.onDragEnd,
      this.width = 30,
      super.key});

  ///double width
  final double width;

  ///onj drag method
  final Function onDrag;

  ///on vertical drag end
  final Function(double height) onDragEnd;
  @override
  ManipulatingStripState createState() => ManipulatingStripState();
}

/// It's a stateful widget that
/// has a gesture detector that calls the `onDrag` callback when the user drags
/// the  widget

class ManipulatingStripState extends State<ManipulatingStrip> {
  /// A variable that is used to store the initial x position of the widget.
  late double initX;

  /// Used to store the initial y position of the widget.
  late double initY;

  void _handleDrag(DragStartDetails details) {
    log('dragged');
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  void _handleUpdate(DragUpdateDetails details) {
    log('drag update');
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
        onTap: () {
          log('tap op edge');
        },
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _handleDrag,
        onVerticalDragUpdate: _handleUpdate,
        onVerticalDragEnd: (DragEndDetails details) {
          widget.onDragEnd(initY);
        },
        child: Container(
          width: widget.width,
          height: ballDiameter,
          decoration: const BoxDecoration(color: Colors.transparent),
        ),
      );
}
