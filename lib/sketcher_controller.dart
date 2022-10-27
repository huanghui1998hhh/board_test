import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SketcherController extends ChangeNotifier {
  int _scale = 100;

  // ignore: prefer_const_constructors
  Size _sketcherSize = Size(2000, 1000);
  Size get sketcherSize => _sketcherSize;
  set sketcherSize(Size value) {
    if (_sketcherSize == value) {
      return;
    }

    _sketcherSize = value;
    notifyListeners();
  }

  double get scale => _scale / 100;
  String get indicatorString => '$_scale%';
  double get lowerBoundX => (sketcherSizeWithScale.width - viewportDimension.width) / 2;
  double get lowerBoundY => (sketcherSizeWithScale.height - viewportDimension.height) / 2;
  Size get sketcherSizeWithScale => _sketcherSize * scale;

  Size? _lastViewportDimension;
  Size get viewportDimension => _lastViewportDimension!;
  setViewportDimension(Size value, BuildContext context) {
    if (_lastViewportDimension == value) {
      return;
    }

    _lastViewportDimension = value;

    draggedOffset = draggedOffset.translate(value.width > sketcherSizeWithScale.width ? -draggedOffset.dx : 0,
        value.height > sketcherSizeWithScale.height ? -draggedOffset.dy : 0);
  }

  Offset _dragOffset = Offset.zero;
  Offset get draggedOffset => _dragOffset;
  set draggedOffset(Offset value) {
    if (value == _dragOffset) {
      return;
    }

    _dragOffset = value;
    notifyListeners();
  }

  void mouseRollerHandle(PointerScrollEvent event, BuildContext context) {
    if (event.scrollDelta.dy > 0) {
      reduceScale(context);
    } else {
      addScale(context);
    }
  }

  void boardDragHandle(Offset dragDelta, BuildContext context) {
    final target = _calculateDragTarget(viewportDimension, dragDelta);

    if (target != _dragOffset) {
      _dragOffset = target;
      notifyListeners();
    }
  }

  void addScale(BuildContext context) {
    if (_scale < 300) {
      final normalScaleDragOffset = _dragOffset / scale;
      _scale += 20;
      _dragOffset = normalScaleDragOffset * scale;
      notifyListeners();
    }
  }

  void reduceScale(BuildContext context) {
    if (_scale > 20) {
      final normalScaleDragOffset = _dragOffset / scale;
      _scale -= 20;
      _dragOffset = _calculateReduceScaleDragOffsetTarget(normalScaleDragOffset, viewportDimension);
      notifyListeners();
    }
  }

  Offset _calculateReduceScaleDragOffsetTarget(Offset normalScaleDragOffset, Size constraints) {
    var dx = normalScaleDragOffset.dx * scale;
    var dy = normalScaleDragOffset.dy * scale;

    if (constraints.width > _sketcherSize.width * scale) {
      dx = 0;
    } else {
      final edgeX = (sketcherSizeWithScale.width - constraints.width) / 2;
      dx = clampDouble(dx, -edgeX, edgeX);
    }

    if (constraints.height > _sketcherSize.height * scale) {
      dy = 0;
    } else {
      final edgeY = (sketcherSizeWithScale.height - constraints.height) / 2;
      dy = clampDouble(dx, -edgeY, edgeY);
    }

    return Offset(dx, dy);
  }

  Offset _calculateDragTarget(Size constraints, Offset dragDelta) {
    final fixedDragDelta = dragDelta * scale;
    var targetX = _dragOffset.dx;
    var targetY = _dragOffset.dy;

    if (constraints.height < _sketcherSize.height * scale) {
      final target = _dragOffset.dy + fixedDragDelta.dy;
      final edge = (_sketcherSize.height * scale - constraints.height) / 2;
      if (target < edge && target > -edge) {
        targetY = target;
      }
    }

    if (constraints.width < _sketcherSize.width * scale) {
      final target = _dragOffset.dx + fixedDragDelta.dx;
      final edge = (_sketcherSize.width * scale - constraints.width) / 2;
      if (target < edge && target > -edge) {
        targetX = target;
      }
    }

    return Offset(targetX, targetY);
  }
}
