// ignore_for_file: invalid_use_of_visible_for_testing_member,
// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Sets up a collection of scroll controllers that mirror their movements to
/// each other.
///
/// Controllers are added and returned via [addAndGet]. The initial offset
/// of the newly created controller is synced to the current offset.
/// Controllers must be `dispose`d when no longer in use to prevent memory
/// leaks and performance degradation.
///
/// If controllers are disposed over the course of the lifetime of this
/// object the corresponding scrollables should be given unique keys.
/// Without the keys, Flutter may reuse a controller after it has been disposed,
/// which can cause the controller offsets to fall out of sync.
class LinkedScrollControllerGroup {
  ///initialize
  LinkedScrollControllerGroup() {
    _offsetNotifier = _LinkedScrollControllerGroupOffsetNotifier(this);
  }

  final List<_LinkedScrollController> _allControllers =
      <_LinkedScrollController>[];

  late _LinkedScrollControllerGroupOffsetNotifier _offsetNotifier;

  /// The current scroll offset of the group.
  double get offset {
    assert(
      _attachedControllers.isNotEmpty,
      'LinkedScrollControllerGroup does not have any scroll controllers '
      'attached.',
    );
    return _attachedControllers.first.offset;
  }

  /// Creates a new controller that is linked to any existing ones.
  ScrollController addAndGet() {
    final double initialScrollOffset = _attachedControllers.isEmpty
        ? 0.0
        : _attachedControllers.first.position.pixels;
    final _LinkedScrollController controller =
        _LinkedScrollController(this, initialScrollOffset: initialScrollOffset);
    _allControllers.add(controller);
    controller.addListener(_offsetNotifier.notifyListeners);
    return controller;
  }

  /// Adds a callback that will be called when the value of [offset] changes.
  void addOffsetChangedListener(VoidCallback onChanged) {
    _offsetNotifier.addListener(onChanged);
  }

  /// Removes the specified offset changed listener.
  void removeOffsetChangedListener(VoidCallback listener) {
    _offsetNotifier.removeListener(listener);
  }

  Iterable<_LinkedScrollController> get _attachedControllers => _allControllers
      .where((_LinkedScrollController controller) => controller.hasClients);

  /// Animates the scroll position of all linked controllers to [offset].
  Future<void> animateTo(
    double offset, {
    required Curve curve,
    required Duration duration,
  }) async {
    final List<Future<void>> animations = <Future<void>>[];
    for (final _LinkedScrollController controller in _attachedControllers) {
      animations
          .add(controller.animateTo(offset, duration: duration, curve: curve));
    }
    return Future.wait<void>(animations).then<void>((List<void> _) => null);
  }

  /// Jumps the scroll position of all linked controllers to [value].
  void jumpTo(double value) {
    for (final _LinkedScrollController controller in _attachedControllers) {
      controller.jumpTo(value);
    }
  }

  /// Resets the scroll position of all linked controllers to 0.
  void resetScroll() {
    jumpTo(0);
  }
}

/// This class provides change notification for [LinkedScrollControllerGroup]'s
/// scroll offset.
///
/// This change notifier de-duplicates change events by only firing listeners
/// when the scroll offset of the group has changed.
class _LinkedScrollControllerGroupOffsetNotifier extends ChangeNotifier {
  _LinkedScrollControllerGroupOffsetNotifier(this.controllerGroup);

  final LinkedScrollControllerGroup controllerGroup;

  /// The cached offset for the group.
  ///
  /// This value will be used in determining whether to notify listeners.
  double? _cachedOffset;

  @override
  void notifyListeners() {
    final double currentOffset = controllerGroup.offset;
    if (currentOffset != _cachedOffset) {
      _cachedOffset = currentOffset;
      super.notifyListeners();
    }
  }
}

/// A scroll controller that mirrors its movements to a peer, which must also
/// be a [_LinkedScrollController].
class _LinkedScrollController extends ScrollController {
  _LinkedScrollController(this._controllers,
      {required double initialScrollOffset})
      : super(
            initialScrollOffset: initialScrollOffset, keepScrollOffset: false);
  final LinkedScrollControllerGroup _controllers;

  @override
  void dispose() {
    _controllers._allControllers.remove(this);
    super.dispose();
  }

  @override
  void attach(ScrollPosition position) {
    assert(
        position is _LinkedScrollPosition,
        '_LinkedScrollControllers can only be used with'
        ' _LinkedScrollPositions.');
    final _LinkedScrollPosition linkedPosition =
        position as _LinkedScrollPosition;
    assert(linkedPosition.owner == this,
        '_LinkedScrollPosition cannot change controllers once created.');
    super.attach(position);
  }

  @override
  _LinkedScrollPosition createScrollPosition(ScrollPhysics physics,
          ScrollContext context, ScrollPosition? oldPosition) =>
      _LinkedScrollPosition(
        this,
        physics: physics,
        context: context,
        initialPixels: initialScrollOffset,
        oldPosition: oldPosition,
      );

  @override
  double get initialScrollOffset => _controllers._attachedControllers.isEmpty
      ? super.initialScrollOffset
      : _controllers.offset;

  @override
  _LinkedScrollPosition get position => super.position as _LinkedScrollPosition;

  Iterable<_LinkedScrollController> get _allPeersWithClients =>
      _controllers._attachedControllers
          .where((_LinkedScrollController peer) => peer != this);

  bool get canLinkWithPeers => _allPeersWithClients.isNotEmpty;

  Iterable<_LinkedScrollActivity> linkWithPeers(_LinkedScrollPosition driver) {
    assert(canLinkWithPeers);
    return _allPeersWithClients
        .map((_LinkedScrollController peer) => peer.link(driver))
        .expand((Iterable<_LinkedScrollActivity> e) => e);
  }

  Iterable<_LinkedScrollActivity> link(_LinkedScrollPosition driver) {
    assert(hasClients);
    final List<_LinkedScrollActivity> activities = <_LinkedScrollActivity>[];
    for (final ScrollPosition position in positions) {
      final _LinkedScrollPosition linkedPosition =
          position as _LinkedScrollPosition;
      activities.add(linkedPosition.link(driver));
    }
    return activities;
  }
}

// Implementation details: Whenever position.setPixels or position.forcePixels
// is called on a _LinkedScrollPosition (which may happen programmatically, or
// as a result of a user action),  the _LinkedScrollPosition creates a
// _LinkedScrollActivity for each linked position and uses it to move to or jump
// to the appropriate offset.
//
// When a new activity begins, the set of peer activities is cleared.
class _LinkedScrollPosition extends ScrollPositionWithSingleContext {
  _LinkedScrollPosition(
    this.owner, {
    required ScrollPhysics physics,
    required ScrollContext context,
    double? initialPixels,
    ScrollPosition? oldPosition,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          oldPosition: oldPosition,
        );

  final _LinkedScrollController owner;

  final Set<_LinkedScrollActivity> _peerActivities = <_LinkedScrollActivity>{};

  // We override hold to propagate it to all peer controllers.
  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    for (final _LinkedScrollController controller
        in owner._allPeersWithClients) {
      controller.position._holdInternal();
    }
    return super.hold(holdCancelCallback);
  }

  // Calls hold without propagating to peers.
  void _holdInternal() {
    super.hold(() {});
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (newActivity == null) {
      return;
    }
    for (final _LinkedScrollActivity activity in _peerActivities) {
      activity.unlink(this);
    }

    _peerActivities.clear();

    super.beginActivity(newActivity);
  }

  @override
  double setPixels(double newPixels) {
    if (newPixels == pixels) {
      return 0;
    }
    updateUserScrollDirection(newPixels - pixels > 0.0
        ? ScrollDirection.forward
        : ScrollDirection.reverse);

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (final _LinkedScrollActivity activity in _peerActivities) {
        activity.moveTo(newPixels);
      }
    }

    return setPixelsInternal(newPixels);
  }

  double setPixelsInternal(double newPixels) => super.setPixels(newPixels);

  @override
  void forcePixels(double value) {
    if (value == pixels) {
      return;
    }
    updateUserScrollDirection(value - pixels > 0.0
        ? ScrollDirection.forward
        : ScrollDirection.reverse);

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (final _LinkedScrollActivity activity in _peerActivities) {
        activity.jumpTo(value);
      }
    }

    forcePixelsInternal(value);
  }

  void forcePixelsInternal(double value) {
    super.forcePixels(value);
  }

  _LinkedScrollActivity link(_LinkedScrollPosition driver) {
    if (this.activity is! _LinkedScrollActivity) {
      beginActivity(_LinkedScrollActivity(this));
    }
    final _LinkedScrollActivity activity =
        (this.activity as _LinkedScrollActivity)..link(driver);
    return activity;
  }

  void unlink(_LinkedScrollActivity activity) {
    _peerActivities.remove(activity);
  }

  // We override this method to make it public (overridden method is protected)

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('owner: $owner');
  }
}

class _LinkedScrollActivity extends ScrollActivity {
  _LinkedScrollActivity(_LinkedScrollPosition delegate) : super(delegate);

  @override
  _LinkedScrollPosition get delegate => super.delegate as _LinkedScrollPosition;

  final Set<_LinkedScrollPosition> drivers = <_LinkedScrollPosition>{};

  void link(_LinkedScrollPosition driver) {
    drivers.add(driver);
  }

  void unlink(_LinkedScrollPosition driver) {
    drivers.remove(driver);
    if (drivers.isEmpty) {
      delegate.goIdle();
    }
  }

  @override
  bool get shouldIgnorePointer => true;

  @override
  bool get isScrolling => true;

  // _LinkedScrollActivity is not self-driven but moved by calls to the [moveTo]
  // method.
  @override
  double get velocity => 0;

  void moveTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.setPixelsInternal(newPixels);
  }

  void jumpTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.forcePixelsInternal(newPixels);
  }

  void _updateUserScrollDirection() {
    assert(drivers.isNotEmpty);
    ScrollDirection commonDirection = drivers.first.userScrollDirection;
    for (final _LinkedScrollPosition driver in drivers) {
      if (driver.userScrollDirection != commonDirection) {
        commonDirection = ScrollDirection.idle;
      }
    }
    delegate.updateUserScrollDirection(commonDirection);
  }

  @override
  void dispose() {
    for (final _LinkedScrollPosition driver in drivers) {
      driver.unlink(this);
    }
    super.dispose();
  }
}
