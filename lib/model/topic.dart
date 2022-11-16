import 'dart:math';

import 'package:board_test/sketcher/sketcher_unit/mind_map_contianer.dart';
import 'package:flutter/material.dart';

class Topic extends ChangeNotifier {
  Topic({
    this.content = '',
    List<Topic>? children,
    this.father,
    TopicStyle? style,
  })  : children = children ?? [],
        _style = style ?? TopicStyle() {
    for (var element in this.children) {
      element.father = this;
    }
  }

  set isItalic(bool value) {
    if (value == style.topicTextStyle.isItalic) return;

    style.topicTextStyle = style.topicTextStyle.copyWith(isItalic: value);
    notifyListeners();
  }

  set isBold(bool value) {
    if (value == style.topicTextStyle.isBold) return;

    style.topicTextStyle = style.topicTextStyle.copyWith(isBold: value);
    notifyListeners();
  }

  set textAlignment(TextAlign value) {
    if (value == style.topicTextStyle.textAlignment) return;

    style.topicTextStyle = style.topicTextStyle.copyWith(textAlignment: value);
    notifyListeners();
  }

  String content;

  Topic? father;
  List<Topic> children = [];

  TopicLayout _layout = TopicLayout.straightTree;
  TopicLayout get layout => _layout;
  set layout(TopicLayout value) {
    if (_layout == value) return;

    _layout = value;
    notifyListeners();
  }

  final TopicStyle _style;
  TopicStyle get style => _style;

  void addSubTopic() {
    children = children.toList()..add(Topic()..father = this);
    notifyListeners();
  }

  @override
  void dispose() {
    for (var element in children) {
      element.dispose();
    }
    assert(father!.children.remove(this));
    father!.children = father!.children.toList();
    father!.notifyListeners();
    father = null;
    super.dispose();
  }
}

class TopicStyle {
  TopicDecorationStyle topicDecorationStyle = const TopicDecorationStyle();
  TopicTextStyle topicTextStyle = const TopicTextStyle();
}

class TopicTextStyle {
  const TopicTextStyle({
    this.textSize = 16,
    this.isBold = false,
    this.isItalic = false,
    this.textAlignment = TextAlign.center,
  });

  final double textSize;
  final bool isItalic;
  final bool isBold;
  final TextAlign textAlignment;

  TopicTextStyle copyWith({
    double? textSize,
    bool? isItalic,
    bool? isBold,
    TextAlign? textAlignment,
  }) =>
      TopicTextStyle(
        textSize: textSize ?? this.textSize,
        isItalic: isItalic ?? this.isItalic,
        isBold: isBold ?? this.isBold,
        textAlignment: textAlignment ?? this.textAlignment,
      );
}

class TopicDecorationStyle {
  const TopicDecorationStyle({
    this.backgroundColor = Colors.yellow,
    this.topPadding = 10,
    this.bottomPadding = 10,
    this.leftPadding = 10,
    this.rightPadding = 10,
  });

  final Color backgroundColor;
  final double topPadding;
  final double bottomPadding;
  final double leftPadding;
  final double rightPadding;

  TopicDecorationStyle copyWith({
    Color? backgroundColor,
    double? topPadding,
    double? bottomPadding,
    double? leftPadding,
    double? rightPadding,
  }) =>
      TopicDecorationStyle(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        topPadding: topPadding ?? this.topPadding,
        bottomPadding: bottomPadding ?? this.bottomPadding,
        leftPadding: leftPadding ?? this.leftPadding,
        rightPadding: rightPadding ?? this.rightPadding,
      );
}

typedef TopicPaintHandle = void Function(
    PaintingContext context, Offset offset, RenderBox mainTopicRender, RenderBox? firstChild);

enum TopicLayout {
  tree(treePaint),
  straightTree(straightTreePaint);

  final TopicPaintHandle topicPaintHandle;
  const TopicLayout(this.topicPaintHandle);

  static void straightTreePaint(
      PaintingContext context, Offset offset, RenderBox mainTopicRender, RenderBox? firstChild) {
    final mainRect = getMainRect(mainTopicRender);

    RenderBox? child = firstChild;
    if (child != null) {
      final centerX = mainRect.right + 25;
      final path = Path()
        ..moveTo(mainRect.right, mainRect.centerRight.dy)
        ..lineTo(centerX, mainRect.centerRight.dy);
      final points = <double>[];
      while (child != null) {
        final TempParentData childParentData = child.parentData! as TempParentData;
        final childMainRender = (child as RenderNewMapTempWidget).mainTopicRender!;
        final totalOffset = childParentData.offset + (childMainRender.parentData! as TempParentData).offset;
        points.add(totalOffset.dy + childMainRender.size.height / 2);
        child = childParentData.nextSibling;
      }
      if (points.length > 1) {
        path.moveTo(centerX, points.first);
        path.lineTo(centerX, points.last);
      }
      final rightX = mainRect.right + 50;
      for (var e in points) {
        path.moveTo(centerX, e);
        path.lineTo(rightX, e);
      }
      context.canvas.drawPath(
        path.shift(offset),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    paintChildrenUseTreeH(context, offset, mainTopicRender, firstChild);
  }

  static Rect getMainRect(RenderBox mainTopicRender) {
    final TempParentData childParentData = mainTopicRender.parentData! as TempParentData;
    return Rect.fromLTWH(
        childParentData.offset.dx, childParentData.offset.dy, mainTopicRender.size.width, mainTopicRender.size.height);
  }

  static void paintChildrenUseTreeH(
      PaintingContext context, Offset offset, RenderBox mainTopicRender, RenderBox? firstChild) {
    final TempParentData childParentData = mainTopicRender.parentData! as TempParentData;
    context.paintChild(mainTopicRender, childParentData.offset + offset);

    RenderBox? child = firstChild;
    while (child != null) {
      final TempParentData childParentData = child.parentData! as TempParentData;
      context.paintChild(child, childParentData.offset + offset);

      child = childParentData.nextSibling;
    }
  }

  static void treePaint(PaintingContext context, Offset offset, RenderBox mainTopicRender, RenderBox? firstChild) {
    final mainRect = getMainRect(mainTopicRender);

    RenderBox? child = firstChild;
    while (child != null) {
      final TempParentData childParentData = child.parentData! as TempParentData;

      final childMainRender = (child as RenderNewMapTempWidget).mainTopicRender!;
      final childrenRect = (childParentData.offset + offset + (childMainRender.parentData! as TempParentData).offset) &
          childMainRender.size;

      final startPoint = Point(mainRect.right, mainRect.center.dy);

      final endPoint = Point(childrenRect.left, childrenRect.center.dy);

      context.canvas.drawPath(
        (Path()
              ..moveTo(startPoint.x, startPoint.y)
              ..cubicTo((startPoint.x + endPoint.x) / 2, startPoint.y, (startPoint.x + endPoint.x) / 2, endPoint.y,
                  endPoint.x, endPoint.y))
            .shift(offset),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      child = childParentData.nextSibling;
    }

    paintChildrenUseTreeH(context, offset, mainTopicRender, firstChild);
  }
}
