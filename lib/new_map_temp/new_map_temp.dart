import 'dart:math';

import 'package:board_test/topic.dart';
import 'package:board_test/topic_block.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class NewMapTempWidget extends MultiChildRenderObjectWidget {
  NewMapTempWidget.topic(Topic topic, {super.key})
      : mainChild = TopicBlock(topic: topic),
        children = topic.children.map((e) => NewMapTempWidget.topic(e)).toList();

  final TopicBlock mainChild;

  @override
  // ignore: overridden_fields
  final List<NewMapTempWidget> children;

  @override
  MultiChildRenderObjectElement createElement() => NewMapTempWidgetElement(this);

  @override
  RenderNewMapTempWidget createRenderObject(BuildContext context) => RenderNewMapTempWidget();
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
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _mainTopicElement = updateChild(_mainTopicElement, widget.mainChild, const IndexedSlot<Element?>(-1, null));
  }
}

class RenderNewMapTempWidget extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TempParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TempParentData> {
  RenderBox? _mainTopicRender;
  RenderBox? get mainTopicRender => _mainTopicRender;

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
  void paint(PaintingContext context, Offset offset) {
    final TempParentData childParentData = mainTopicRender!.parentData! as TempParentData;
    context.paintChild(mainTopicRender!, childParentData.offset + offset);

    defaultPaint(context, offset);
  }

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

class TempParentData extends ContainerBoxParentData<RenderBox> {}
