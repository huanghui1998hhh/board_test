import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SketcherController extends ChangeNotifier {
  int _computableScale = 100;
  int get computableScale => _computableScale;
  set computableScale(int value) {
    _computableScale = value;
    _matrix4[0] = scale;
    _matrix4[5] = scale;
  }

  double get scale => computableScale / 100;

  Size _sketcherSize = Size.zero;
  Size get sketcherSize => _sketcherSize;
  set sketcherSize(Size value) {
    if (_sketcherSize == value) {
      return;
    }

    _sketcherSize = value;
    notifyListeners();
  }

  final Matrix4 _matrix4 = Matrix4.identity();
  Matrix4 get matrix4 => _matrix4;

  double get offsetX => _matrix4[12];
  double get offsetY => _matrix4[13];

  set offsetX(double value) {
    final lowerBoundX = (sketcherSizeWithScale.width - viewportDimension.width) / 2;
    _matrix4[12] = value == 0 ? value : clampDouble(value, -lowerBoundX, lowerBoundX);
  }

  set offsetY(double value) {
    final lowerBoundY = (sketcherSizeWithScale.height - viewportDimension.height) / 2;
    _matrix4[13] = value == 0 ? value : clampDouble(value, -lowerBoundY, lowerBoundY);
  }

  set offsetTranslateX(double value) {
    final lowerBoundX = (sketcherSizeWithScale.width - viewportDimension.width) / 2;
    _matrix4[12] = clampDouble(offsetX + value, -lowerBoundX, lowerBoundX);
  }

  set offsetTranslateY(double value) {
    final lowerBoundY = (sketcherSizeWithScale.height - viewportDimension.height) / 2;
    _matrix4[13] = clampDouble(offsetY + value, -lowerBoundY, lowerBoundY);
  }

  String get indicatorString => '$computableScale%';
  Size get sketcherSizeWithScale => _sketcherSize * scale;

  Size? _lastViewportDimension;
  Size get viewportDimension => _lastViewportDimension!;
  set viewportDimension(Size value) {
    if (_lastViewportDimension == value) {
      return;
    }

    _lastViewportDimension = value;

    if (value.width > sketcherSizeWithScale.width) {
      offsetX = 0;
    } else {
      offsetX = offsetX;
    }

    if (value.height > sketcherSizeWithScale.height) {
      offsetY = 0;
    } else {
      offsetY = offsetY;
    }
  }

  void zoomIn({int step = 20}) {
    if (computableScale < 300) {
      final temp = 1 / computableScale * (computableScale += step);
      offsetX *= temp;
      offsetY *= temp;
      notifyListeners();
    }
  }

  void zoomOut({int step = 20}) {
    if (computableScale > 20) {
      final temp = 1 / computableScale * (computableScale -= 20);
      if (viewportDimension.width > sketcherSizeWithScale.width) {
        offsetX = 0;
      } else {
        offsetX *= temp;
      }
      if (viewportDimension.height > sketcherSizeWithScale.height) {
        offsetY = 0;
      } else {
        offsetY *= temp;
      }
      notifyListeners();
    }
  }

  void mouseRollerHandle(Offset scrollDelta) {
    final temp = RawKeyboard.instance.keysPressed.lastWhereOrNull((e) =>
        e == LogicalKeyboardKey.controlLeft ||
        e == LogicalKeyboardKey.shiftLeft ||
        e == LogicalKeyboardKey.controlRight ||
        e == LogicalKeyboardKey.shiftRight);

    if (temp == null) {
      if (sketcherSizeWithScale.height > viewportDimension.height) {
        offsetTranslateY = scrollDelta.dy;
        notifyListeners();
      }
    } else if (temp == LogicalKeyboardKey.shiftLeft || temp == LogicalKeyboardKey.shiftRight) {
      if (sketcherSizeWithScale.width > viewportDimension.width) {
        offsetTranslateX = scrollDelta.dy;
        notifyListeners();
      }
    } else {
      if (scrollDelta.dy > 0) {
        zoomIn();
      } else {
        zoomOut();
      }
    }
  }

  void boardDragHandle(Offset dragDelta) {
    offsetTranslateX = dragDelta.dx;
    offsetTranslateY = dragDelta.dy;
    notifyListeners();
  }
}
