import 'package:board_test/sketcher_controller.dart';
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
          context.read<SketcherController>().setViewportDimension(constraints.biggest, context);

          return Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                context.read<SketcherController>().mouseRollerHandle(event, context);
              }
            },
            child: Container(
              color: Colors.grey,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: UnconstrainedBox(
                      alignment: Alignment.center,
                      child: Selector<SketcherController, Offset>(
                        selector: (_, sketcherVM) => sketcherVM.dragOffset,
                        builder: (_, dragOffset, child) => Transform.translate(
                          offset: dragOffset,
                          child: child,
                        ),
                        child: Selector<SketcherController, double>(
                          selector: (_, sketcherVM) => sketcherVM.scale,
                          builder: (_, scale, child) => Stack(
                            alignment: Alignment.center,
                            children: [
                              Selector<SketcherController, Size>(
                                selector: (_, sketcherVM) => sketcherVM.sketcherSize,
                                builder: (_, size, child) => GestureDetector(
                                  onTap: widget.onTapSpace,
                                  child: Container(
                                    height: size.height * scale,
                                    width: size.width * scale,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: scale,
                                alignment: Alignment.center,
                                child: child,
                              ),
                            ],
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
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ButtonBar(
                      children: [
                        Selector<SketcherController, String>(
                          selector: (_, sketcherVM) => sketcherVM.indicatorString,
                          builder: (_, indicatorString, __) => Text(indicatorString),
                        ),
                        IconButton(
                          onPressed: () => context.read<SketcherController>().reduceScale(context),
                          icon: const Text('-'),
                        ),
                        IconButton(
                            onPressed: () => context.read<SketcherController>().addScale(context),
                            icon: const Text('+')),
                      ],
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
