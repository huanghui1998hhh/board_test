import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class HoverIndicatable extends SingleChildRenderObjectWidget {
  const HoverIndicatable({
    super.key,
    this.cursor = MouseCursor.defer,
    this.opaque = true,
    this.isSelected = false,
    this.hitTestBehavior,
    this.onTap,
    super.child,
  });

  final MouseCursor cursor;
  final bool opaque;
  final HitTestBehavior? hitTestBehavior;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  RenderHoverIndicatable createRenderObject(BuildContext context) => RenderHoverIndicatable(
        cursor: cursor,
        opaque: opaque,
        hitTestBehavior: hitTestBehavior,
        onTap: onTap,
        isSelected: isSelected,
      );

  @override
  void updateRenderObject(BuildContext context, RenderHoverIndicatable renderObject) {
    renderObject
      ..cursor = cursor
      ..opaque = opaque
      ..isSelected = isSelected
      ..onTap = onTap
      ..hitTestBehavior = hitTestBehavior;
  }
}

class RenderHoverIndicatable extends RenderProxyBoxWithHitTestBehavior implements MouseTrackerAnnotation {
  RenderHoverIndicatable({
    MouseCursor cursor = MouseCursor.defer,
    bool validForMouseTracker = true,
    bool opaque = true,
    bool isSelected = false,
    this.onTap,
    HitTestBehavior? hitTestBehavior = HitTestBehavior.opaque,
  })  : _cursor = cursor,
        _validForMouseTracker = validForMouseTracker,
        _opaque = opaque,
        _isSelected = isSelected,
        super(behavior: hitTestBehavior ?? HitTestBehavior.opaque);

  bool _isHoverd = false;
  bool get isHoverd => _isHoverd;
  set isHoverd(bool value) {
    _isHoverd = value;
    markNeedsPaint();
  }

  VoidCallback? onTap;

  bool _isSelected;
  bool get isSelected => _isSelected;
  set isSelected(bool value) {
    if (_isSelected == value) {
      return;
    }

    _isSelected = value;
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

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (onTap == null) return;

    if (event is PointerDownEvent) {
      onTap!();
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

  double padding = 5;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size > Size.zero) {
      Color? color;
      if (isSelected) {
        color = const Color(0xFFFFB6C1);
      } else if (isHoverd) {
        color = const Color(0xFFFFB6C1).withOpacity(0.4);
      }
      if (color != null) {
        context.canvas.drawRRect(
          RRect.fromRectAndRadius((offset - Offset(padding, padding)) & (size + Offset(padding * 2, padding * 2)),
              const Radius.circular(10)),
          Paint()
            ..color = color
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }
    }

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
