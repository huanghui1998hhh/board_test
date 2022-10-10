import 'package:board_test/nice.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(const MyApp());

class A {
  static const Size a = Size(2000, 1000);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _scale = 100;

  double get scale => _scale / 100;

  Set<RRect> rects = {
    RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, 200, 200), Radius.circular(20)),
    RRect.fromRectAndRadius(
        Rect.fromLTWH(200, 200, 200, 200), Radius.circular(60)),
    RRect.fromRectAndRadius(
        Rect.fromLTWH(400, 400, 200, 200), Radius.circular(80)),
  };

  Set<RRect> selectedTemp = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: MyApp._title,
      home: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy > 0) {
              if (_scale > 20) {
                setState(() {
                  _scale -= 20;
                });
              }
            } else {
              if (_scale < 500) {
                setState(() {
                  _scale += 20;
                });
              }
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey,
          body: LayoutBuilder(
            builder: (context, constraints) => UnconstrainedBox(
              alignment: Alignment.topLeft,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: A.a.height,
                      width: A.a.width,
                      color: Colors.white,
                    ),
                    Sketcher(
                      rects: rects,
                      onSelect: (e) {
                        setState(() {
                          rects.addAll(selectedTemp);
                          selectedTemp.clear();
                          rects.remove(e);
                          selectedTemp.add(e);
                        });
                      },
                    ),
                    Sketcher1(
                      rects: selectedTemp,
                      color: Colors.red,
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
                  onPressed: () {
                    if (_scale > 20) {
                      setState(() {
                        _scale -= 20;
                      });
                    }
                  },
                  icon: Text('-')),
              IconButton(
                  onPressed: () {
                    if (_scale < 500) {
                      setState(() {
                        _scale += 20;
                      });
                    }
                  },
                  icon: Text('+')),
            ],
          ),
        ),
      ),
    );
  }
}

class Sketcher extends LeafRenderObjectWidget {
  final Set<RRect> rects;
  final Color color;
  final void Function(RRect)? onSelect;

  const Sketcher({
    super.key,
    required this.rects,
    this.color = Colors.black,
    this.onSelect,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSketcher(rects, color, onSelect);

  @override
  void updateRenderObject(
          BuildContext context, covariant RenderSketcher renderObject) =>
      renderObject
        ..rects = rects
        ..color = color;
}

class RenderSketcher extends RenderBox {
  RenderSketcher(this._rects, Color color, this.onSelect)
      : pen = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

  Set<RRect> _rects;
  set rects(Set<RRect> value) {
    _rects = value;
    markNeedsPaint();
  }

  void Function(RRect)? onSelect;

  Paint pen;

  set color(Color value) {
    pen.color = value;
    markNeedsPaint();
  }

  // Picture? _picture;
  // final _previous = Path();
  // var _current = Path();

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    // if (event is PointerDownEvent) {
    //   _current.moveTo(event.localPosition.dx, event.localPosition.dy);
    // } else if (event is PointerMoveEvent) {
    //   _current.lineTo(event.localPosition.dx, event.localPosition.dy);
    //   markNeedsPaint();
    // } else if (event is PointerUpEvent) {
    //   _previous.addPath(_current, Offset.zero);
    //   _current = Path();
    //   PictureRecorder recorder = PictureRecorder();
    //   Canvas canvas = Canvas(recorder);
    //   canvas.drawPath(_previous, pen2);
    //   _picture = recorder.endRecording();
    //   markNeedsPaint();
    // }
    if (event is PointerDownEvent) {
      final rect =
          _rects.firstWhereOrNull((e) => e.contains(event.localPosition));
      if (rect != null) {
        onSelect?.call(rect);
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.translate(offset.dx, offset.dy);

    // if (_picture != null) context.canvas.drawPicture(_picture!);
    // context.canvas.drawPath(_current, pen);
    // context.canvas
    //     .drawRRect(RRect.fromLTRBR(0, 0, 20, 20, Radius.circular(8)), pen);
    // TextPainter(text: TextSpan(text: "text"), textDirection: TextDirection.ltr)
    //   ..layout()
    //   ..paint(context.canvas, offset);

    for (var e in _rects) {
      context.canvas.drawRRect(e, pen);
    }
  }

  @override
  void performLayout() => size = A.a;

  @override
  bool hitTestSelf(Offset position) => true;
}
