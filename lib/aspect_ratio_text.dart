import 'package:flutter/material.dart';

class AspectRatioText extends LeafRenderObjectWidget {
  final InlineSpan text;
  final int? maxLines;
  final double idealRatio;

  const AspectRatioText(
    this.text, {
    super.key,
    this.maxLines,
    required this.idealRatio,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAspectRatioText(
        text,
        maxLines: maxLines,
        idealRatio: idealRatio,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, RenderAspectRatioText renderObject) => renderObject
    ..text = text
    ..maxLines = maxLines
    ..idealRatio = idealRatio;
}

class RenderAspectRatioText extends RenderBox {
  RenderAspectRatioText(
    InlineSpan text, {
    int? maxLines,
    TextAlign textAlign = TextAlign.start,
    required TextDirection textDirection,
    required double idealRatio,
  })  : _textPainter = TextPainter(
          text: text,
          maxLines: maxLines,
          textAlign: textAlign,
          textDirection: textDirection,
        ),
        _idealRatio = idealRatio;

  double _idealRatio;
  set idealRatio(double value) {
    if (_idealRatio == value) {
      return;
    }

    _idealRatio = value;
    markNeedsPaint();
  }

  final TextPainter _textPainter;
  set text(InlineSpan value) {
    _textPainter.text = value;

    markNeedsLayout();
  }

  set maxLines(int? value) {
    if (_textPainter.maxLines == value) {
      return;
    }

    _textPainter.maxLines = value;

    markNeedsLayout();
  }

  @override
  void performLayout() {
    _textPainter.layout();
    double lowerBound = 0;
    double upperBound = _textPainter.size.width;

    int count = 1;

    while (upperBound - lowerBound > 20) {
      count++;
      final newWidth = (lowerBound + upperBound) / 2;
      _textPainter.layout(maxWidth: newWidth);
      final currentRatio = _textPainter.size.aspectRatio;
      if (currentRatio < _idealRatio) {
        lowerBound = newWidth;
      } else {
        upperBound = newWidth;
      }
    }

    size = constraints.constrain(_textPainter.size);
    print(count);
  }

  @override
  void paint(PaintingContext context, Offset offset) => _textPainter.paint(context.canvas, offset);
}
