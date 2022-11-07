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
