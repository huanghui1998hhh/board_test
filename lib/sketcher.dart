import 'package:board_test/sketcher_controller.dart';
import 'package:board_test/tappable_colored_box.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sketcher extends StatefulWidget {
  final WidgetBuilder builder;
  final SketcherController controller;
  final VoidCallback onTapSpace;
  const Sketcher({
    Key? key,
    required this.controller,
    required this.builder,
    required this.onTapSpace,
  }) : super(key: key);

  @override
  State<Sketcher> createState() => _SketcherState();
}

class _SketcherState extends State<Sketcher> {
  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
      value: widget.controller,
      child: LayoutBuilder(
        builder: (context, constraints) {
          widget.controller.viewportDimension = constraints.biggest;

          return Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                widget.controller.mouseRollerHandle(event.scrollDelta);
              }
            },
            child: Container(
              color: Colors.grey,
              child: Stack(
                fit: StackFit.passthrough,
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Selector<SketcherController, Offset>(
                      selector: (_, sketcherVM) => sketcherVM.draggedOffset,
                      builder: (_, dragOffset, child) => Transform.translate(
                        offset: dragOffset,
                        child: child,
                      ),
                      child: Selector<SketcherController, double>(
                        selector: (_, sketcherVM) => sketcherVM.scale,
                        builder: (_, scale, child) => Transform.scale(
                          scale: scale,
                          alignment: Alignment.center,
                          child: UnconstrainedBox(
                            child: TappableColoredBox(
                              color: Colors.white,
                              child: child,
                            ),
                          ),
                        ),
                        child: Selector<SketcherController, Size>(
                          selector: (_, sketcherVM) => sketcherVM.sketcherSize,
                          builder: (_, size, child) => SizedBox(
                            height: size.height,
                            width: size.width,
                            child: child,
                          ),
                          child: widget.builder(context),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ButtonBar(
                        children: [
                          Selector<SketcherController, String>(
                            selector: (_, sketcherVM) => sketcherVM.indicatorString,
                            builder: (_, indicatorString, __) => Text(indicatorString),
                          ),
                          IconButton(
                            onPressed: () => context.read<SketcherController>().reduceScale(),
                            icon: const Text('-'),
                          ),
                          IconButton(
                            onPressed: () => context.read<SketcherController>().addScale(),
                            icon: const Text('+'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
