import 'package:board_test/sketcher_controller.dart';
import 'package:board_test/topic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  Widget? cache;
  TopicStyle? oldStyle;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(ignorePointerWithoutFocus);
    widget.topic.addListener(refresh);
  }

  void refresh() {
    setState(() {});
  }

  @override
  void didUpdateWidget(TopicBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget == widget) return;

    _text.text = widget.topic.content;
    oldWidget.topic.removeListener(refresh);
    widget.topic.addListener(refresh);
  }

  void ignorePointerWithoutFocus() {
    ignorePointer.value = !_focusNode.hasFocus;
  }

  @override
  void dispose() {
    _focusNode.removeListener(ignorePointerWithoutFocus);
    widget.topic.removeListener(refresh);
    _focusNode.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (oldStyle != widget.topic.style) {
      oldStyle = widget.topic.style;
      cache = GestureDetector(
        onDoubleTap: () {
          _focusNode.requestFocus();
        },
        onPanUpdate: (details) => context.read<SketcherController>().boardDragHandle(details.delta),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            oldStyle!.leftPadding,
            oldStyle!.topPadding,
            oldStyle!.rightPadding,
            oldStyle!.bottomPadding,
          ),
          decoration: BoxDecoration(color: oldStyle!.backgroundColor, borderRadius: BorderRadius.circular(5)),
          child: ValueListenableBuilder(
            valueListenable: ignorePointer,
            builder: (context, value, child) => IgnorePointer(
              ignoring: value,
              child: child,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: IntrinsicWidth(
                child: TextField(
                  textAlign: TextAlign.center,
                  focusNode: _focusNode,
                  style: TextStyle(fontSize: oldStyle!.textSize),
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  controller: _text,
                  onChanged: (value) => widget.topic.content = value,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return cache!;
  }
}
