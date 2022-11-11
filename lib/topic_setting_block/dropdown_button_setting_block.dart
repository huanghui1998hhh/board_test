import 'package:board_test/topic_setting_block/base.dart';
import 'package:flutter/material.dart';

class DropdownButtonSettingBlock<T extends Enum> extends TopicSettingBlock<T> {
  final void Function(T) onChange;
  final List<T> values;
  const DropdownButtonSettingBlock({
    super.key,
    required super.value,
    required this.onChange,
    required this.values,
  });

  @override
  State<StatefulWidget> createState() => _DropdownButtonSettingBlockState<T>();
}

class _DropdownButtonSettingBlockState<T extends Enum>
    extends TopicSettingBlockState<T, DropdownButtonSettingBlock<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: stateValue,
      onChanged: (T? value) {
        if (value == null) return;
        stateValue = value;
        widget.onChange(value);
      },
      items: widget.values.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
