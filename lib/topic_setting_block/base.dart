import 'package:flutter/widgets.dart';

abstract class TopicSettingBlock<T> extends StatefulWidget {
  final T value;
  const TopicSettingBlock({super.key, required this.value});
}

abstract class TopicSettingBlockState<T, Block extends TopicSettingBlock<T>> extends State<Block> {
  late T _stateValue;
  T get stateValue => _stateValue;
  set stateValue(T value) {
    if (_stateValue == value) return;
    setState(() {
      _stateValue = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _stateValue = widget.value;
  }

  @override
  void didUpdateWidget(Block oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget == widget) return;
    _stateValue = widget.value;
  }
}
