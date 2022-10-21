import 'package:board_test/topic.dart';
import 'package:flutter/material.dart';

class SketcherTopic extends StatefulWidget {
  final Topic topic;

  const SketcherTopic({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  State<SketcherTopic> createState() => _SketcherTopicState();
}

class _SketcherTopicState extends State<SketcherTopic> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.topic.content),
    );
  }
}
