import 'package:flutter/material.dart';

class SelectedSketcher extends LeafRenderObjectWidget {
  final Set<RRect> rects;
  final Color color;
  final Size sketcherSize;

  const SelectedSketcher({
    super.key,
    required this.rects,
    required this.sketcherSize,
    this.color = Colors.black,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderSelectedSketcher(rects, color, sketcherSize);

  @override
  void updateRenderObject(BuildContext context, covariant RenderSelectedSketcher renderObject) => renderObject
    ..rects = rects
    ..color = color
    ..sketcherSize = sketcherSize;
}

class RenderSelectedSketcher extends RenderBox {
  RenderSelectedSketcher(this._rects, Color color, this._sketcherSize)
      : pen = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

  Set<RRect> _rects;
  set rects(Set<RRect> value) {
    _rects = value;
    markNeedsPaint();
  }

  final Size _sketcherSize;
  set sketcherSize(Size value) {
    if (_sketcherSize == value) {
      return;
    }

    value = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  Paint pen;

  set color(Color value) {
    pen.color = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (var e in _rects) {
      context.canvas.drawRRect(e, pen);
    }
  }

  @override
  bool get sizedByParent => false;

  @override
  void performLayout() => size = _sketcherSize;
}
