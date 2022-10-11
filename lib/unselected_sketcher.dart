import 'package:board_test/sketcher_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class UnselectedSketcher extends LeafRenderObjectWidget {
  final Set<RRect> rects;
  final Color color;
  final void Function(RRect)? onSelected;
  final void Function(Offset dragDelta)? onDraggedBoard;

  const UnselectedSketcher({
    super.key,
    required this.rects,
    this.color = Colors.black,
    this.onSelected,
    this.onDraggedBoard,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderUnselectedSketcher(rects, color, onSelected, onDraggedBoard);

  @override
  void updateRenderObject(BuildContext context, covariant RenderUnselectedSketcher renderObject) => renderObject
    ..rects = rects
    ..color = color
    ..onSelected = onSelected
    ..onDraggedBoard = onDraggedBoard;
}

class RenderUnselectedSketcher extends RenderBox {
  RenderUnselectedSketcher(this._rects, Color color, this.onSelected, this.onDraggedBoard)
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

  // Picture? _picture;
  // final _previous = Path();
  // var _current = Path();

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    // if (event is PointerDownEvent) {
    //   _current.moveTo(event.localPosition.dx, event.localPosition.dy);
    // } else if (event is PointerMoveEvent) {
    //   _current.lineTo(event.localPosition.dx, event.localPosition.dy);
    //   markNeedsPaint();
    // } else if (event is PointerUpEvent) {
    //   _previous.addPath(_current, Offset.zero);
    //   _current = Path();
    //   PictureRecorder recorder = PictureRecorder();
    //   Canvas canvas = Canvas(recorder);
    //   canvas.drawPath(_previous, pen2);
    //   _picture = recorder.endRecording();
    //   markNeedsPaint();
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

    // if (_picture != null) context.canvas.drawPicture(_picture!);
    // context.canvas.drawPath(_current, pen);
    // context.canvas
    //     .drawRRect(RRect.fromLTRBR(0, 0, 20, 20, Radius.circular(8)), pen);
    // TextPainter(text: TextSpan(text: "text"), textDirection: TextDirection.ltr)
    //   ..layout()
    //   ..paint(context.canvas, offset);

    for (var e in _rects) {
      context.canvas.drawRRect(e, pen);
    }
  }

  @override
  void performLayout() => size = SketcherData.size;

  @override
  bool hitTestSelf(Offset position) => true;
}
