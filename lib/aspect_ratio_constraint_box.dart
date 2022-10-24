import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AspectRatioConstraintBox extends SingleChildRenderObjectWidget {
  final double idealRatio;
  final double threshold;

  const AspectRatioConstraintBox({
    super.key,
    this.threshold = 20,
    required this.idealRatio,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAspectRatioConstraintBox(
        idealRatio: idealRatio,
        threshold: 20,
      );

  @override
  void updateRenderObject(BuildContext context, RenderAspectRatioConstraintBox renderObject) => renderObject
    ..idealRatio = idealRatio
    ..threshold = threshold;
}

class RenderAspectRatioConstraintBox extends RenderProxyBox {
  RenderAspectRatioConstraintBox({
    RenderBox? child,
    double idealRatio = 1,
    double threshold = 20,
  })  : _idealRatio = idealRatio,
        _threshold = 20,
        super(child);

  double _idealRatio;
  double get idealRatio => _idealRatio;
  set idealRatio(double value) {
    if (_idealRatio == value) {
      return;
    }

    _idealRatio = value;
    markNeedsPaint();
  }

  double _threshold;
  double get threshold => _threshold;
  set threshold(double value) {
    if (_threshold == value) {
      return;
    }

    _threshold = value;
    markNeedsPaint();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    assert(debugCannotComputeDryLayout(
      error: FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('The ${objectRuntimeType(this, 'RenderBox')} class does not implement "computeDryLayout".'),
        ErrorHint(
          'If you are not writing your own RenderBox subclass, then this is not\n'
          'your fault. Contact support: https://github.com/flutter/flutter/issues/new?template=2_bug.md',
        ),
      ]),
    ));
    return Size.zero;
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(const BoxConstraints(), parentUsesSize: true);
      size = child!.size;
      double lowerBound = 0;
      double upperBound = child!.size.width;

      while (upperBound - lowerBound > threshold) {
        final newWidth = (lowerBound + upperBound) / 2;
        child!.layout(BoxConstraints(maxWidth: newWidth), parentUsesSize: true);
        final currentRatio = child!.size.aspectRatio;
        if (currentRatio < idealRatio) {
          lowerBound = newWidth;
        } else {
          upperBound = newWidth;
        }
      }

      size = child!.size;
    } else {
      size = constraints.constrain(Size.zero);
    }
  }
}
