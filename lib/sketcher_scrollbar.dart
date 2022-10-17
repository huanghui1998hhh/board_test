// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:board_test/sketcher_scrollbar_painter.dart';
import 'package:board_test/sketcher_vm.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _kMinThumbExtent = 18.0;
const double _kScrollbarThickness = 6.0;
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 300);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 600);

class SketcherScrollbar extends StatefulWidget {
  /// Creates a basic raw scrollbar that wraps the given [child].
  ///
  /// The [child], or a descendant of the [child], should be a source of
  /// [ScrollNotification] notifications, typically a [Scrollable] widget.
  ///
  /// The [child], [fadeDuration], [pressDuration], and [timeToFade] arguments
  /// must not be null.
  const SketcherScrollbar({
    super.key,
    required this.child,
    required this.controller,
    required this.scrollAxis,
    this.thumbVisibility,
    this.shape,
    this.radius,
    this.thickness,
    this.thumbColor,
    this.minThumbLength = _kMinThumbExtent,
    this.minOverscrollLength,
    this.trackVisibility,
    this.trackRadius,
    this.trackColor,
    this.trackBorderColor,
    this.fadeDuration = _kScrollbarFadeDuration,
    this.timeToFade = _kScrollbarTimeToFade,
    this.pressDuration = Duration.zero,
    this.interactive,
    @Deprecated(
      'Use thumbVisibility instead. '
      'This feature was deprecated after v2.9.0-1.0.pre.',
    )
        this.isAlwaysShown,
  })  : assert(
            thumbVisibility == null || isAlwaysShown == null,
            'Scrollbar thumb appearance should only be controlled with thumbVisibility, '
            'isAlwaysShown is deprecated.'),
        assert(!((thumbVisibility == false || isAlwaysShown == false) && (trackVisibility ?? false)),
            'A scrollbar track cannot be drawn without a scrollbar thumb.'),
        assert(minThumbLength >= 0),
        assert(minOverscrollLength == null || minOverscrollLength <= minThumbLength),
        assert(minOverscrollLength == null || minOverscrollLength >= 0),
        assert(radius == null || shape == null);

  final Widget child;
  final SketcherController controller;
  final bool? thumbVisibility;
  @Deprecated(
    'Use thumbVisibility instead. '
    'This feature was deprecated after v2.9.0-1.0.pre.',
  )
  final bool? isAlwaysShown;
  final OutlinedBorder? shape;
  final Radius? radius;
  final double? thickness;
  final Color? thumbColor;
  final double minThumbLength;
  final double? minOverscrollLength;
  final bool? trackVisibility;
  final Radius? trackRadius;
  final Color? trackColor;
  final Color? trackBorderColor;
  final Duration fadeDuration;
  final Duration timeToFade;
  final Duration pressDuration;
  final bool? interactive;
  final SketcherScrollAxis scrollAxis;

  @override
  SketcherScrollbarState<SketcherScrollbar> createState() => SketcherScrollbarState<SketcherScrollbar>();
}

/// The state for a [SketcherScrollbar] widget, also shared by the [Scrollbar] and
/// [CupertinoScrollbar] widgets.
///
/// Controls the animation that fades a scrollbar's thumb in and out of view.
///
/// Provides defaults gestures for dragging the scrollbar thumb and tapping on the
/// scrollbar track.
class SketcherScrollbarState<T extends SketcherScrollbar> extends State<T> with TickerProviderStateMixin<T> {
  Timer? _fadeoutTimer;
  late AnimationController _fadeoutAnimationController;
  late Animation<double> _fadeoutOpacityAnimation;
  final GlobalKey _scrollbarPainterKey = GlobalKey();
  bool _hoverIsActive = false;

  /// Used to paint the scrollbar.
  ///
  /// Can be customized by subclasses to change scrollbar behavior by overriding
  /// [updateScrollbarPainter].
  @protected
  late final SketcherScrollbarPainter sketcherScrollbarPainter;

  /// Overridable getter to indicate that the scrollbar should be visible, even
  /// when a scroll is not underway.
  ///
  /// Subclasses can override this getter to make its value depend on an inherited
  /// theme.
  ///
  /// Defaults to false when [SketcherScrollbar.thumbVisibility] or
  /// [SketcherScrollbar.thumbVisibility] is null.
  ///
  /// See also:
  ///
  ///   * [SketcherScrollbar.thumbVisibility], which overrides the default behavior.
  @protected
  bool get showScrollbar => widget.isAlwaysShown ?? widget.thumbVisibility ?? false;

  bool get _showTrack => showScrollbar && (widget.trackVisibility ?? false);

  /// Overridable getter to indicate is gestures should be enabled on the
  /// scrollbar.
  ///
  /// When false, the scrollbar will not respond to gesture or hover events,
  /// and will allow to click through it.
  ///
  /// Subclasses can override this getter to make its value depend on an inherited
  /// theme.
  ///
  /// Defaults to true when [SketcherScrollbar.interactive] is null.
  ///
  /// See also:
  ///
  ///   * [SketcherScrollbar.interactive], which overrides the default behavior.
  @protected
  bool get enableGestures => widget.interactive ?? true;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    )..addStatusListener(_validateInteractions);
    _fadeoutOpacityAnimation = CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn,
    );
    sketcherScrollbarPainter = SketcherScrollbarPainter(
      color: widget.thumbColor ?? const Color(0x66BCBCBC),
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      thickness: widget.thickness ?? _kScrollbarThickness,
      radius: widget.radius,
      trackRadius: widget.trackRadius,
      shape: widget.shape,
      minLength: widget.minThumbLength,
      minOverscrollLength: widget.minOverscrollLength ?? widget.minThumbLength,
      scrollAxis: widget.scrollAxis,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(_debugScheduleCheckHasValidScrollPosition());
  }

  bool _debugScheduleCheckHasValidScrollPosition() {
    if (!showScrollbar) {
      return true;
    }
    return true;
  }

  void _validateInteractions(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      assert(_fadeoutOpacityAnimation.value == 0.0);
    }
  }

  @protected
  void updateScrollbarPainter() {
    sketcherScrollbarPainter
      ..color = widget.thumbColor ?? const Color(0x66BCBCBC)
      ..trackRadius = widget.trackRadius
      ..trackColor = _showTrack ? widget.trackColor ?? const Color(0x08000000) : const Color(0x00000000)
      ..trackBorderColor = _showTrack ? widget.trackBorderColor ?? const Color(0x1a000000) : const Color(0x00000000)
      ..textDirection = Directionality.of(context)
      ..thickness = widget.thickness ?? _kScrollbarThickness
      ..radius = widget.radius
      ..shape = widget.shape
      ..minLength = widget.minThumbLength
      ..ignorePointer = !enableGestures;
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAlwaysShown != oldWidget.isAlwaysShown || widget.thumbVisibility != oldWidget.thumbVisibility) {
      if ((widget.isAlwaysShown ?? false) || (widget.thumbVisibility ?? false)) {
        assert(_debugScheduleCheckHasValidScrollPosition());
        _fadeoutTimer?.cancel();
        _fadeoutAnimationController.animateTo(1.0);
      } else {
        _fadeoutAnimationController.reverse();
      }
    }
  }

  void _updateScrollPosition(Offset updatedOffset) {
    //TODO:
    // assert(_currentController != null);
    // assert(_dragScrollbarAxisOffset != null);

    // final ScrollPosition position = _currentController!.position;
    // late double primaryDelta;
    // switch (widget.scrollAxis) {
    //   case SketcherScrollAxis.horizontal:
    //     primaryDelta = updatedOffset.dx - _dragScrollbarAxisOffset!.dx;
    //     break;
    //   case SketcherScrollAxis.vertical:
    //     primaryDelta = updatedOffset.dy - _dragScrollbarAxisOffset!.dy;
    //     break;
    // }

    // final double scrollOffsetLocal = scrollbarPainter.getTrackToScroll(primaryDelta);
    // final double scrollOffsetGlobal = scrollOffsetLocal + position.pixels;
    // if (scrollOffsetGlobal != position.pixels) {
    //   final double physicsAdjustment = position.physics.applyBoundaryConditions(position, scrollOffsetGlobal);
    //   double newPosition = scrollOffsetGlobal - physicsAdjustment;

    //   switch (ScrollConfiguration.of(context).getPlatform(context)) {
    //     case TargetPlatform.fuchsia:
    //     case TargetPlatform.linux:
    //     case TargetPlatform.macOS:
    //     case TargetPlatform.windows:
    //       newPosition = clampDouble(newPosition, position.minScrollExtent, position.maxScrollExtent);
    //       break;
    //     case TargetPlatform.iOS:
    //     case TargetPlatform.android:
    //       break;
    //   }
    //   position.jumpTo(newPosition);
    // }
  }

  void _maybeStartFadeoutTimer() {
    if (!showScrollbar) {
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(widget.timeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
  }

  /// Handler called when a press on the scrollbar thumb has been recognized.
  ///
  /// Cancels the [Timer] associated with the fade animation of the scrollbar.
  @protected
  @mustCallSuper
  void handleThumbPress() {
    _fadeoutTimer?.cancel();
  }

  @protected
  @mustCallSuper
  void handleThumbPressStart(Offset localPosition) {
    _fadeoutTimer?.cancel();
    _fadeoutAnimationController.forward();
  }

  @protected
  @mustCallSuper
  void handleThumbPressUpdate(Offset localPosition) {
    _updateScrollPosition(localPosition);
  }

  @protected
  @mustCallSuper
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    _maybeStartFadeoutTimer();
  }

  void _handleTrackTapDown(TapDownDetails details) {
    //TODO:
    // _currentController = widget.controller;

    // double scrollIncrement;

    // final ScrollIncrementCalculator? calculator = Scrollable.of(
    //   _currentController!.position.context.notificationContext!,
    // )?.widget.incrementCalculator;
    // if (calculator != null) {
    //   scrollIncrement = calculator(
    //     ScrollIncrementDetails(
    //       type: ScrollIncrementType.page,
    //       metrics: _currentController!.position,
    //     ),
    //   );
    // } else {
    //   // Default page increment
    //   scrollIncrement = 0.8 * _currentController!.position.viewportDimension;
    // }

    // // Adjust scrollIncrement for direction
    // switch (widget.scrollAxis) {
    //   case SketcherScrollAxis.vertical:
    //     if (details.localPosition.dy < scrollbarPainter.thumbOffset) {
    //       scrollIncrement = -scrollIncrement;
    //     }
    //     break;
    //   case SketcherScrollAxis.horizontal:
    //     if (details.localPosition.dx < scrollbarPainter.thumbOffset) {
    //       scrollIncrement = -scrollIncrement;
    //     }
    //     break;
    // }

    // _currentController!.position.moveTo(
    //   _currentController!.position.pixels + scrollIncrement,
    //   duration: const Duration(milliseconds: 100),
    //   curve: Curves.easeInOut,
    // );
  }

  bool _handleScrollMetricsNotification(SketcherMetricsNotification notification) {
    if (showScrollbar) {
      if (_fadeoutAnimationController.status != AnimationStatus.forward &&
          _fadeoutAnimationController.status != AnimationStatus.completed) {
        _fadeoutAnimationController.forward();
      }
    }

    final SketcherPositionMetrics metrics = notification.metrics;

    sketcherScrollbarPainter.update(metrics, widget.scrollAxis);

    return false;
  }

  Map<Type, GestureRecognizerFactory> get _gestures {
    final Map<Type, GestureRecognizerFactory> gestures = <Type, GestureRecognizerFactory>{};
    if (!enableGestures) {
      return gestures;
    }

    gestures[_ThumbPressGestureRecognizer] = GestureRecognizerFactoryWithHandlers<_ThumbPressGestureRecognizer>(
      () => _ThumbPressGestureRecognizer(
        debugOwner: this,
        customPaintKey: _scrollbarPainterKey,
        pressDuration: widget.pressDuration,
      ),
      (_ThumbPressGestureRecognizer instance) {
        instance.onLongPress = handleThumbPress;
        instance.onLongPressStart = (LongPressStartDetails details) => handleThumbPressStart(details.localPosition);
        instance.onLongPressMoveUpdate =
            (LongPressMoveUpdateDetails details) => handleThumbPressUpdate(details.localPosition);
        instance.onLongPressEnd =
            (LongPressEndDetails details) => handleThumbPressEnd(details.localPosition, details.velocity);
      },
    );

    gestures[_TrackTapGestureRecognizer] = GestureRecognizerFactoryWithHandlers<_TrackTapGestureRecognizer>(
      () => _TrackTapGestureRecognizer(
        debugOwner: this,
        customPaintKey: _scrollbarPainterKey,
      ),
      (_TrackTapGestureRecognizer instance) {
        instance.onTapDown = _handleTrackTapDown;
      },
    );

    return gestures;
  }

  @protected
  bool isPointerOverTrack(Offset position, PointerDeviceKind kind) {
    if (_scrollbarPainterKey.currentContext == null) {
      return false;
    }
    final Offset localOffset = _getLocalOffset(_scrollbarPainterKey, position);
    return sketcherScrollbarPainter.hitTestInteractive(localOffset, kind) &&
        !sketcherScrollbarPainter.hitTestOnlyThumbInteractive(localOffset, kind);
  }

  @protected
  bool isPointerOverThumb(Offset position, PointerDeviceKind kind) {
    if (_scrollbarPainterKey.currentContext == null) {
      return false;
    }
    final Offset localOffset = _getLocalOffset(_scrollbarPainterKey, position);
    return sketcherScrollbarPainter.hitTestOnlyThumbInteractive(localOffset, kind);
  }

  @protected
  bool isPointerOverScrollbar(Offset position, PointerDeviceKind kind, {bool forHover = false}) {
    if (_scrollbarPainterKey.currentContext == null) {
      return false;
    }
    final Offset localOffset = _getLocalOffset(_scrollbarPainterKey, position);
    return sketcherScrollbarPainter.hitTestInteractive(localOffset, kind, forHover: true);
  }

  @protected
  @mustCallSuper
  void handleHover(PointerHoverEvent event) {
    if (isPointerOverScrollbar(event.position, event.kind, forHover: true)) {
      _hoverIsActive = true;
      _fadeoutAnimationController.forward();
      _fadeoutTimer?.cancel();
    } else if (_hoverIsActive) {
      _hoverIsActive = false;
      _maybeStartFadeoutTimer();
    }
  }

  @protected
  @mustCallSuper
  void handleHoverExit(PointerExitEvent event) {
    _hoverIsActive = false;
    _maybeStartFadeoutTimer();
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _fadeoutTimer?.cancel();
    sketcherScrollbarPainter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateScrollbarPainter();

    Widget child = RepaintBoundary(
      child: RawGestureDetector(
        gestures: _gestures,
        child: MouseRegion(
          onExit: (PointerExitEvent event) {
            switch (event.kind) {
              case PointerDeviceKind.mouse:
              case PointerDeviceKind.trackpad:
                if (enableGestures) {
                  handleHoverExit(event);
                }
                break;
              case PointerDeviceKind.stylus:
              case PointerDeviceKind.invertedStylus:
              case PointerDeviceKind.unknown:
              case PointerDeviceKind.touch:
                break;
            }
          },
          onHover: (PointerHoverEvent event) {
            switch (event.kind) {
              case PointerDeviceKind.mouse:
              case PointerDeviceKind.trackpad:
                if (enableGestures) {
                  handleHover(event);
                }
                break;
              case PointerDeviceKind.stylus:
              case PointerDeviceKind.invertedStylus:
              case PointerDeviceKind.unknown:
              case PointerDeviceKind.touch:
                break;
            }
          },
          child: CustomPaint(
            key: _scrollbarPainterKey,
            foregroundPainter: sketcherScrollbarPainter,
            child: RepaintBoundary(child: widget.child),
          ),
        ),
      ),
    );

    if (widget.scrollAxis == SketcherScrollAxis.horizontal) {
      child = NotificationListener<SketcherHMetricsNotification>(
        onNotification: _handleScrollMetricsNotification,
        child: child,
      );
    } else {
      child = NotificationListener<SketcherVMetricsNotification>(
        onNotification: _handleScrollMetricsNotification,
        child: child,
      );
    }

    return child;
  }
}

class _ThumbPressGestureRecognizer extends LongPressGestureRecognizer {
  _ThumbPressGestureRecognizer({
    required Object super.debugOwner,
    required GlobalKey customPaintKey,
    required Duration pressDuration,
  })  : _customPaintKey = customPaintKey,
        super(
          duration: pressDuration,
        );

  final GlobalKey _customPaintKey;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(_customPaintKey, event.position, event.kind)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }

  bool _hitTestInteractive(GlobalKey customPaintKey, Offset offset, PointerDeviceKind kind) {
    if (customPaintKey.currentContext == null) {
      return false;
    }
    final CustomPaint customPaint = customPaintKey.currentContext!.widget as CustomPaint;
    final SketcherScrollbarPainter painter = customPaint.foregroundPainter! as SketcherScrollbarPainter;
    final Offset localOffset = _getLocalOffset(customPaintKey, offset);
    return painter.hitTestOnlyThumbInteractive(localOffset, kind);
  }
}

class _TrackTapGestureRecognizer extends TapGestureRecognizer {
  _TrackTapGestureRecognizer({
    required Object debugOwner,
    required GlobalKey customPaintKey,
  })  : _customPaintKey = customPaintKey,
        super(debugOwner: debugOwner);

  final GlobalKey _customPaintKey;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(_customPaintKey, event.position, event.kind)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }

  bool _hitTestInteractive(GlobalKey customPaintKey, Offset offset, PointerDeviceKind kind) {
    if (customPaintKey.currentContext == null) {
      return false;
    }
    final CustomPaint customPaint = customPaintKey.currentContext!.widget as CustomPaint;
    final SketcherScrollbarPainter painter = customPaint.foregroundPainter! as SketcherScrollbarPainter;
    final Offset localOffset = _getLocalOffset(customPaintKey, offset);
    return painter.hitTestInteractive(localOffset, kind) && !painter.hitTestOnlyThumbInteractive(localOffset, kind);
  }
}

Offset _getLocalOffset(GlobalKey scrollbarPainterKey, Offset position) {
  final RenderBox renderBox = scrollbarPainterKey.currentContext!.findRenderObject()! as RenderBox;
  return renderBox.globalToLocal(position);
}

class SketcherHMetricsNotification extends SketcherMetricsNotification {
  SketcherHMetricsNotification(super.metrics);
}

class SketcherVMetricsNotification extends SketcherMetricsNotification {
  SketcherVMetricsNotification(super.metrics);
}

abstract class SketcherMetricsNotification extends Notification {
  SketcherMetricsNotification(this.metrics);

  final SketcherPositionMetrics metrics;
}
