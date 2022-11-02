import 'dart:math';

import 'package:board_test/hover_indicatable.dart';
import 'package:board_test/topic.dart';
import 'package:board_test/topic_block.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

double _yPadding = 20;
double _xPadding = 50;

class SketcherContnetStack extends MultiChildRenderObjectWidget {
  SketcherContnetStack({
    super.key,
    List<Widget> children = const [],
  }) : super(children: children);

  @override
  RenderSketcherContnetStack createRenderObject(BuildContext context) => RenderSketcherContnetStack();
}

class RenderSketcherContnetStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderHoverIndicatable, SketcherStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderHoverIndicatable, SketcherStackParentData> {
  RenderSketcherContnetStack({
    List<RenderHoverIndicatable>? children,
  }) {
    addAll(children);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void dropChild(covariant RenderHoverIndicatable child) {
    (child.parentData! as SketcherStackParentData).topic?.render = null;
    super.dropChild(child);
  }

  void childOnTapHandle(RenderHoverIndicatable? onTapChild) {
    RenderHoverIndicatable? child = firstChild;

    while (child != null) {
      child.isSelected = child == onTapChild;
      child = (child.parentData! as SketcherStackParentData).nextSibling;
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SketcherStackParentData) {
      child.parentData = SketcherStackParentData();
    }
  }

  Set<Path> paths = {};

  RenderHoverIndicatable _layoutMainTopic() {
    final child =
        getChildrenAsList().firstWhereOrNull((e) => (e.parentData! as SketcherStackParentData).topic!.father == null)!;

    final SketcherStackParentData childParentData = child.parentData! as SketcherStackParentData;

    layoutHepler(child, constraints);
    childParentData.offset = (size / 2) - child.size as Offset;
    return child;
  }

  @override
  void performLayout() {
    paths.clear();
    size = constraints.biggest;

    List<RenderHoverIndicatable> fatherTemp = [_layoutMainTopic()];
    List<RenderHoverIndicatable> temp =
        (fatherTemp.single.parentData! as SketcherStackParentData).topic!.children.map((e) => e.render!).toList();

    Offset centerYWithX = Offset(
        (fatherTemp.first.parentData! as SketcherStackParentData).offset.dx + fatherTemp.first.size.width + _xPadding,
        (fatherTemp.first.parentData! as SketcherStackParentData).offset.dy + fatherTemp.first.size.height / 2);

    while (temp.isNotEmpty) {
      double height = 0;
      double tempWidth = 0;

      for (var e in temp) {
        final layoutSize = layoutHepler(e, constraints);
        height += layoutSize.height;
        tempWidth = max(tempWidth, layoutSize.width);
      }

      height += (temp.length - 1) * _yPadding;

      var tempOffset = centerYWithX.translate(0, -height / 2);

      final renderTemp = <RenderHoverIndicatable>[];

      for (var father in fatherTemp) {
        final fatherData = father.parentData! as SketcherStackParentData;

        for (var e in fatherData.topic!.children.map((e) => e.render!)) {
          final parentData = e.parentData! as SketcherStackParentData;
          parentData.offset = tempOffset;
          renderTemp.addAll(parentData.topic!.children.map((e) => e.render!));

          final startPoint =
              Offset(fatherData.offset.dx + father.size.width, fatherData.offset.dy + father.size.height / 2);
          final endPoint = Offset(tempOffset.dx, tempOffset.dy + e.size.height / 2);
          paths.add(Path()
            ..moveTo(startPoint.dx, startPoint.dy)
            ..cubicTo((startPoint.dx + endPoint.dx) / 2, startPoint.dy, (startPoint.dx + endPoint.dx) / 2, endPoint.dy,
                endPoint.dx, endPoint.dy));

          tempOffset = tempOffset.translate(0, _yPadding + e.size.height);
        }
      }

      centerYWithX = centerYWithX.translate(tempWidth + _xPadding, 0);
      fatherTemp = temp;
      temp = renderTemp;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (var element in paths) {
      context.canvas.drawPath(
        element.shift(offset),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    defaultPaint(context, offset);
  }

  static Size layoutHepler(RenderHoverIndicatable child, BoxConstraints constraints) {
    child.layout(constraints.loosen(), parentUsesSize: true);
    return child.size;
  }
}

class SketcherStackParentData extends ContainerBoxParentData<RenderHoverIndicatable> {
  Topic? topic;

  bool get isTopicData => topic != null;
}

class TopicBlockWrap extends ParentDataWidget<SketcherStackParentData> {
  const TopicBlockWrap({
    Key? key,
    this.topic,
    required TopicBlock child,
  }) : super(key: key, child: child);

  final Topic? topic;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is SketcherStackParentData);
    final SketcherStackParentData parentData = renderObject.parentData! as SketcherStackParentData;

    if (parentData.topic != topic) {
      parentData.topic = topic;
      parentData.topic?.render = renderObject as RenderHoverIndicatable;

      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderSketcherContnetStack) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SketcherContnetStack;
}
