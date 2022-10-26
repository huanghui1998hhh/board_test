import 'package:board_test/hover_indicatable.dart';
import 'package:board_test/mind_mapping.dart';
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
        onPanUpdate: (details) => context.read<SketcherController>().boardDragHandle(details.delta, context),
        child: HoverIndicatable(
          isSelected: isSelected,
          onTap: () {
            context.read<MindMapping>().selectedTopic = widget.topic;
          },
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(5)),
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
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                controller: _text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
