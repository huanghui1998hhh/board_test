import 'package:flutter/material.dart';

import 'main.dart';

class Sketcher1 extends LeafRenderObjectWidget {
  final Set<RRect> rects;
  final Color color;

  const Sketcher1({
    super.key,
    required this.rects,
    this.color = Colors.black,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSketcher1(rects, color);

  @override
  void updateRenderObject(
          BuildContext context, covariant RenderSketcher1 renderObject) =>
      renderObject
        ..rects = rects
        ..color = color;
}

class RenderSketcher1 extends RenderBox {
  RenderSketcher1(this._rects, Color color)
      : pen = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

  Set<RRect> _rects;
  set rects(Set<RRect> value) {
    _rects = value;
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
  void performLayout() => size = A.a;
}
