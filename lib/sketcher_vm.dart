import 'package:board_test/sketcher_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class SketcherVM extends ChangeNotifier {
  int _scale = 100;

  double get scale => _scale / 100;
  String get indicatorString => '$_scale%';

  Set<RRect> rects = {
    RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 200, 200), const Radius.circular(20)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(200, 200, 200, 200), const Radius.circular(60)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(400, 400, 800, 200), const Radius.circular(80)),
  };

  Set<RRect> selectedTemp = {};

  Offset dragOffset = Offset.zero;

  void mouseRollerHandle(BoxConstraints constraints, PointerScrollEvent event) {
    if (event.scrollDelta.dy > 0) {
      reduceScale(constraints);
    } else {
      addScale();
    }
  }

  void onBlockSelected(RRect block) {
    rects.addAll(selectedTemp);
    selectedTemp.clear();
    rects.remove(block);
    selectedTemp.add(block);

    notifyListeners();
  }

  void boardDragHandle(BoxConstraints constraints, Offset dragDelta) {
    var targetX = dragOffset.dx;
    var targetY = dragOffset.dy;
    if (constraints.maxHeight < SketcherData.size.height * scale) {
      final target = dragOffset.dy + dragDelta.dy;
      final edge = (SketcherData.size.height * scale - constraints.maxHeight) / 2;
      if (target < edge && target > -edge) {
        targetY = target;
      }
    }
    if (constraints.maxWidth < SketcherData.size.width * scale) {
      final target = dragOffset.dx + dragDelta.dx;
      final edge = (SketcherData.size.width * scale - constraints.maxWidth) / 2;
      if (target < edge && target > -edge) {
        targetX = target;
      }
    }
    final target = Offset(targetX, targetY);
    if (target != dragOffset) {
      dragOffset = target;

      notifyListeners();
    }
  }

  void addScale() {
    if (_scale < 300) {
      final normalScaleDragOffset = dragOffset / scale;
      _scale += 20;
      dragOffset = normalScaleDragOffset * scale;

      notifyListeners();
    }
  }

  void reduceScale(BoxConstraints constraints) {
    if (_scale > 20) {
      final normalScaleDragOffset = dragOffset / scale;

      var dx = normalScaleDragOffset.dx;
      var dy = normalScaleDragOffset.dy;

      _scale -= 20;

      dx *= scale;
      dy *= scale;

      if (constraints.maxWidth > SketcherData.size.width * scale) {
        dx = 0;
      } else {
        final edgeX = (SketcherData.size.width * scale - constraints.maxWidth) / 2;
        if (dx > edgeX) {
          dx = edgeX;
        } else if (dx < -edgeX) {
          dx = -edgeX;
        }
      }

      if (constraints.maxHeight > SketcherData.size.height * scale) {
        dy = 0;
      } else {
        final edgeY = (SketcherData.size.height * scale - constraints.maxHeight) / 2;
        if (dy > edgeY) {
          dy = edgeY;
        } else if (dy < -edgeY) {
          dy = -edgeY;
        }
      }

      dragOffset = Offset(dx, dy);

      notifyListeners();
    }
  }
}
