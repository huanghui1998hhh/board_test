import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SketcherContnetStack extends MultiChildRenderObjectWidget {
  SketcherContnetStack({
    super.key,
    super.children,
  });

  @override
  RenderSketcherContnetStack createRenderObject(BuildContext context) => RenderSketcherContnetStack();
}

class RenderSketcherContnetStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StackParentData> {
  RenderSketcherContnetStack({
    List<RenderBox>? children,
  }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StackParentData) {
      child.parentData = StackParentData();
    }
  }

  static void layoutPositionedChild(RenderBox child, StackParentData childParentData, Size size) {
    assert(childParentData.isPositioned);
    assert(child.parentData == childParentData);

    BoxConstraints childConstraints = const BoxConstraints();

    if (childParentData.left != null && childParentData.right != null) {
      childConstraints = childConstraints.tighten(width: size.width - childParentData.right! - childParentData.left!);
    } else if (childParentData.width != null) {
      childConstraints = childConstraints.tighten(width: childParentData.width);
    }

    if (childParentData.top != null && childParentData.bottom != null) {
      childConstraints = childConstraints.tighten(height: size.height - childParentData.bottom! - childParentData.top!);
    } else if (childParentData.height != null) {
      childConstraints = childConstraints.tighten(height: childParentData.height);
    }

    child.layout(childConstraints, parentUsesSize: true);

    final double x;
    if (childParentData.left != null) {
      x = childParentData.left!;
    } else if (childParentData.right != null) {
      x = size.width - childParentData.right! - child.size.width;
    } else {
      x = (size - child.size as Offset).dx;
    }

    final double y;
    if (childParentData.top != null) {
      y = childParentData.top!;
    } else if (childParentData.bottom != null) {
      y = size.height - childParentData.bottom! - child.size.height;
    } else {
      y = (size - child.size as Offset).dy;
    }

    childParentData.offset = Offset(x, y);
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    RenderBox? child = firstChild;

    Offset? tempOffset;

    while (child != null) {
      final StackParentData childParentData = child.parentData! as StackParentData;

      child.layout(constraints.loosen(), parentUsesSize: true);
      childParentData.offset = tempOffset ??= (size / 2) - child.size as Offset;
      tempOffset = childParentData.offset.translate(0, child.size.height + 10);

      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
