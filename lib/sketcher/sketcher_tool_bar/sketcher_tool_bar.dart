import 'package:board_test/model/mind_mapping.dart';
import 'package:board_test/model/topic.dart';
import 'package:board_test/sketcher/sketcher_tool_bar/icon_toogle.dart';
import 'package:board_test/topic_setting_block/value_selector.dart';
import 'package:flutter/material.dart';

class SketcherToolBar extends StatefulWidget {
  final MindMapping mindMapping;
  const SketcherToolBar({
    Key? key,
    required this.mindMapping,
  }) : super(key: key);

  @override
  State<SketcherToolBar> createState() => _SketcherToolBarState();
}

class _SketcherToolBarState extends State<SketcherToolBar> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color.fromRGBO(41, 56, 69, 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        height: 42,
        child: ValueSelector(
          controller: widget.mindMapping,
          valueBuilder: (_, controller) => controller.selectedTopic,
          builder: (_, selectedTopic, __) {
            if (selectedTopic == null) return const SizedBox();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) =>
                      controller.style.topicTextStyle.textSize == TopicTextSize.values.first,
                  builder: (_, value, __) => IconToogle.icon(
                    disabled: value,
                    onPressed: selectedTopic.textSizeReduce,
                    icon: Icons.remove,
                  ),
                ),
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) => controller.style.topicTextStyle.textSize,
                  builder: (_, value, __) => IconToogle(
                    onPressed: () {},
                    child: Text(
                      value.string,
                      textScaleFactor: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) =>
                      controller.style.topicTextStyle.textSize == TopicTextSize.values.last,
                  builder: (_, value, __) => IconToogle.icon(
                    disabled: value,
                    onPressed: selectedTopic.textSizeIncrease,
                    icon: Icons.add,
                  ),
                ),
                VerticalDivider(
                  indent: 4,
                  endIndent: 4,
                  color: Colors.white.withOpacity(0.8),
                ),
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) => controller.style.topicTextStyle.isBold,
                  builder: (_, value, __) => IconToogle.icon(
                    isSelected: value,
                    onSelected: (e) => selectedTopic.isBold = e,
                    icon: Icons.format_bold,
                  ),
                ),
                VerticalDivider(
                  indent: 4,
                  endIndent: 4,
                  color: Colors.white.withOpacity(0.8),
                ),
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) => controller.style.topicTextStyle.isItalic,
                  builder: (_, value, __) => IconToogle.icon(
                    isSelected: value,
                    onSelected: (e) => selectedTopic.isItalic = e,
                    icon: Icons.format_italic,
                  ),
                ),
                VerticalDivider(
                  indent: 4,
                  endIndent: 4,
                  color: Colors.white.withOpacity(0.8),
                ),
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) => controller.style.topicTextStyle.textAlignment == TextAlign.left,
                  builder: (_, value, __) => IconToogle.icon(
                    isSelected: value,
                    onSelected: (e) {
                      if (e) selectedTopic.textAlignment = TextAlign.left;
                    },
                    icon: Icons.format_align_left,
                  ),
                ),
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) => controller.style.topicTextStyle.textAlignment == TextAlign.center,
                  builder: (_, value, __) => IconToogle.icon(
                    isSelected: value,
                    onSelected: (e) {
                      if (e) selectedTopic.textAlignment = TextAlign.center;
                    },
                    icon: Icons.format_align_center,
                  ),
                ),
                ValueSelector(
                  controller: selectedTopic,
                  valueBuilder: (_, controller) => controller.style.topicTextStyle.textAlignment == TextAlign.right,
                  builder: (_, value, __) => IconToogle.icon(
                    isSelected: value,
                    onSelected: (e) {
                      if (e) selectedTopic.textAlignment = TextAlign.right;
                    },
                    icon: Icons.format_align_right,
                  ),
                ),
                // VerticalDivider(
                //   indent: 4,
                //   endIndent: 4,
                //   color: Colors.white.withOpacity(0.8),
                // ),
                // IconToogle.icon(
                //   onPressed: () {
                //     widget.mindMapping.selectedTopic = null;
                //   },
                //   icon: Icons.close,
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
