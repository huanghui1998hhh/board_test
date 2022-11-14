import 'package:board_test/hover_indicatable.dart';
import 'package:board_test/mind_mapping.dart';
import 'package:board_test/sketcher_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TransformViewport extends SingleChildRenderObjectWidget {
  const TransformViewport({
    super.key,
    super.child,
    required this.mindMap,
    required this.controller,
  });

  final SketcherController controller;
  final MindMapping mindMap;

  @override
  RenderTransformViewport createRenderObject(BuildContext context) => RenderTransformViewport(
        controller: controller,
        mindMap: mindMap,
      );

  @override
  void updateRenderObject(BuildContext context, RenderTransformViewport renderObject) => renderObject
    ..controller = controller
    ..mindMap = mindMap;
}

class RenderTransformViewport extends RenderProxyBox {
  RenderTransformViewport({required SketcherController controller, required MindMapping mindMap})
      : _controller = controller,
        _mindMap = mindMap;

  MindMapping _mindMap;
  MindMapping get mindMap => _mindMap;
  set mindMap(MindMapping value) {
    if (value == _controller) {
      return;
    }
    _mindMap = value;
  }

  SketcherController _controller;
  SketcherController get controller => _controller;
  set controller(SketcherController value) {
    if (value == _controller) {
      return;
    }
    if (attached) {
      _controller.removeListener(markNeedsPaint);
    }
    _controller = value;
    if (attached) {
      _controller.addListener(markNeedsPaint);
    }

    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _controller.removeListener(markNeedsPaint);
    super.detach();
  }

  final List<RenderHoverIndicatable> topics = [];

  @override
  void performLayout() {
    _controller.viewportDimension = constraints.biggest;
    child!.layout(constraints);
    size = constraints.biggest;
  }

  Matrix4 get _effectiveTransform {
    final Matrix4 result = Matrix4.identity();
    Offset translation = Alignment.center.alongSize(size);
    result.translate(translation.dx, translation.dy);
    result.multiply(controller.matrix4);
    result.translate(-translation.dx, -translation.dy);
    return result;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_effectiveTransform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Matrix4 transform = _effectiveTransform;
    final Offset? childOffset = MatrixUtils.getAsTranslation(transform);
    if (childOffset == null) {
      final double det = transform.determinant();
      if (det == 0 || !det.isFinite) {
        layer = null;
        return;
      }
      layer = context.pushTransform(
        needsCompositing,
        offset,
        transform,
        super.paint,
        oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
      );
    } else {
      super.paint(context, offset + childOffset);
      layer = null;
    }
  }

  void childOnTapHandle(RenderHoverIndicatable? onTappedRender) {
    mindMap.selectedTopic = onTappedRender?.topic;

    for (var element in topics) {
      element.isSelected = element == onTappedRender;
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent) {
      childOnTapHandle(null);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool hitTarget = false;
    if (size.contains(position)) {
      hitTarget = !hitTestChildren(result, position: position);
      if (hitTarget) {
        result.add(BoxHitTestEntry(this, position));
      }
    }
    return hitTarget;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _effectiveTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }
}
