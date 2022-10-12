import 'package:board_test/selected_sketcher.dart';
import 'package:board_test/sketcher_data.dart';
import 'package:board_test/unselected_sketcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Sketcher extends StatefulWidget {
  const Sketcher({Key? key}) : super(key: key);

  @override
  State<Sketcher> createState() => _SketcherState();
}

class _SketcherState extends State<Sketcher> {
  int _scale = 100;

  double get scale => _scale / 100;

  Set<RRect> rects = {
    RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 200, 200), const Radius.circular(20)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(200, 200, 200, 200), const Radius.circular(60)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(400, 400, 800, 200), const Radius.circular(80)),
  };

  Set<RRect> selectedTemp = {};

  Offset dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _mouseRollerHandle(constraints, event);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey,
          body: Center(
            child: UnconstrainedBox(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: dragOffset,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: SketcherData.size.height * scale,
                      width: SketcherData.size.width * scale,
                      color: Colors.white,
                    ),
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          UnselectedSketcher(
                            rects: rects,
                            onSelected: _onBlockSelected,
                            onDraggedBoard: (e) => _boardDragHandle(constraints, e),
                          ),
                          SelectedSketcher(
                            rects: selectedTemp,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: ButtonBar(
            children: [
              Text('$_scale%'),
              IconButton(
                onPressed: () => _reduceScale(constraints),
                icon: const Text('-'),
              ),
              IconButton(onPressed: _addScale, icon: const Text('+')),
            ],
          ),
        ),
      ),
    );
  }

  void _mouseRollerHandle(BoxConstraints constraints, PointerScrollEvent event) {
    if (event.scrollDelta.dy > 0) {
      _reduceScale(constraints);
    } else {
      _addScale();
    }
  }

  void _onBlockSelected(RRect block) {
    setState(() {
      rects.addAll(selectedTemp);
      selectedTemp.clear();
      rects.remove(block);
      selectedTemp.add(block);
    });
  }

  void _boardDragHandle(BoxConstraints constraints, Offset dragDelta) {
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
      setState(() {
        dragOffset = target;
      });
    }
  }

  void _addScale() {
    if (_scale < 300) {
      setState(() {
        final normalScaleDragOffset = dragOffset / scale;
        _scale += 20;
        dragOffset = normalScaleDragOffset * scale;
      });
    }
  }

  void _reduceScale(BoxConstraints constraints) {
    if (_scale > 20) {
      setState(() {
        var dx = dragOffset.dx;
        var dy = dragOffset.dy;
        if (constraints.maxWidth < SketcherData.size.width * scale) {
          dx = 0;
        }
        if (constraints.maxHeight < SketcherData.size.height * scale) {
          dy = 0;
        }
        final normalScaleDragOffset = Offset(dx, dy) / scale;
        _scale -= 20;
        dragOffset = normalScaleDragOffset * scale;
      });
    }
  }
}
