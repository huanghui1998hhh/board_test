import 'package:board_test/model/topic.dart';
import 'package:board_test/topic_setting_block/value_selector.dart';
import 'package:flutter/material.dart';

class TopicBlock extends StatefulWidget {
  final Topic topic;
  const TopicBlock({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  State<TopicBlock> createState() => _TopicBlockState();
}

class _TopicBlockState extends State<TopicBlock> {
  late final _text = TextEditingController(text: widget.topic.content);
  final _focusNode = FocusNode(skipTraversal: true);
  ValueNotifier<bool> ignorePointer = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(ignorePointerWithoutFocus);
  }

  void refresh() {
    setState(() {});
  }

  @override
  void didUpdateWidget(TopicBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget == widget) return;
    _text.text = widget.topic.content;
  }

  void ignorePointerWithoutFocus() {
    ignorePointer.value = !_focusNode.hasFocus;
  }

  @override
  void dispose() {
    _focusNode.removeListener(ignorePointerWithoutFocus);
    _focusNode.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _focusNode.requestFocus,
      child: ValueSelector(
        controller: widget.topic,
        valueBuilder: (_, controller) => controller.style.topicDecorationStyle,
        builder: (_, value, child) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              value.leftPadding.toDouble(),
              value.topPadding.toDouble(),
              value.rightPadding.toDouble(),
              value.bottomPadding.toDouble(),
            ),
            decoration: BoxDecoration(color: value.backgroundColor, borderRadius: BorderRadius.circular(5)),
            child: child,
          );
        },
        child: ValueListenableBuilder(
          valueListenable: ignorePointer,
          builder: (context, value, child) => IgnorePointer(
            ignoring: value,
            child: child,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: IntrinsicWidth(
              child: ValueSelector(
                controller: widget.topic,
                valueBuilder: (_, controller) => controller.style.topicTextStyle,
                builder: (_, value, __) {
                  return TextField(
                    textAlign: value.textAlignment,
                    focusNode: _focusNode,
                    style: TextStyle(
                      fontSize: value.textSize.value,
                      fontStyle: value.isItalic ? FontStyle.italic : FontStyle.normal,
                      fontWeight: value.isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    controller: _text,
                    onChanged: (value) => widget.topic.content = value,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
