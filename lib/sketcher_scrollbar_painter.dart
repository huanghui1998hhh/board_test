import 'dart:ui';

import 'package:board_test/sketcher_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kMinThumbExtent = 18.0;
const double _kMinInteractiveSize = 48.0;
const double _kScrollbarThickness = 6.0;

enum SketcherScrollAxis { horizontal, vertical }

class SketcherScrollbarPainter extends ChangeNotifier implements CustomPainter {
  SketcherScrollbarPainter({
    required Color color,
    required this.fadeoutOpacityAnimation,
    required SketcherScrollAxis scrollAxis,
    Color trackColor = const Color(0x00000000),
    Color trackBorderColor = const Color(0x00000000),
    TextDirection? textDirection,
    double thickness = _kScrollbarThickness,
    Radius? radius,
    Radius? trackRadius,
    OutlinedBorder? shape,
    double minLength = _kMinThumbExtent,
    double? minOverscrollLength,
    ScrollbarOrientation? scrollbarOrientation,
    bool ignorePointer = false,
  })  : assert(radius == null || shape == null),
        assert(minLength >= 0),
        assert(minOverscrollLength == null || minOverscrollLength <= minLength),
        assert(minOverscrollLength == null || minOverscrollLength >= 0),
        _color = color,
        _textDirection = textDirection,
        _thickness = thickness,
        _radius = radius,
        _shape = shape,
        _minLength = minLength,
        _trackColor = trackColor,
        _trackBorderColor = trackBorderColor,
        _trackRadius = trackRadius,
        _scrollAxis = scrollAxis,
        _ignorePointer = ignorePointer {
    fadeoutOpacityAnimation.addListener(notifyListeners);
  }

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (color == value) {
      return;
    }

    _color = value;
    notifyListeners();
  }

  Color get trackColor => _trackColor;
  Color _trackColor;
  set trackColor(Color value) {
    if (trackColor == value) {
      return;
    }

    _trackColor = value;
    notifyListeners();
  }

  Color get trackBorderColor => _trackBorderColor;
  Color _trackBorderColor;
  set trackBorderColor(Color value) {
    if (trackBorderColor == value) {
      return;
    }

    _trackBorderColor = value;
    notifyListeners();
  }

  Radius? get trackRadius => _trackRadius;
  Radius? _trackRadius;
  set trackRadius(Radius? value) {
    if (trackRadius == value) {
      return;
    }

    _trackRadius = value;
    notifyListeners();
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    assert(value != null);
    if (textDirection == value) {
      return;
    }

    _textDirection = value;
    notifyListeners();
  }

  double get thickness => _thickness;
  double _thickness;
  set thickness(double value) {
    if (thickness == value) {
      return;
    }

    _thickness = value;
    notifyListeners();
  }

  final Animation<double> fadeoutOpacityAnimation;

  Radius? get radius => _radius;
  Radius? _radius;
  set radius(Radius? value) {
    assert(shape == null || value == null);
    if (radius == value) {
      return;
    }

    _radius = value;
    notifyListeners();
  }

  OutlinedBorder? get shape => _shape;
  OutlinedBorder? _shape;
  set shape(OutlinedBorder? value) {
    assert(radius == null || value == null);
    if (shape == value) {
      return;
    }

    _shape = value;
    notifyListeners();
  }

  double get minLength => _minLength;
  double _minLength;
  set minLength(double value) {
    if (minLength == value) {
      return;
    }

    _minLength = value;
    notifyListeners();
  }

  bool get ignorePointer => _ignorePointer;
  bool _ignorePointer;
  set ignorePointer(bool value) {
    if (ignorePointer == value) {
      return;
    }

    _ignorePointer = value;
    notifyListeners();
  }

  SketcherPositionMetrics? _lastMetrics;
  final SketcherScrollAxis _scrollAxis;
  Rect? _thumbRect;
  Rect? _trackRect;
  late double _thumbOffset;

  void update(
    SketcherPositionMetrics metrics,
  ) {
    if (_lastMetrics != null &&
        _lastMetrics!.dragOffset == metrics.dragOffset &&
        _lastMetrics!.sketcherSizeWithScale == metrics.sketcherSizeWithScale &&
        _lastMetrics!.viewportDimension == metrics.viewportDimension) {
      return;
    }

    final SketcherPositionMetrics? oldMetrics = _lastMetrics;
    _lastMetrics = metrics;

    bool needPaint(SketcherPositionMetrics? metrics) =>
        metrics != null && metrics.sketcherSizeWithScale > metrics.viewportDimension;
    if (!needPaint(oldMetrics) && !needPaint(metrics)) {
      return;
    }

    notifyListeners();
  }

  void updateThickness(double nextThickness, Radius nextRadius) {
    thickness = nextThickness;
    radius = nextRadius;
  }

  Paint get _paintThumb {
    return Paint()..color = color.withOpacity(color.opacity * fadeoutOpacityAnimation.value);
  }

  Paint _paintTrack({bool isBorder = false}) {
    if (isBorder) {
      return Paint()
        ..color = trackBorderColor.withOpacity(trackBorderColor.opacity * fadeoutOpacityAnimation.value)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
    }
    return Paint()..color = trackColor.withOpacity(trackColor.opacity * fadeoutOpacityAnimation.value);
  }

  void _paintScrollbar(Canvas canvas, Size size, double thumbExtent) {
    assert(
      textDirection != null,
      'A TextDirection must be provided before a Scrollbar can be painted.',
    );

    final double x, y;
    final Size thumbSize, trackSize;
    final Offset trackOffset, borderStart, borderEnd;

    switch (_scrollAxis) {
      case SketcherScrollAxis.vertical:
        thumbSize = Size(thickness, thumbExtent);
        trackSize = Size(thickness, _trackExtent);
        x = size.width - thickness;
        y = _thumbOffset;
        trackOffset = Offset(x, 0);
        borderStart = trackOffset;
        borderEnd = Offset(trackOffset.dx, trackOffset.dy + _trackExtent);
        break;
      case SketcherScrollAxis.horizontal:
        thumbSize = Size(thumbExtent, thickness);
        trackSize = Size(_trackExtent, thickness);
        x = _thumbOffset;
        y = size.height - thickness;
        trackOffset = Offset(0, y);
        borderStart = trackOffset;
        borderEnd = Offset(trackOffset.dx + _trackExtent, trackOffset.dy);
        break;
    }

    _trackRect = trackOffset & trackSize;
    _thumbRect = Offset(x, y) & thumbSize;

    if (fadeoutOpacityAnimation.value != 0.0) {
      if (trackRadius == null) {
        canvas.drawRect(_trackRect!, _paintTrack());
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(_trackRect!, trackRadius!), _paintTrack());
      }
      canvas.drawLine(borderStart, borderEnd, _paintTrack(isBorder: true));
      if (radius != null) {
        canvas.drawRRect(RRect.fromRectAndRadius(_thumbRect!, radius!), _paintThumb);
        return;
      }
      if (shape == null) {
        canvas.drawRect(_thumbRect!, _paintThumb);
        return;
      }
      final Path outerPath = shape!.getOuterPath(_thumbRect!);
      canvas.drawPath(outerPath, _paintThumb);
      shape!.paint(canvas, _thumbRect!);
    }
  }

  double _thumbExtent() => _lastMetrics!.viewportDimension * _trackExtent / _lastMetrics!.sketcherSizeWithScale;

  @override
  void dispose() {
    fadeoutOpacityAnimation.removeListener(notifyListeners);
    super.dispose();
  }

  double get _trackExtent => _lastMetrics!.viewportDimension;

  double getTrackToScroll(double thumbOffsetLocal) {
    final double scrollableExtent = _lastMetrics!.sketcherSizeWithScale - _lastMetrics!.viewportDimension;
    final double thumbMovableExtent = _trackExtent - _thumbExtent();

    return scrollableExtent * thumbOffsetLocal / thumbMovableExtent;
  }

  double _getScrollToTrack(SketcherPositionMetrics metrics, double thumbExtent) {
    final double scrollableExtent = metrics.sketcherSizeWithScale - metrics.viewportDimension;

    final double fractionPast = (scrollableExtent > 0)
        ? clampDouble((metrics.dragOffset - (scrollableExtent / 2)) / scrollableExtent, 0.0, 1.0)
        : 0;

    return fractionPast * (_trackExtent - thumbExtent);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_lastMetrics == null || _lastMetrics!.sketcherSizeWithScale <= _lastMetrics!.viewportDimension) {
      return;
    }

    if (_trackExtent <= 0) {
      return;
    }

    final double thumbExtent = _thumbExtent();
    final double thumbOffsetLocal = _getScrollToTrack(_lastMetrics!, thumbExtent);
    _thumbOffset = thumbOffsetLocal;

    return _paintScrollbar(canvas, size, thumbExtent);
  }

  bool hitTestInteractive(Offset position, PointerDeviceKind kind, {bool forHover = false}) {
    if (_trackRect == null) {
      return false;
    }

    if (ignorePointer) {
      return false;
    }

    final Rect interactiveRect = _trackRect!;
    final Rect paddedRect = interactiveRect.expandToInclude(
      Rect.fromCircle(center: _thumbRect!.center, radius: _kMinInteractiveSize / 2),
    );

    if (fadeoutOpacityAnimation.value == 0.0) {
      if (forHover && kind == PointerDeviceKind.mouse) {
        return paddedRect.contains(position);
      }
      return false;
    }

    switch (kind) {
      case PointerDeviceKind.touch:
      case PointerDeviceKind.trackpad:
        return paddedRect.contains(position);
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
      case PointerDeviceKind.unknown:
        return interactiveRect.contains(position);
    }
  }

  bool hitTestOnlyThumbInteractive(Offset position, PointerDeviceKind kind) {
    if (_thumbRect == null) {
      return false;
    }
    if (ignorePointer) {
      return false;
    }

    if (fadeoutOpacityAnimation.value == 0.0) {
      return false;
    }

    switch (kind) {
      case PointerDeviceKind.touch:
      case PointerDeviceKind.trackpad:
        final Rect touchThumbRect = _thumbRect!.expandToInclude(
          Rect.fromCircle(center: _thumbRect!.center, radius: _kMinInteractiveSize / 2),
        );
        return touchThumbRect.contains(position);
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
      case PointerDeviceKind.unknown:
        return _thumbRect!.contains(position);
    }
  }

  @override
  bool? hitTest(Offset? position) {
    if (_thumbRect == null) {
      return null;
    }
    if (ignorePointer) {
      return false;
    }

    if (fadeoutOpacityAnimation.value == 0.0) {
      return false;
    }

    return _trackRect!.contains(position!);
  }

  @override
  bool shouldRepaint(SketcherScrollbarPainter oldDelegate) {
    return color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        trackBorderColor != oldDelegate.trackBorderColor ||
        textDirection != oldDelegate.textDirection ||
        thickness != oldDelegate.thickness ||
        fadeoutOpacityAnimation != oldDelegate.fadeoutOpacityAnimation ||
        radius != oldDelegate.radius ||
        trackRadius != oldDelegate.trackRadius ||
        shape != oldDelegate.shape ||
        minLength != oldDelegate.minLength ||
        ignorePointer != oldDelegate.ignorePointer;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  String toString() => describeIdentity(this);
}
