import 'package:board_test/hover_indicatable.dart';
import 'package:board_test/mind_mapping.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TappableColoredBox extends SingleChildRenderObjectWidget {
  final MindMapping mindMap;
  const TappableColoredBox({required this.color, super.child, super.key, required this.mindMap});

  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTappableColoredBox(color: color, mindMap: mindMap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTappableColoredBox renderObject) => renderObject..color = color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Color>('color', color));
  }
}

class RenderTappableColoredBox extends RenderProxyBox {
  final MindMapping mindMap;
  RenderTappableColoredBox({required Color color, required this.mindMap}) : _color = color;

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  final List<RenderHoverIndicatable> topics = [];

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
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size > Size.zero) {
      context.canvas.drawRect(offset & size, Paint()..color = color);
    }
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
