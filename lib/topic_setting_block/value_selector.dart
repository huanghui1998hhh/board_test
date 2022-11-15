import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

class ValueSelector<T extends ChangeNotifier, S> extends SingleChildStatefulWidget {
  final T controller;
  final S Function(BuildContext context, T controller) valueBuilder;
  final Widget Function(BuildContext context, S value, Widget? child) builder;
  const ValueSelector({
    super.key,
    super.child,
    required this.controller,
    required this.valueBuilder,
    required this.builder,
  });

  @override
  State<ValueSelector> createState() => _ValueSelectorState<T, S>();
}

class _ValueSelectorState<T extends ChangeNotifier, S> extends SingleChildState<ValueSelector<T, S>> {
  S? value;
  Widget? cache;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(refresh);
    super.dispose();
  }

  @override
  void didUpdateWidget(ValueSelector<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(refresh);
      widget.controller.addListener(refresh);
    }
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final temp = widget.valueBuilder(context, widget.controller);
    if (temp != value) {
      value = temp;
      cache = widget.builder(
        context,
        temp,
        child,
      );
    }
    return cache!;
  }
}
