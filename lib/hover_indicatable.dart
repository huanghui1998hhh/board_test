import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class HoverIndicatable extends SingleChildRenderObjectWidget {
  const HoverIndicatable({
    super.key,
    this.cursor = MouseCursor.defer,
    this.opaque = true,
    this.hitTestBehavior,
    super.child,
  });

  final MouseCursor cursor;
  final bool opaque;
  final HitTestBehavior? hitTestBehavior;

  @override
  RenderHoverIndicatable createRenderObject(BuildContext context) => RenderHoverIndicatable(
        cursor: cursor,
        opaque: opaque,
        hitTestBehavior: hitTestBehavior,
      );

  @override
  void updateRenderObject(BuildContext context, RenderHoverIndicatable renderObject) {
    renderObject
      ..cursor = cursor
      ..opaque = opaque
      ..hitTestBehavior = hitTestBehavior;
  }
}

class RenderHoverIndicatable extends RenderProxyBoxWithHitTestBehavior implements MouseTrackerAnnotation {
  RenderHoverIndicatable({
    MouseCursor cursor = MouseCursor.defer,
    bool validForMouseTracker = true,
    bool opaque = true,
    HitTestBehavior? hitTestBehavior = HitTestBehavior.opaque,
  })  : _cursor = cursor,
        _validForMouseTracker = validForMouseTracker,
        _opaque = opaque,
        super(behavior: hitTestBehavior ?? HitTestBehavior.opaque);

  bool _isHoverd = false;
  bool get isHoverd => _isHoverd;
  set isHoverd(bool value) {
    _isHoverd = value;
    markNeedsPaint();
  }

  bool get opaque => _opaque;
  bool _opaque;
  set opaque(bool value) {
    if (_opaque != value) {
      _opaque = value;
      markNeedsPaint();
    }
  }

  @override
  MouseCursor get cursor => _cursor;
  MouseCursor _cursor;
  set cursor(MouseCursor value) {
    if (_cursor != value) {
      _cursor = value;
      markNeedsPaint();
    }
  }

  HitTestBehavior? get hitTestBehavior => behavior;
  set hitTestBehavior(HitTestBehavior? value) {
    final HitTestBehavior newValue = value ?? HitTestBehavior.opaque;
    if (behavior != newValue) {
      behavior = newValue;
      markNeedsPaint();
    }
  }

  @override
  late PointerEnterEventListener? onEnter = (_) => isHoverd = true;

  @override
  late PointerExitEventListener? onExit = (_) => isHoverd = false;

  @override
  bool get validForMouseTracker => _validForMouseTracker;
  bool _validForMouseTracker;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _validForMouseTracker = true;
  }

  @override
  void detach() {
    _validForMouseTracker = false;
    super.detach();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return super.hitTest(result, position: position) && _opaque;
  }

  double padding = 10;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    if (!child!.hasSize) return;

    if (isHoverd) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
            (offset - Offset(padding, padding)) & (size + Offset(padding * 2, padding * 2)), const Radius.circular(10)),
        Paint()
          ..color = const Color(0xFFFFB6C1)
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke,
      );
    }

    context.paintChild(child!, offset);
  }
}
