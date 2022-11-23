import 'package:board_test/model/mind_mapping.dart';
import 'package:board_test/model/topic.dart';
import 'package:board_test/sketcher/sketcher_unit/topic_block.dart';
import 'package:board_test/sketcher/transform_viewport.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HoverIndicatable extends SingleChildRenderObjectWidget {
  HoverIndicatable({
    super.key,
    this.cursor = MouseCursor.defer,
    this.hitTestBehavior,
    this.onTap,
    required this.topic,
  }) : super(child: TopicBlock(topic: topic));

  final MouseCursor cursor;
  final HitTestBehavior? hitTestBehavior;
  final void Function(bool)? onTap;
  final Topic topic;

  @override
  RenderHoverIndicatable createRenderObject(BuildContext context) => RenderHoverIndicatable(
        cursor: cursor,
        hitTestBehavior: hitTestBehavior,
        onTap: onTap,
        topic: topic,
        link: context.read<MindMapping>().layerLink,
      );

  @override
  SingleChildRenderObjectElement createElement() => AddTopicToControlElement(this);

  @override
  void updateRenderObject(BuildContext context, RenderHoverIndicatable renderObject) {
    renderObject
      ..topic = topic
      ..cursor = cursor
      ..onTap = onTap
      ..behavior = hitTestBehavior;
  }
}

class AddTopicToControlElement extends SingleChildRenderObjectElement {
  AddTopicToControlElement(super.widget);

  RenderTransformViewport? _controlRender;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    var temp = renderObject.parent;
    while (temp is! RenderTransformViewport) {
      temp = temp?.parent;
    }
    _controlRender = temp;
    _controlRender!.topics.add(renderObject as RenderHoverIndicatable);
  }

  @override
  void unmount() {
    _controlRender!.topics.remove(renderObject);
    _controlRender = null;

    super.unmount();
  }
}

class RenderHoverIndicatable extends RenderProxyBox implements MouseTrackerAnnotation {
  RenderHoverIndicatable({
    MouseCursor cursor = MouseCursor.defer,
    bool validForMouseTracker = true,
    required LayerLink link,
    this.onTap,
    required Topic topic,
    HitTestBehavior? hitTestBehavior = HitTestBehavior.opaque,
  })  : _topic = topic,
        _link = link,
        _cursor = cursor,
        _validForMouseTracker = validForMouseTracker;

  Size? _previousLayoutSize;

  LayerLink get link => _link;
  LayerLink _link;
  set link(LayerLink value) {
    if (_link == value) {
      return;
    }
    _link.leaderSize = null;
    _link = value;
    if (_previousLayoutSize != null) {
      _link.leaderSize = _previousLayoutSize;
    }
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => _isSelected;

  Topic _topic;
  Topic get topic => _topic;
  set topic(Topic value) {
    if (_topic == value) {
      return;
    }
    _isSelected = false;
    _isHoverd = false;
    _topic = value;
  }

  bool _isHoverd = false;
  bool get isHoverd => _isHoverd;
  set isHoverd(bool value) {
    _isHoverd = value;
    markNeedsPaint();
  }

  void Function(bool)? onTap;

  bool _isSelected = false;
  bool get isSelected => _isSelected;
  set isSelected(bool value) {
    if (_isSelected == value) {
      return;
    }

    _isSelected = value;
    markNeedsLayout();
  }

  bool _isMultiSelected = false;
  bool get isMultiSelected => _isMultiSelected;
  set isMultiSelected(bool value) {
    if (_isMultiSelected == value) {
      return;
    }

    _isMultiSelected = value;
    markNeedsPaint();
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
  void performLayout() {
    super.performLayout();
    if (_isSelected) {
      _previousLayoutSize = size;
      link.leaderSize = size;
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent && !isSelected) {
      var temp = parent;

      while (temp is! RenderTransformViewport) {
        temp = temp?.parent;
      }

      temp.childOnTapHandle(this);
    }
  }

  HitTestBehavior _behavior = HitTestBehavior.translucent;
  HitTestBehavior? get behavior => _behavior;
  set behavior(HitTestBehavior? value) {
    final HitTestBehavior newValue = value ?? HitTestBehavior.opaque;
    if (_behavior != newValue) {
      _behavior = newValue;
      markNeedsPaint();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool hitTarget = false;
    if (size.contains(position)) {
      hitTarget = hitTestChildren(result, position: position) || hitTestSelf(position);
      if (hitTarget || behavior == HitTestBehavior.translucent) {
        result.add(BoxHitTestEntry(this, position));
      }
    }
    return hitTarget;
  }

  @override
  bool hitTestSelf(Offset position) => behavior == HitTestBehavior.opaque;

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

  double padding = 5;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_isSelected) {
      if (layer == null) {
        layer = LeaderLayer(link: link, offset: offset);
      } else {
        final LeaderLayer leaderLayer = layer! as LeaderLayer;
        leaderLayer
          ..link = link
          ..offset = offset;
      }
      context.pushLayer(layer!, paintChild, Offset.zero);
      assert(() {
        layer!.debugCreator = debugCreator;
        return true;
      }());
    } else {
      paintChild(context, offset);
    }
  }

  void paintChild(PaintingContext context, Offset offset) {
    if (size > Size.zero) {
      Color? color;
      if (isSelected || _isMultiSelected) {
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
