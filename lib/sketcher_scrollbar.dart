import 'dart:async';

import 'package:board_test/sketcher_scrollbar_painter.dart';
import 'package:board_test/sketcher_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _kMinThumbExtent = 18.0;
const double _kScrollbarThickness = 6.0;
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 300);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 600);

class SketcherScrollbar extends StatefulWidget {
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
    this.margin = EdgeInsets.zero,
  })  : assert(!((thumbVisibility == false) && (trackVisibility ?? false)),
            'A scrollbar track cannot be drawn without a scrollbar thumb.'),
        assert(minThumbLength >= 0),
        assert(minOverscrollLength == null || minOverscrollLength <= minThumbLength),
        assert(minOverscrollLength == null || minOverscrollLength >= 0),
        assert(radius == null || shape == null);

  final Widget child;
  final SketcherController controller;
  final bool? thumbVisibility;
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
  final EdgeInsets margin;

  @override
  SketcherScrollbarState<SketcherScrollbar> createState() => SketcherScrollbarState<SketcherScrollbar>();
}

class SketcherScrollbarState<T extends SketcherScrollbar> extends State<T> with TickerProviderStateMixin<T> {
  Offset? _dragScrollbarAxisOffset;
  Timer? _fadeoutTimer;
  late AnimationController _fadeoutAnimationController;
  late Animation<double> _fadeoutOpacityAnimation;
  final GlobalKey _scrollbarPainterKey = GlobalKey();
  bool _hoverIsActive = false;

  @protected
  late final SketcherScrollbarPainter sketcherScrollbarPainter;

  @protected
  bool get showScrollbar => widget.thumbVisibility ?? false;

  bool get _showTrack => showScrollbar && (widget.trackVisibility ?? false);

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
      scrollAxis: widget.scrollAxis,
      margin: widget.margin,
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
      ..margin = widget.margin
      ..padding = MediaQuery.of(context).padding
      ..radius = widget.radius
      ..shape = widget.shape
      ..minLength = widget.minThumbLength
      ..ignorePointer = !enableGestures;
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.thumbVisibility != oldWidget.thumbVisibility) {
      if (widget.thumbVisibility ?? false) {
        assert(_debugScheduleCheckHasValidScrollPosition());
        _fadeoutTimer?.cancel();
        _fadeoutAnimationController.animateTo(1.0);
      } else {
        _fadeoutAnimationController.reverse();
      }
    }
  }

  void _updateScrollPosition(Offset updatedOffset) {
    assert(_dragScrollbarAxisOffset != null);

    late double primaryDelta;
    switch (widget.scrollAxis) {
      case SketcherScrollAxis.horizontal:
        primaryDelta = _dragScrollbarAxisOffset!.dx - updatedOffset.dx;
        break;
      case SketcherScrollAxis.vertical:
        primaryDelta = _dragScrollbarAxisOffset!.dy - updatedOffset.dy;
        break;
    }

    final double scrollOffsetLocal = sketcherScrollbarPainter.getTrackToScroll(primaryDelta);
    final double scrollOffsetGlobal = isVertical
        ? clampDouble(scrollOffsetLocal + widget.controller.dragOffset.dy, -widget.controller.lowerBoundY,
            widget.controller.lowerBoundY)
        : clampDouble(scrollOffsetLocal + widget.controller.dragOffset.dx, -widget.controller.lowerBoundX,
            widget.controller.lowerBoundX);

    sketcherScrollbarPainter.metricsDragOffset = scrollOffsetGlobal;

    widget.controller.dragOffset = isVertical
        ? Offset(widget.controller.dragOffset.dx, scrollOffsetGlobal)
        : Offset(scrollOffsetGlobal, widget.controller.dragOffset.dy);
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
    _dragScrollbarAxisOffset = localPosition;
  }

  @protected
  @mustCallSuper
  void handleThumbPressUpdate(Offset localPosition) {
    _updateScrollPosition(localPosition);
    _dragScrollbarAxisOffset = localPosition;
  }

  @protected
  @mustCallSuper
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    _maybeStartFadeoutTimer();
    _dragScrollbarAxisOffset = null;
  }

  void _handleTrackTapDown(TapDownDetails details) {
    final double tapResultOffset = sketcherScrollbarPainter.jumpTo(details.localPosition);
    widget.controller.dragOffset = isVertical
        ? Offset(widget.controller.dragOffset.dx, tapResultOffset)
        : Offset(tapResultOffset, widget.controller.dragOffset.dy);
  }

  bool get isVertical => widget.scrollAxis == SketcherScrollAxis.vertical;

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

    if (isVertical) {
      child = NotificationListener<SketcherVMetricsNotification>(
        onNotification: _handleScrollMetricsNotification,
        child: child,
      );
    } else {
      child = NotificationListener<SketcherHMetricsNotification>(
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
