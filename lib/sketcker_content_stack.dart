import 'package:board_test/hover_indicatable.dart';
import 'package:board_test/topic.dart';
import 'package:board_test/topic_block.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

double _padding = 20;

class SketcherContnetStack extends MultiChildRenderObjectWidget {
  SketcherContnetStack({
    super.key,
    List<TopicBlockWrap> children = const [],
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
  void insert(RenderHoverIndicatable child, {RenderHoverIndicatable? after}) {
    super.insert(child, after: after);
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

  @override
  void performLayout() {
    paths.clear();
    size = constraints.biggest;

    final childs = getChildrenAsList();

    RenderHoverIndicatable? child =
        childs.firstWhereOrNull((e) => (e.parentData! as SketcherStackParentData).fatherRender.isEmpty);

    if (child != null) {
      childs.remove(child);

      final SketcherStackParentData childParentData = child.parentData! as SketcherStackParentData;

      layoutHepler(child, constraints);
      childParentData.offset = (size / 2) - child.size as Offset;

      double height = 0;

      for (var e in childs) {
        height += layoutHepler(e, constraints).height;
      }

      height += (childs.length - 1) * _padding;

      Offset tempOffset = childParentData.offset.translate(child.size.width + 50, (child.size.height - height) / 2);

      for (var e in childs) {
        (e.parentData! as SketcherStackParentData).offset = tempOffset;

        final startPoint =
            Offset(childParentData.offset.dx + child.size.width, childParentData.offset.dy + child.size.height / 2);
        final endPoint = Offset(tempOffset.dx, tempOffset.dy + e.size.height / 2);
        paths.add(Path()
          ..moveTo(startPoint.dx, startPoint.dy)
          ..cubicTo((startPoint.dx + endPoint.dx) / 2, startPoint.dy, (startPoint.dx + endPoint.dx) / 2, endPoint.dy,
              endPoint.dx, endPoint.dy));

        tempOffset = tempOffset.translate(0, _padding + e.size.height);
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);

    context.canvas.translate(offset.dx, offset.dy);
    for (var element in paths) {
      context.canvas.drawPath(
        element,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  static Size layoutHepler(RenderHoverIndicatable child, BoxConstraints constraints) {
    child.layout(constraints.loosen(), parentUsesSize: true);
    return child.size;
  }
}

class SketcherStackParentData extends ContainerBoxParentData<RenderHoverIndicatable> {
  Topic? topic;

  List<RenderHoverIndicatable> childrenRender = [];
  List<RenderHoverIndicatable> fatherRender = [];

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
    bool needsLayout = false;

    if (parentData.topic != topic) {
      parentData.topic = topic;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SketcherContnetStack;
}
