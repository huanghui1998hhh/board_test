import 'dart:ui';
import 'dart:math' as math;

import 'package:board_test/sketcher/sketcher_controller.dart';
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
    required this.sketcherController,
    required this.fadeoutOpacityAnimation,
    SketcherScrollAxis? scrollAxis,
    Color trackColor = const Color(0x00000000),
    Color trackBorderColor = const Color(0x00000000),
    TextDirection? textDirection,
    double thickness = _kScrollbarThickness,
    EdgeInsets padding = EdgeInsets.zero,
    Radius? radius,
    Radius? trackRadius,
    OutlinedBorder? shape,
    EdgeInsets margin = EdgeInsets.zero,
    double minLength = _kMinThumbExtent,
    ScrollbarOrientation? scrollbarOrientation,
    bool ignorePointer = false,
  })  : assert(radius == null || shape == null),
        assert(minLength >= 0),
        assert(padding.isNonNegative),
        _color = color,
        _textDirection = textDirection,
        _thickness = thickness,
        _radius = radius,
        _shape = shape,
        _padding = padding,
        _minLength = minLength,
        _trackColor = trackColor,
        _trackBorderColor = trackBorderColor,
        _trackRadius = trackRadius,
        _scrollAxis = scrollAxis,
        _margin = margin,
        _ignorePointer = ignorePointer {
    fadeoutOpacityAnimation.addListener(notifyListeners);
    sketcherController.addListener(notifyListeners);
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

  EdgeInsets get margin => _margin;
  EdgeInsets _margin;
  set margin(EdgeInsets value) {
    if (margin == value) {
      return;
    }

    _margin = value;
    notifyListeners();
  }

  EdgeInsets get padding => _padding;
  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (padding == value) {
      return;
    }

    _padding = value;
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

  final SketcherController sketcherController;
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

  final SketcherScrollAxis? _scrollAxis;
  Rect? _thumbRect;
  Rect? _trackRect;
  late double _thumbOffset;
  double get thumbOffset => _thumbOffset;

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

  void _paintScrollbar(Canvas canvas, Size size, double thumbExtent, SketcherScrollAxis scrollAxis) {
    assert(
      textDirection != null,
      'A TextDirection must be provided before a Scrollbar can be painted.',
    );

    final double x, y;
    final Size thumbSize, trackSize;
    final Offset trackOffset, borderStart, borderEnd;

    switch (scrollAxis) {
      case SketcherScrollAxis.vertical:
        thumbSize = Size(thickness, thumbExtent);
        trackSize = Size(thickness + margin.horizontal, _trackExtent);
        x = size.width - thickness - margin.right - padding.right;
        y = _thumbOffset;
        trackOffset = Offset(x - margin.left, margin.top + padding.top);
        borderStart = trackOffset;
        borderEnd = Offset(trackOffset.dx, trackOffset.dy + _trackExtent);

        break;
      case SketcherScrollAxis.horizontal:
        thumbSize = Size(thumbExtent, thickness);
        trackSize = Size(_trackExtent, thickness + margin.vertical);
        x = _thumbOffset;
        y = size.height - thickness - margin.bottom - padding.bottom;
        trackOffset = Offset(margin.left + padding.left, y - margin.top);
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

  double _thumbExtent() {
    final double fractionVisible = clampDouble(
        (_viewportDimension - _mainAxisPadding) / (_mainAxitSketcherSizeWithScale - _mainAxisPadding), 0.0, 1.0);

    final double thumbExtent = _trackExtent * fractionVisible;

    final double safeMinLength = math.min(minLength, _trackExtent);

    return clampDouble(thumbExtent, safeMinLength, _trackExtent);
  }

  @override
  void dispose() {
    fadeoutOpacityAnimation.removeListener(notifyListeners);
    sketcherController.removeListener(notifyListeners);
    super.dispose();
  }

  bool get _isVertical => _scrollAxis == SketcherScrollAxis.vertical;
  double get _mainAxisPadding => _isVertical ? padding.vertical : padding.horizontal;
  double get _mainAxisMargin => _isVertical ? margin.vertical : margin.horizontal;
  double get _draggedOffset => _isVertical ? sketcherController.offsetY : sketcherController.offsetX;
  double get _viewportDimension =>
      _isVertical ? sketcherController.viewportDimension.height : sketcherController.viewportDimension.width;
  double get _mainAxitSketcherSizeWithScale =>
      _isVertical ? sketcherController.sketcherSizeWithScale.height : sketcherController.sketcherSizeWithScale.width;
  double get _trackExtent => _viewportDimension - _mainAxisMargin - _mainAxisPadding;
  double get _scrollableExtent => _mainAxitSketcherSizeWithScale - _viewportDimension;

  double jumpTo(Offset tapLocalPosition) {
    final double mainAxisDetail = _isVertical ? tapLocalPosition.dy : tapLocalPosition.dx;
    final double mainMargin = _isVertical ? margin.top : margin.left;
    final double thumbExtent = _thumbExtent();
    final double scrollbarScrollableExtent = _trackExtent - thumbExtent;
    final double fractionPast =
        clampDouble(mainAxisDetail - mainMargin - thumbExtent / 2, 0, scrollbarScrollableExtent) /
            scrollbarScrollableExtent;
    final double lowerBound = (_mainAxitSketcherSizeWithScale - _viewportDimension) / 2;

    final double resultOffset = lerpDouble(lowerBound, -lowerBound, fractionPast)!;

    return resultOffset;
  }

  double getTrackToScroll(double thumbOffsetLocal) {
    final double thumbMovableExtent = _trackExtent - _thumbExtent();

    return _scrollableExtent * thumbOffsetLocal / thumbMovableExtent;
  }

  double _getScrollToTrack(double thumbExtent) {
    final double fractionPast = _scrollableExtent > 0
        ? clampDouble(((_scrollableExtent / 2) - _draggedOffset) / _scrollableExtent, 0.0, 1.0)
        : 0;

    return fractionPast * (_trackExtent - thumbExtent);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_mainAxitSketcherSizeWithScale < _viewportDimension) {
      return;
    }

    if (_trackExtent <= 0) {
      return;
    }

    final double beforePadding = _isVertical ? padding.top : padding.left;
    final double mainOffset = _isVertical ? margin.top : margin.left;
    final double thumbExtent = _thumbExtent();
    final double thumbOffsetLocal = _getScrollToTrack(thumbExtent);
    _thumbOffset = thumbOffsetLocal + mainOffset + beforePadding;

    return _paintScrollbar(canvas, size, thumbExtent, _scrollAxis!);
  }

  bool hitTestInteractive(Offset position, PointerDeviceKind kind, {bool forHover = false}) {
    if (_mainAxitSketcherSizeWithScale < _viewportDimension) {
      return false;
    }

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
    if (_mainAxitSketcherSizeWithScale < _viewportDimension) {
      return false;
    }

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
    if (_mainAxitSketcherSizeWithScale < _viewportDimension) {
      return null;
    }

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
        sketcherController != oldDelegate.sketcherController ||
        margin != oldDelegate.margin ||
        radius != oldDelegate.radius ||
        trackRadius != oldDelegate.trackRadius ||
        shape != oldDelegate.shape ||
        padding != oldDelegate.padding ||
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
