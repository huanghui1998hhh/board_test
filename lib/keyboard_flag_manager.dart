import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardFlagManager {
  static final KeyboardFlagManager instance = KeyboardFlagManager._();
  KeyboardFlagManager._();

  bool get shiftPressed => false;

  final LinkedHashSet<LogicalKeyboardKey> _flagTemp = LinkedHashSet<LogicalKeyboardKey>();

  KeyEventResult keyEventHandle(RawKeyEvent event) {
    if (event is RawKeyDownEvent && !event.repeat) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        _flagTemp.add(event.logicalKey);
      }
    }

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        _flagTemp.remove(event.logicalKey);
      }
    }
    return KeyEventResult.ignored;
  }
}
