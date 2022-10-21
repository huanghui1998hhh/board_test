import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class UnselectedSketcher extends MultiChildRenderObjectWidget {
  final Set<RRect> rects;
  final Color color;
  final Size sketcherSize;

  final void Function(RRect)? onSelected;
  final void Function(Offset dragDelta)? onDraggedBoard;

  UnselectedSketcher({
    super.key,
    required this.rects,
    required this.sketcherSize,
    this.color = Colors.black,
    this.onSelected,
    this.onDraggedBoard,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderUnselectedSketcher(rects, color, sketcherSize, onSelected, onDraggedBoard);

  @override
  void updateRenderObject(BuildContext context, covariant RenderUnselectedSketcher renderObject) => renderObject
    ..rects = rects
    ..color = color
    ..sketcherSize = sketcherSize
    ..onSelected = onSelected
    ..onDraggedBoard = onDraggedBoard;
}

class RenderUnselectedSketcher extends RenderBox {
  RenderUnselectedSketcher(this._rects, Color color, this._sketcherSize, this.onSelected, this.onDraggedBoard)
      : pen = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

  Set<RRect> _rects;
  set rects(Set<RRect> value) {
    _rects = value;
    markNeedsPaint();
  }

  void Function(RRect)? onSelected;
  void Function(Offset)? onDraggedBoard;

  Paint pen;

  set color(Color value) {
    pen.color = value;
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

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    // if (event is PointerHoverEvent) {
    //   print(_rects.firstWhereOrNull((RRect e) => e.contains(event.localPosition)) != null);
    // }

    if (event is PointerDownEvent) {
      final rect = _rects.firstWhereOrNull((e) => e.contains(event.localPosition));
      if (rect != null) {
        onSelected?.call(rect);
      }
    }

    if (event is PointerMoveEvent) {
      onDraggedBoard?.call(event.delta);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.translate(offset.dx, offset.dy);

    TextPainter(text: const TextSpan(text: "text"), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(context.canvas, offset);

    for (var e in _rects) {
      context.canvas.drawRRect(e, pen);
    }
  }

  @override
  void performLayout() => size = _sketcherSize;

  @override
  bool get sizedByParent => false;

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }
}
