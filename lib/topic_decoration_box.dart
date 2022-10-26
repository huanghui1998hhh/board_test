import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TopicDecorationBox extends SingleChildRenderObjectWidget {
  final double minWidth;
  final double maxWidth;
  final double step;

  const TopicDecorationBox({
    super.key,
    this.minWidth = 100,
    this.maxWidth = 320,
    this.step = 20,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderTopicDecorationBox(
        minwidth: minWidth,
        maxWidth: maxWidth,
        step: step,
      );

  @override
  void updateRenderObject(BuildContext context, RenderTopicDecorationBox renderObject) => renderObject
    ..minWidth = minWidth
    ..maxWidth = maxWidth
    ..step = step;
}

class RenderTopicDecorationBox extends RenderProxyBox {
  RenderTopicDecorationBox({
    RenderBox? child,
    double minwidth = 100,
    double maxWidth = 320,
    double step = 20,
  })  : _minWidth = minwidth,
        _maxWidth = maxWidth,
        _step = step,
        super(child);

  double _step;
  double get step => _step;
  set step(double value) {
    if (_step == value) {
      return;
    }

    _step = value;
    markNeedsPaint();
  }

  double _minWidth;
  double get minWidth => _minWidth;
  set minWidth(double value) {
    if (_minWidth == value) {
      return;
    }

    _minWidth = value;
    markNeedsPaint();
  }

  double _maxWidth;
  double get maxWidth => _maxWidth;
  set maxWidth(double value) {
    if (_maxWidth == value) {
      return;
    }

    _maxWidth = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      final tempHeight = child!.size.height;

      child!.layout(BoxConstraints(maxWidth: maxWidth), parentUsesSize: true);

      if (child!.size.height > tempHeight) {
        size = child!.size;
        return;
      }

      int flag = 0;

      while (child!.size.height == tempHeight && (maxWidth - step * flag) > minWidth) {
        flag++;
        child!.layout(BoxConstraints(maxWidth: maxWidth - step * flag), parentUsesSize: true);
      }

      child!.layout(BoxConstraints(maxWidth: maxWidth - step * (flag - 1)), parentUsesSize: true);

      size = child!.size;
    } else {
      size = constraints.constrain(Size.zero);
    }
  }
}
