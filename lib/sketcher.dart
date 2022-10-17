import 'package:board_test/selected_sketcher.dart';
import 'package:board_test/sketcher_data.dart';
import 'package:board_test/sketcher_vm.dart';
import 'package:board_test/unselected_sketcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sketcher extends StatefulWidget {
  final SketcherController controller;
  const Sketcher({Key? key, required this.controller}) : super(key: key);

  @override
  State<Sketcher> createState() => _SketcherState();
}

class _SketcherState extends State<Sketcher> {
  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
      value: widget.controller,
      child: LayoutBuilder(
        builder: (context, constraints) => Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              context.read<SketcherController>().mouseRollerHandle(constraints, event, context);
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
                            Container(
                              height: SketcherData.size.height * scale,
                              width: SketcherData.size.width * scale,
                              color: Colors.white,
                            ),
                            Transform.scale(
                              scale: scale,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Selector<SketcherController, Set<RRect>>(
                              selector: (_, sketcherVM) => sketcherVM.rects,
                              shouldRebuild: (_, __) => true,
                              builder: (_, rects, __) => UnselectedSketcher(
                                rects: rects,
                                onSelected: context.read<SketcherController>().onBlockSelected,
                                onDraggedBoard: (e) {
                                  context.read<SketcherController>().boardDragHandle(constraints, e, context);
                                },
                              ),
                            ),
                            Selector<SketcherController, Set<RRect>>(
                              selector: (_, sketcherVM) => sketcherVM.selectedTemp,
                              shouldRebuild: (_, __) => true,
                              builder: (_, selectedTemp, __) => SelectedSketcher(
                                rects: selectedTemp,
                                color: Colors.red,
                              ),
                            ),
                          ],
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
                        onPressed: () => context.read<SketcherController>().reduceScale(constraints, context),
                        icon: const Text('-'),
                      ),
                      IconButton(
                          onPressed: () => context.read<SketcherController>().addScale(constraints, context),
                          icon: const Text('+')),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
