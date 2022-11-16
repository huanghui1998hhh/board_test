import 'package:flutter/material.dart';

class IconToogle extends StatelessWidget {
  final bool value;
  final void Function(bool value) onSelected;
  final ButtonStyle? buttonStyle;
  final IconData icon;
  final double? size;

  const IconToogle({
    Key? key,
    this.buttonStyle,
    this.size,
    required this.icon,
    required this.value,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: buttonStyle,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: () {
        onSelected(!value);
      },
      icon: Icon(icon, size: size),
      isSelected: value,
    );
  }
}
