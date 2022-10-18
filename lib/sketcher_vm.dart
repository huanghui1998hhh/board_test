import 'package:board_test/sketcher_data.dart';
import 'package:board_test/sketcher_scrollbar.dart';
import 'package:board_test/sketcher_scrollbar_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SketcherPositionMetrics {
  SketcherPositionMetrics(
    this.viewportDimension,
    this.sketcherSizeWithScale,
    this.dragOffset,
  );

  double viewportDimension;
  double sketcherSizeWithScale;
  double dragOffset;
}

class SketcherController extends ChangeNotifier {
  int _scale = 100;

  double get scale => _scale / 100;
  String get indicatorString => '$_scale%';
  double get lowerBoundX => (sketcherSizeWithScale.width - viewportDimension.width) / 2;
  double get lowerBoundY => (sketcherSizeWithScale.height - viewportDimension.height) / 2;
  Size get sketcherSizeWithScale => SketcherData.size * scale;

  Size? _viewportDimension;
  Size get viewportDimension => _viewportDimension!;
  setViewportDimension(Size value, BuildContext context) {
    if (_viewportDimension == value) {
      return;
    }

    _viewportDimension = value;

    dragOffset = dragOffset.translate(value.width > sketcherSizeWithScale.width ? -dragOffset.dx : 0,
        value.height > sketcherSizeWithScale.height ? -dragOffset.dy : 0);

    dispatch(context);
  }

  Set<RRect> rects = {
    RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 200, 200), const Radius.circular(20)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(200, 200, 200, 200), const Radius.circular(60)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(400, 400, 800, 200), const Radius.circular(80)),
  };

  Set<RRect> selectedTemp = {};

  Offset _dragOffset = Offset.zero;
  Offset get dragOffset => _dragOffset;
  set dragOffset(Offset value) {
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

  void onBlockSelected(RRect block) {
    rects.addAll(selectedTemp);
    selectedTemp.clear();
    rects.remove(block);
    selectedTemp.add(block);

    notifyListeners();
  }

  void boardDragHandle(Offset dragDelta, BuildContext context) {
    final target = _calculateDragTarget(viewportDimension, dragDelta);

    if (target != _dragOffset) {
      _dragOffset = target;
      dispatch(context);
      notifyListeners();
    }
  }

  void addScale(BuildContext context) {
    if (_scale < 300) {
      final normalScaleDragOffset = _dragOffset / scale;
      _scale += 20;
      _dragOffset = normalScaleDragOffset * scale;
      dispatch(context);
      notifyListeners();
    }
  }

  void reduceScale(BuildContext context) {
    if (_scale > 20) {
      final normalScaleDragOffset = _dragOffset / scale;
      _scale -= 20;
      _dragOffset = _calculateReduceScaleDragOffsetTarget(normalScaleDragOffset, viewportDimension);
      dispatch(context);
      notifyListeners();
    }
  }

  void dispatch(BuildContext context) {
    SketcherVMetricsNotification(
            SketcherPositionMetrics(viewportDimension.height, sketcherSizeWithScale.height, _dragOffset.dy))
        .dispatch(context);
    SketcherHMetricsNotification(
            SketcherPositionMetrics(viewportDimension.width, sketcherSizeWithScale.width, _dragOffset.dx))
        .dispatch(context);
  }

  SketcherMetricsNotification createNotification(
          SketcherScrollAxis scrollAxis) =>
      scrollAxis == SketcherScrollAxis.vertical
          ? SketcherVMetricsNotification(
              SketcherPositionMetrics(viewportDimension.height, sketcherSizeWithScale.height, _dragOffset.dy))
          : SketcherHMetricsNotification(
              SketcherPositionMetrics(viewportDimension.width, sketcherSizeWithScale.width * scale, _dragOffset.dx));

  Offset _calculateReduceScaleDragOffsetTarget(Offset normalScaleDragOffset, Size constraints) {
    var dx = normalScaleDragOffset.dx * scale;
    var dy = normalScaleDragOffset.dy * scale;

    if (constraints.width > SketcherData.size.width * scale) {
      dx = 0;
    } else {
      final edgeX = (sketcherSizeWithScale.width - constraints.width) / 2;
      dx = clampDouble(dx, -edgeX, edgeX);
    }

    if (constraints.height > SketcherData.size.height * scale) {
      dy = 0;
    } else {
      final edgeY = (sketcherSizeWithScale.height - constraints.height) / 2;
      dy = clampDouble(dx, -edgeY, edgeY);
    }

    return Offset(dx, dy);
  }

  Offset _calculateDragTarget(Size constraints, Offset dragDelta) {
    var targetX = _dragOffset.dx;
    var targetY = _dragOffset.dy;

    if (constraints.height < SketcherData.size.height * scale) {
      final target = _dragOffset.dy + dragDelta.dy;
      final edge = (SketcherData.size.height * scale - constraints.height) / 2;
      if (target < edge && target > -edge) {
        targetY = target;
      }
    }

    if (constraints.width < SketcherData.size.width * scale) {
      final target = _dragOffset.dx + dragDelta.dx;
      final edge = (SketcherData.size.width * scale - constraints.width) / 2;
      if (target < edge && target > -edge) {
        targetX = target;
      }
    }

    return Offset(targetX, targetY);
  }
}
