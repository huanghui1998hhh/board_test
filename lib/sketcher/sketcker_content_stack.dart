import 'package:board_test/sketcher/sketcher_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SketckerStack extends MultiChildRenderObjectWidget {
  SketckerStack({
    super.key,
    super.children,
    required this.controller,
  });

  final SketcherController controller;

  @override
  RenderSketckerStack createRenderObject(BuildContext context) => RenderSketckerStack(controller: controller);

  @override
  void updateRenderObject(BuildContext context, RenderSketckerStack renderObject) =>
      renderObject..controller = controller;
}

class RenderSketckerStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SketckerStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SketckerStackParentData> {
  RenderSketckerStack({List<RenderBox>? children, required this.controller}) {
    addAll(children);
  }

  SketcherController controller;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SketckerStackParentData) {
      child.parentData = SketckerStackParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    size = constraints.biggest;

    RenderBox? child = firstChild;
    while (child != null) {
      final SketckerStackParentData childParentData = child.parentData! as SketckerStackParentData;

      child.layout(const BoxConstraints(), parentUsesSize: true);
      childParentData.offset = Offset(size.width - child.size.width, size.height - child.size.height) / 2;

      assert(child.parentData == childParentData);

      child = childParentData.nextSibling;
    }

    controller.sketcherSize = firstChild!.size + const Offset(500, 500);
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

class SketckerStackParentData extends ContainerBoxParentData<RenderBox> {}
