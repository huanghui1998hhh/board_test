import 'dart:math';

import 'package:board_test/new_map_temp.dart';
import 'package:flutter/material.dart';

class Topic extends ChangeNotifier {
  Topic({
    this.content = '',
    List<Topic>? children,
    TopicStyle? style,
  })  : children = children ?? [],
        _style = style ?? const TopicStyle();

  String content;

  List<Topic> children = [];

  TopicLayout _layout = TopicLayout.straightTree;
  TopicLayout get layout => _layout;
  set layout(TopicLayout value) {
    if (_layout == value) return;

    _layout = value;
    notifyListeners();
  }

  TopicStyle _style;
  TopicStyle get style => _style;
  set style(TopicStyle value) {
    if (_style == value) return;

    _style = value;
    notifyListeners();
  }

  void addSubTopic() {
    children.add(Topic());
    notifyListeners();
  }

  @override
  void dispose() {
    for (var element in children) {
      element.dispose();
    }
    super.dispose();
  }
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
    final mainRect = paintChildrenUseTreeH(context, offset, mainTopicRender, firstChild);

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
  }

  static Rect paintChildrenUseTreeH(
      PaintingContext context, Offset offset, RenderBox mainTopicRender, RenderBox? firstChild) {
    final TempParentData childParentData = mainTopicRender.parentData! as TempParentData;
    context.paintChild(mainTopicRender, childParentData.offset + offset);

    RenderBox? child = firstChild;
    while (child != null) {
      final TempParentData childParentData = child.parentData! as TempParentData;
      context.paintChild(child, childParentData.offset + offset);

      child = childParentData.nextSibling;
    }

    return Rect.fromLTWH(
        childParentData.offset.dx, childParentData.offset.dy, mainTopicRender.size.width, mainTopicRender.size.height);
  }

  static void treePaint(PaintingContext context, Offset offset, RenderBox mainTopicRender, RenderBox? firstChild) {
    final mainRect = paintChildrenUseTreeH(context, offset, mainTopicRender, firstChild);

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
  }
}

class TopicStyle {
  const TopicStyle({
    this.backgroundColor = Colors.yellow,
    this.textSize = 16,
    this.topPadding = 10,
    this.bottomPadding = 10,
    this.leftPadding = 10,
    this.rightPadding = 10,
  });

  final Color backgroundColor;
  final double textSize;
  final double topPadding;
  final double bottomPadding;
  final double leftPadding;
  final double rightPadding;

  TopicStyle copyWith({
    Color? backgroundColor,
    double? textSize,
    double? topPadding,
    double? bottomPadding,
    double? leftPadding,
    double? rightPadding,
  }) =>
      TopicStyle(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        textSize: textSize ?? this.textSize,
        topPadding: topPadding ?? this.topPadding,
        bottomPadding: bottomPadding ?? this.bottomPadding,
        leftPadding: leftPadding ?? this.leftPadding,
        rightPadding: rightPadding ?? this.rightPadding,
      );
}
