import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Indexed List View
/// ListView that lets you jump instantly to any index.
/// Only works for lists with infinite extent.
class IndexedListView extends StatefulWidget {
  /// See [ListView.builder]
  IndexedListView.builder({
    required this.controller,
    required IndexedWidgetBuilderOrNull itemBuilder,
    this.emptyItemBuilder = defaultEmptyItemBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.physics,
    this.padding,
    this.scrollBehavior,
    this.pageSnapping = true,
    this.itemExtent,
    Key? key,
    int? maxItemCount,
    int? minItemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    this.cacheExtent,
  })  : separated = false,
        positiveChildrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int _index = index + controller._originIndex;
            if ((minItemCount != null && _index < minItemCount) ||
                (maxItemCount != null && _index > maxItemCount)) {
              return emptyItemBuilder(context, _index);
            } else {
              return itemBuilder(context, _index) ??
                  emptyItemBuilder(context, _index);
            }
          },
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        negativeChildrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int _index = -1 - index + controller._originIndex;
            if ((minItemCount != null && _index < minItemCount) ||
                (maxItemCount != null && _index > maxItemCount)) {
              return emptyItemBuilder(context, _index);
            } else {
              return itemBuilder(context, _index) ??
                  emptyItemBuilder(context, _index);
            }
          },
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        super(key: key);

  /// See [ListView.separated]
  IndexedListView.separated({
    required this.controller,
    required IndexedWidgetBuilderOrNull itemBuilder,
    required IndexedWidgetBuilderOrNull separatorBuilder,
    this.emptyItemBuilder = defaultEmptyItemBuilder,
    this.scrollDirection = Axis.vertical,
    this.scrollBehavior,
    Key? key,
    this.reverse = false,
    this.pageSnapping = true,
    this.physics,
    this.padding,
    int? maxItemCount,
    int? minItemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    this.cacheExtent,
  })  : separated = true,
        itemExtent = null,
        positiveChildrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int _index = (index ~/ 2) + controller._originIndex;
            if ((minItemCount != null && _index < minItemCount) ||
                (maxItemCount != null && _index > maxItemCount)) {
              return emptyItemBuilder(context, _index);
            } else {
              return index.isEven
                  ? (itemBuilder(context, _index) ??
                      emptyItemBuilder(context, _index))
                  : separatorBuilder(context, _index);
            }
          },
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        negativeChildrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int _index = ((-1 - index) ~/ 2) + controller._originIndex;
            if ((minItemCount != null && _index < minItemCount) ||
                (maxItemCount != null && _index > maxItemCount)) {
              return emptyItemBuilder(context, _index);
            } else {
              return index.isOdd
                  ? (itemBuilder(context, _index) ??
                      emptyItemBuilder(context, _index))
                  : separatorBuilder(context, _index);
            }
          },
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        super(key: key);

  ///defualt empty builder for the view
  static Widget defaultEmptyItemBuilder(BuildContext context, int index) =>
      const SizedBox(width: 5, height: 5);

  ///empty builder for the lsitview
  final IndexedWidgetBuilderOrNull emptyItemBuilder;

  ///pass tru if items are sperated
  final bool separated;

  /// See: [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// See: [ScrollView.reverse]
  final bool reverse;

  /// See: [ScrollView.controller]
  final IndexedScrollController controller;

  /// See: [ScrollView.physics]
  final ScrollPhysics? physics;

  /// See: [BoxScrollView.padding]
  final EdgeInsets? padding;

  /// See: [ListView.itemExtent]
  final double? itemExtent;

  /// See: [ScrollView.cacheExtent]
  final double? cacheExtent;

  ///seen [ScrollBehaviour]
  final ScrollBehavior? scrollBehavior;

  ///it will snap the page

  final bool pageSnapping;

  /// See: [ListView.childrenDelegate]
  final SliverChildDelegate negativeChildrenDelegate;

  /// See: [ListView.childrenDelegate]
  final SliverChildDelegate positiveChildrenDelegate;

  @override
  _IndexedListViewState createState() => _IndexedListViewState();
}

// --------------------------------------------------------------------------

/// The builder should create a widget for the given index.
/// When the builder returns `null`, the list will ask the `emptyItemBuilder`
/// to create an "empty" item to be displayed instead.
typedef IndexedWidgetBuilderOrNull = Widget? Function(
    BuildContext context, int index);

// -----------------------------------------------------------------------------

class _IndexedListViewState extends State<IndexedListView> {
  //
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void didUpdateWidget(IndexedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = _buildSlivers(context);
    final List<Widget> negativeSlivers = _buildSlivers(context, negative: true);
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics scrollPhysics =
        widget.physics ?? const _AlwaysScrollableScrollPhysics();

    final ScrollPhysics physics =
        const _ForceImplicitScrollPhysics(allowImplicitScrolling: true).applyTo(
            const PageScrollPhysics().applyTo(widget.physics ??
                widget.scrollBehavior?.getScrollPhysics(context)));
    return Scrollable(
      // Rebuild everything when the originIndex changes.
      key: ValueKey<int>(widget.controller._originIndex),
      axisDirection: axisDirection,
      controller: widget.controller,
      physics: widget.pageSnapping ? physics : scrollPhysics,
      viewportBuilder: (BuildContext context, ViewportOffset offset) =>
          Builder(builder: (BuildContext context) {
        // Build negative [ScrollPosition] for the negative scrolling [Viewport]
        final ScrollableState state = Scrollable.of(context)!;
        final _IndexedScrollPosition negativeOffset = _IndexedScrollPosition(
          physics: widget.pageSnapping ? physics : scrollPhysics,
          context: state,
          initialPixels: -offset.pixels,
          keepScrollOffset: false,
        );

        // Keep the negative scrolling [Viewport] positioned to the
        // [ScrollPosition].
        offset.addListener(() {
          negativeOffset._forceNegativePixels(offset.pixels);
        });

        /// Stack the two [Viewport]s on top of each other so they move in sync.
        return Stack(
          children: <Widget>[
            Viewport(
              axisDirection: flipAxisDirection(axisDirection),
              anchor: 1,
              offset: negativeOffset,
              slivers: negativeSlivers,
              cacheExtent: widget.cacheExtent,
            ),
            Viewport(
              axisDirection: axisDirection,
              offset: offset,
              slivers: slivers,
              cacheExtent: widget.cacheExtent,
            ),
          ],
        );
      }),
    );
  }

  AxisDirection _getDirection(BuildContext context) =>
      getAxisDirectionFromAxisReverseAndDirectionality(
          context, widget.scrollDirection, widget.reverse);

  List<Widget> _buildSlivers(BuildContext context, {bool negative = false}) {
    Widget sliver;
    if (widget.itemExtent != null) {
      sliver = SliverFixedExtentList(
        delegate: negative
            ? widget.negativeChildrenDelegate
            : widget.positiveChildrenDelegate,
        itemExtent: widget.itemExtent!,
      );
    } else {
      sliver = SliverList(
          delegate: negative
              ? widget.negativeChildrenDelegate
              : widget.positiveChildrenDelegate);
    }
    if (widget.padding != null) {
      sliver = SliverPadding(
        padding: negative
            ? widget.padding! - EdgeInsets.only(bottom: widget.padding!.bottom)
            : widget.padding! - EdgeInsets.only(top: widget.padding!.top),
        sliver: sliver,
      );
    }
    return <Widget>[sliver];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection))
      ..add(FlagProperty('reverse',
          value: widget.reverse, ifTrue: 'reversed', showName: true))
      ..add(DiagnosticsProperty<ScrollController>(
          'controller', widget.controller,
          showName: false, defaultValue: null))
      ..add(DiagnosticsProperty<ScrollPhysics>('physics', widget.physics,
          showName: false, defaultValue: null))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', widget.padding,
          defaultValue: null))
      ..add(DoubleProperty('itemExtent', widget.itemExtent, defaultValue: null))
      ..add(DoubleProperty('cacheExtent', widget.cacheExtent,
          defaultValue: null));
  }
}

// -----------------------------------------------------------------------------

class _AlwaysScrollableScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that always lets the user scroll.
  const _AlwaysScrollableScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  _AlwaysScrollableScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _AlwaysScrollableScrollPhysics(parent: buildParent(ancestor));

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;
}

class _ForceImplicitScrollPhysics extends ScrollPhysics {
  const _ForceImplicitScrollPhysics({
    required this.allowImplicitScrolling,
    super.parent,
  });

  @override
  _ForceImplicitScrollPhysics applyTo(ScrollPhysics? ancestor) =>
   _ForceImplicitScrollPhysics(
      allowImplicitScrolling: allowImplicitScrolling,
      parent: buildParent(ancestor),
    );

  @override
  final bool allowImplicitScrolling;
}
// ----------------------------------------------------------------------------

/// Provides scroll with infinite bounds, and keeps a
/// scroll-position and a origin-index.
/// The scroll-position is the number of pixels of scroll,
///  considering the item at origin-index
/// as the origin (0.0). So, for example,
/// if you have scroll-position 10.0 and origin-index 15,
/// then you are 10 pixels after the 15th item.
///
/// Besides regular [ScrollController] methods,
/// offers [IndexedScrollController.jumpToIndex]
/// and [IndexedScrollController.animateToIndex].

class IndexedScrollController extends ScrollController {
  ///initilize the scroll controller
  IndexedScrollController({
    this.initialIndex = 0,
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
  })  : _originIndex = initialIndex,
        super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  ///initila index
  final int initialIndex;

  /// the origin-index changes as the list jumps by index.
  int _originIndex = 0;

  ///orgin index
  int get originIndex => _originIndex;

  @override
  double get initialScrollOffset =>
      _initialScrollOffset ?? super.initialScrollOffset;

  double? _initialScrollOffset;

  /// Jumps the origin-index to the given [index],
  ///  and the scroll-position to [offset],
  /// without animation, and without checking if the new value is in range.
  ///
  /// Any active animation is canceled. If the user is currently scrolling, that
  /// action is canceled.
  void jumpToIndexAndOffset({required int index, required double offset}) {
    // If we didn't change the origin-index, go to its offset position.
    if (_originIndex == index) {
      super.jumpTo(offset);
    }
    // If we changed the origin, go to its offset position.
    else {
      _originIndex = index;
      _initialScrollOffset = offset;

      // Notify is enough. The key will change,
      // and the offset will revert to _initialScrollOffset),
      notifyListeners();
    }
  }

  ///Jumps the origin-index to the given [index],
  ///and the scroll-position to 0.0,
  /// without animation, and without checking if the new value is in range.
  ///
  /// Any active animation is canceled. If the user is currently scrolling, that
  /// action is canceled.
  void jumpToIndex(int index) {
    jumpToIndexAndOffset(index: index, offset: 0);
  }

  /// If the current origin-index is already the same as the given [index],
  /// animates the position from its current value to the [offset] position
  /// relative to the origin-index.
  ///
  /// The returned [Future] will complete when the animation ends, whether it
  /// completed successfully or whether it was interrupted prematurely.
  ///
  /// However, if the current origin-index is different from the given [index],
  /// this will jump to the new index, without any animation.
  Future<void> animateToIndexAndOffset({
    required int index,
    required double offset,
    Duration duration = const Duration(milliseconds: 750),
    Curve curve = Curves.decelerate,
  }) async {
    // If we didn't change origin, go to its 0.0 position.
    if (_originIndex == index) {
      _originIndex = index;
      return super.animateTo(offset, duration: duration, curve: curve);
    }
    // If we changed the origin, jump to the index and offset.
    else {
      jumpToIndexAndOffset(index: index, offset: offset);
    }
  }

  /// If the current origin-index is already the same as the given [index],
  /// animates the position from its current value to the 0.0 position
  /// relative to the origin-index.
  ///
  /// The returned [Future] will complete when the animation ends, whether it
  /// completed successfully or whether it was interrupted prematurely.
  ///
  /// However, if the current origin-index is different from the given [index],
  /// this will jump to the new position, without any animation.
  Future<void> animateToIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 750),
    Curve curve = Curves.decelerate,
  }) =>
      animateToIndexAndOffset(
          index: index, offset: 0, duration: duration, curve: curve);

  /// Goes to origin-index 0,
  /// and then jumps the scroll position
  /// from its current value to the given [offset],
  /// without animation, and without checking if the new value is in range.
  ///
  /// Any active animation is canceled. If the user is currently scrolling, that
  /// action is canceled.
  ///
  /// If this method changes the scroll position, a sequence of start/update/end
  /// scroll notifications will be dispatched. No overscroll notifications can
  /// be generated by this method.
  ///
  /// Immediately after the jump, a ballistic activity is started, in case the
  /// value was out of range.
  @override
  void jumpTo(double offset) {
    jumpToIndexAndOffset(index: 0, offset: offset);
  }

  /// Goes to origin-index 0,
  /// and then animates the position from its
  ///  current value to the given [offset].
  ///
  /// Any active animation is canceled. If the user is currently scrolling, that
  /// action is canceled.
  ///
  /// The returned [Future] will complete when the animation ends, whether it
  /// completed successfully or whether it was interrupted prematurely.
  ///
  /// An animation will be interrupted whenever the user attempts to scroll
  /// manually, or whenever another activity is started, or whenever the
  /// animation reaches the edge of the viewport and attempts to overscroll. (If
  /// the [ScrollPosition] does not overscroll but instead allows scrolling
  /// beyond the extents, then going beyond the extents will not interrupt the
  /// animation.)
  ///
  /// The animation is indifferent to changes to the viewport or content
  /// dimensions.
  ///
  /// Once the animation has completed, the scroll position will attempt to
  /// begin a ballistic activity in case its value is not stable (for example,
  /// if it is scrolled beyond the extents and in that situation the scroll
  /// position would normally bounce back).
  ///
  /// The duration must not be zero. To jump to a particular value without an
  /// animation, use [jumpTo].
  @override
  Future<void> animateTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 750),
    Curve curve = Curves.decelerate,
  }) =>
      animateToIndexAndOffset(
        index: 0,
        offset: offset,
        duration: duration,
        curve: curve,
      );

  /// Same as [jumpTo] but will keep the current origin-index.
  void jumpToWithSameOriginIndex(double offset) => super.jumpTo(offset);

  /// Same as [animateTo] but will keep the current origin-index.
  Future<void> animateToWithSameOriginIndex(
    double offset, {
    Duration duration = const Duration(milliseconds: 750),
    Curve curve = Curves.decelerate,
  }) =>
      super.animateTo(offset, duration: duration, curve: curve);

  /// Same as [jumpTo] but will move [offset] from the current position.
  void jumpToRelative(double offset) => super.jumpTo(this.offset + offset);

  /// Same as [animateTo] but will move [offset] from the current position.
  Future<void> animateToRelative(
    double offset, {
    Duration duration = const Duration(milliseconds: 750),
    Curve curve = Curves.decelerate,
  }) =>
      super.animateTo(this.offset + offset, duration: duration, curve: curve);

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
          ScrollContext context, ScrollPosition? oldPosition) =>
      _IndexedScrollPosition(
        physics: physics,
        context: context,
        initialPixels: initialScrollOffset,
        keepScrollOffset: keepScrollOffset,
        oldPosition: oldPosition,
        debugLabel: debugLabel,
      );
}

// -----------------------------------------------------------------------------

class _IndexedScrollPosition extends ScrollPositionWithSingleContext {
  _IndexedScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  void _forceNegativePixels(double offset) {
    super.forcePixels(-offset);
  }

  @override
  double get minScrollExtent => double.negativeInfinity;

  @override
  double get maxScrollExtent => double.infinity;
}
