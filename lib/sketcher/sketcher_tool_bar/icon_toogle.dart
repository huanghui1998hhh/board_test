import 'package:flutter/material.dart';

class IconToogle extends StatelessWidget {
  final bool? isSelected;
  final bool disabled;
  final void Function(bool value)? onSelected;
  final void Function()? onPressed;
  final ButtonStyle? buttonStyle;
  final Widget child;

  const IconToogle({
    super.key,
    this.buttonStyle,
    this.isSelected,
    this.onSelected,
    this.onPressed,
    this.disabled = false,
    required this.child,
  }) : assert(
          (isSelected == null && onPressed != null && onSelected == null) ||
              (isSelected != null && onPressed == null && onSelected != null),
        );

  factory IconToogle.icon({
    Key? key,
    bool? isSelected,
    void Function(bool value)? onSelected,
    void Function()? onPressed,
    ButtonStyle? buttonStyle,
    required IconData icon,
    bool disabled = false,
    double? size,
  }) =>
      IconToogle(
        key: key,
        isSelected: isSelected,
        onPressed: onPressed,
        onSelected: onSelected,
        disabled: disabled,
        child: Icon(icon, size: size),
      );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: buttonStyle ?? _iconToogleStyle,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: disabled
          ? null
          : () {
              if (isSelected == null) {
                onPressed!();
              } else {
                onSelected!(!isSelected!);
              }
            },
      icon: child,
      isSelected: isSelected,
    );
  }

  static final _iconToogleStyle = ButtonStyle(
    overlayColor: MaterialStateProperty.all(Colors.transparent),
    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.white.withOpacity(0.4);
        }
        return Colors.white;
      },
    ),
    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return const Color.fromRGBO(156, 66, 228, 1);
        } else if (states.contains(MaterialState.hovered)) {
          return Colors.black.withOpacity(0.4);
        }
        return Colors.white.withOpacity(0.4);
      },
    ),
    splashFactory: NoSplash.splashFactory,
    fixedSize: MaterialStateProperty.all(const Size(30, 30)),
    padding: MaterialStateProperty.all(EdgeInsets.zero),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}
