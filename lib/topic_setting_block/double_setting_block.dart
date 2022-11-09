import 'package:board_test/topic_setting_block/base.dart';
import 'package:flutter/material.dart';

class DoubleSettingBlock extends TopicSettingBlock<double> {
  final void Function(double) onChange;
  const DoubleSettingBlock({super.key, required super.value, required this.onChange});

  @override
  State<StatefulWidget> createState() => _DoubleSettingBlockState();
}

class _DoubleSettingBlockState extends TopicSettingBlockState<double, DoubleSettingBlock> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: stateValue,
      min: 5,
      max: 96,
      onChanged: (value) {
        stateValue = value;
        widget.onChange(value);
      },
    );
  }
}
