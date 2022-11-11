import 'dart:math';

import 'package:board_test/hover_indicatable.dart';
import 'package:board_test/topic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MindMap extends StatefulWidget {
  final Topic topic;
  const MindMap({Key? key, required this.topic}) : super(key: key);

  @override
  State<MindMap> createState() => MindMapState();
}

class MindMapState extends State<MindMap> {
  Topic? oldTopic;
  List<Topic>? oldValue;
  TopicLayout? oldLayout;
  HoverIndicatable? oldTempWidget;

  @override
  void initState() {
    super.initState();
    widget.topic.addListener(refresh);
  }

  @override
  void dispose() {
    widget.topic.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void didUpdateWidget(MindMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic == widget.topic) return;
    oldWidget.topic.removeListener(refresh);
    oldTempWidget = null;
    oldTopic = null;
    oldValue = null;
    oldLayout = null;
    widget.topic.addListener(refresh);
  }

  @override
  Widget build(BuildContext context) {
    if (oldTopic != widget.topic) {
      oldTopic = widget.topic;
      oldTempWidget = HoverIndicatable(topic: widget.topic);
      oldValue = widget.topic.children;
      oldLayout = widget.topic.layout;
    } else {
      if (oldValue != widget.topic.children) {
        oldValue = widget.topic.children;
      }
      if (oldLayout != widget.topic.layout) {
        oldLayout = widget.topic.layout;
      }
    }

    return NewMapTempWidget(
      mainChild: oldTempWidget!,
      topicLayout: oldLayout!,
      children: oldValue!.map((e) => MindMap(topic: e)).toList(),
    );
  }
}

class NewMapTempWidget extends MultiChildRenderObjectWidget {
  NewMapTempWidget({
    super.key,
    required this.mainChild,
    required this.topicLayout,
    required this.children,
  });

  final HoverIndicatable mainChild;

  final TopicLayout topicLayout;

  @override
  // ignore: overridden_fields
  final List<MindMap> children;

  @override
  MultiChildRenderObjectElement createElement() => NewMapTempWidgetElement(this);

  @override
  RenderNewMapTempWidget createRenderObject(BuildContext context) => RenderNewMapTempWidget(
        topicLayout: topicLayout,
      );

  @override
  void updateRenderObject(BuildContext context, RenderNewMapTempWidget renderObject) =>
      renderObject..topicLayout = topicLayout;
}

class NewMapTempWidgetElement extends MultiChildRenderObjectElement {
  NewMapTempWidgetElement(super.widget);

  @override
  NewMapTempWidget get widget => super.widget as NewMapTempWidget;

  Element? _mainTopicElement;

  @override
  void insertRenderObjectChild(RenderBox child, IndexedSlot<Element?> slot) {
    if (slot.index < 0) {
      final RenderNewMapTempWidget renderObject = this.renderObject as RenderNewMapTempWidget;
      renderObject.mainTopicRender = child;
    } else {
      super.insertRenderObjectChild(child, slot);
    }
  }

  @override
  void removeRenderObjectChild(RenderObject child, IndexedSlot<Element?> slot) {
    final RenderNewMapTempWidget renderObject = this.renderObject as RenderNewMapTempWidget;
    if (slot.index < 0) {
      assert(renderObject.mainTopicRender == child);
      renderObject.mainTopicRender = null;
    } else {
      super.removeRenderObjectChild(child, slot);
    }
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    super.visitChildren(visitor);
    if (_mainTopicElement != null) {
      visitor(_mainTopicElement!);
    }
  }

  @override
  void update(NewMapTempWidget newWidget) {
    super.update(newWidget);
    _mainTopicElement = updateChild(_mainTopicElement, widget.mainChild, const IndexedSlot<Element?>(-1, null));
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _mainTopicElement = updateChild(_mainTopicElement, widget.mainChild, const IndexedSlot<Element?>(-1, null));
  }
}

class RenderNewMapTempWidget extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TempParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TempParentData> {
  RenderNewMapTempWidget({required TopicLayout topicLayout}) : _topicLayout = topicLayout;

  RenderBox? _mainTopicRender;
  RenderBox? get mainTopicRender => _mainTopicRender;

  TopicLayout _topicLayout;
  TopicLayout get topicLayout => _topicLayout;
  set topicLayout(TopicLayout value) {
    _topicLayout = value;
    markNeedsLayout();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TempParentData) {
      child.parentData = TempParentData();
    }
  }

  set mainTopicRender(RenderBox? value) {
    if (_mainTopicRender != null) {
      dropChild(_mainTopicRender!);
    }
    _mainTopicRender = value;
    if (_mainTopicRender != null) {
      adoptChild(_mainTopicRender!);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_mainTopicRender != null) {
      _mainTopicRender!.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    if (_mainTopicRender != null) {
      _mainTopicRender!.detach();
    }
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    if (_mainTopicRender != null) {
      redepthChild(_mainTopicRender!);
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    if (_mainTopicRender != null) {
      visitor(_mainTopicRender!);
    }
  }

  @override
  void performLayout() {
    _mainTopicRender!.layout(constraints.loosen(), parentUsesSize: true);

    RenderBox? child = firstChild;
    Offset tempOffset = Offset(_mainTopicRender!.size.width + 50, 0);

    double widthTemp = 0;

    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final parent = child.parentData! as TempParentData;
      parent.offset = tempOffset;

      widthTemp = max(widthTemp, child.size.width);
      tempOffset = tempOffset.translate(0, child.size.height + 20);
      child = parent.nextSibling;
    }

    final childrenHeight = max(tempOffset.dy - 20, _mainTopicRender!.size.height);

    (_mainTopicRender!.parentData! as TempParentData).offset =
        Offset(0, (childrenHeight - _mainTopicRender!.size.height) / 2);

    size = Size(_mainTopicRender!.size.width + 50 + widthTemp, childrenHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      topicLayout.topicPaintHandle(context, offset, mainTopicRender!, firstChild);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final TempParentData childParentData = mainTopicRender!.parentData! as TempParentData;
    final bool isHit = result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return mainTopicRender!.hitTest(result, position: transformed);
      },
    );
    if (isHit) {
      return true;
    }

    return defaultHitTestChildren(result, position: position);
  }
}

class TempParentData extends ContainerBoxParentData<RenderBox> {
  Rect? mainTopicRect;
}
