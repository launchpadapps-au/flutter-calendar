// ignore_for_file: invalid_use_of_protected_member

library screenshot;

// import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:edgar_planner_calendar_flutter/core/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// controller for the screenshot
class ScreenshotController {
  ///initialize the controller
  ScreenshotController() {
    _containerKey = GlobalKey();
  }

  late GlobalKey _containerKey;

  ///it will capture ui image
  Future<ui.Image?> captureAsUiImage(
          {double? pixelRatio = 1,
          Duration delay = const Duration(milliseconds: 20)}) =>
      Future<ui.Image?>.delayed(delay, () async {
        late double? pr;
        try {
          final RenderObject? findRenderObject =
              _containerKey.currentContext?.findRenderObject();
          if (findRenderObject == null) {
            return null;
          }
          final RenderRepaintBoundary boundary =
              findRenderObject as RenderRepaintBoundary;
          final BuildContext? context = _containerKey.currentContext;
          if (pixelRatio == null) {
            if (context != null) {
              pr = pixelRatio ?? MediaQuery.of(context).devicePixelRatio;
            }
          }
          final ui.Image image = await boundary.toImage(pixelRatio: pr ?? 1);
          return image;
        } on Exception {
          throw ScreenShotException();
        }
      });

  ///
  /// Value for [delay] should increase with widget tree size.

  ///[context] parameter is used to Inherit App Theme and MediaQuery data.

  Future<Uint8List> captureFromWidget(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    final ui.Image image = await widgetToUiImage(widget,
        delay: delay,
        pixelRatio: pixelRatio,
        context: context,
        targetSize: targetSize);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return byteData!.buffer.asUint8List();
  }

  ///conver widhet to ui
  static Future<ui.Image> widgetToUiImage(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    ///
    ///Retry counter
    ///
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      ///
      ///Inherit Theme and MediaQuery of app
      ///
      ///
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              child: child,
              color: Colors.transparent,
            )),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final Size logicalSize = targetSize ??
        ui.window.physicalSize / ui.window.devicePixelRatio; // Adapted
    final Size imageSize = targetSize ?? ui.window.physicalSize; // Adapted

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
        imageSize.aspectRatio
            .toStringAsPrecision(5)); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      window: ui.window,
      child: RenderPositionedBox(child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(
        focusManager: FocusManager(),
        onBuildScheduled: () {
          ///
          ///current render is dirty, mark it.
          ///
          isDirty = true;
        });

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: child,
            )).attachToRenderTree(
      buildOwner,
    );
    ////
    ///Render Widget
    ///
    ///

    buildOwner
      ..buildScope(
        rootElement,
      )
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    ui.Image? image;

    do {
      ///
      ///Reset the dirty flag
      ///
      ///
      isDirty = false;

      image = await repaintBoundary.toImage(
          pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      ///
      ///This delay sholud increas with Widget tree Size
      ///

      await Future<void>.delayed(delay);

      ///
      ///Check does this require rebuild
      ///
      ///
      if (isDirty) {
        ///
        ///Previous capture has been updated, re-render again.
        ///
        ///
        buildOwner
          ..buildScope(
            rootElement,
          )
          ..finalizeTree();
        pipelineOwner
          ..flushLayout()
          ..flushCompositingBits()
          ..flushPaint();
      }
      retryCounter--;

      ///
      ///retry untill capture is successfull
      ///

    } while (isDirty && retryCounter >= 0);
    try {
      /// Dispose All widgets
      rootElement.visitChildren((Element element) {
        rootElement.deactivateChild(element);
      });
      buildOwner.finalizeTree();
    } on Exception catch (e) {
      logInfo(e.toString());
    }

    return image; // Adapted to directly return the image and not the Uint8List
  }
}

///Screenshot widget which require for capturing screenshot
class Screenshot extends StatefulWidget {
  ///initialize the widet
  const Screenshot({
    required this.child,
    required this.controller,
    Key? key,
  }) : super(key: key);

  ///child of the widget
  final Widget? child;

  ///controller of the widget
  final ScreenshotController controller;

  @override
  State<Screenshot> createState() => _ScreenshotState();
}

class _ScreenshotState extends State<Screenshot> with TickerProviderStateMixin {
  late ScreenshotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        key: _controller._containerKey,
        child: widget.child,
      );
}

///locl extension on double

extension Ex on double {
  ///return double with ficed precision
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

///[ScreenshotException will be throwe]

class ScreenShotException implements Exception {}
