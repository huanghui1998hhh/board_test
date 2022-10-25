import 'package:board_test/aspect_ratio_constraint_box.dart';
import 'package:board_test/hover_indicatable.dart';
import 'package:board_test/mind_mapping.dart';
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
  final _focusNode = FocusNode();
  ValueNotifier<bool> ignorePointer = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(ignorePointerWithoutFocus);
  }

  @override
  void didUpdateWidget(covariant TopicBlock oldWidget) {
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
    return Selector<MindMapping, bool>(
      selector: (context, mindMapping) => mindMapping.selectedTopic == widget.topic,
      builder: (context, isSelected, child) => GestureDetector(
        onDoubleTap: () {
          _focusNode.requestFocus();
        },
        child: HoverIndicatable(
          isSelected: isSelected,
          onTap: () {
            context.read<MindMapping>().selectedTopic = widget.topic;
          },
          child: child,
        ),
      ),
      child: AspectRatioConstraintBox(
        idealRatio: 4,
        threshold: 2,
        child: ValueListenableBuilder(
          valueListenable: ignorePointer,
          builder: (context, value, child) => IgnorePointer(
            ignoring: value,
            child: child,
          ),
          child: TextField(
            focusNode: _focusNode,
            style: const TextStyle(fontSize: 32),
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ),
            controller: _text,
          ),
        ),
      ),
    );
  }
}
