import 'package:board_test/sketcher_data.dart';
import 'package:flutter/material.dart';

class SelectedSketcher extends LeafRenderObjectWidget {
  final Set<RRect> rects;
  final Color color;

  const SelectedSketcher({
    super.key,
    required this.rects,
    this.color = Colors.black,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderSelectedSketcher(rects, color);

  @override
  void updateRenderObject(BuildContext context, covariant RenderSelectedSketcher renderObject) => renderObject
    ..rects = rects
    ..color = color;
}

class RenderSelectedSketcher extends RenderBox {
  RenderSelectedSketcher(this._rects, Color color)
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
  bool get sizedByParent => false;

  @override
  void performLayout() => size = SketcherData.size;
}
