import 'package:board_test/selected_sketcher.dart';
import 'package:board_test/sketcher_data.dart';
import 'package:board_test/sketcher_vm.dart';
import 'package:board_test/unselected_sketcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sketcher extends StatefulWidget {
  const Sketcher({Key? key}) : super(key: key);

  @override
  State<Sketcher> createState() => _SketcherState();
}

class _SketcherState extends State<Sketcher> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SketcherVM(),
      child: LayoutBuilder(
        builder: (context, constraints) => Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              context.read<SketcherVM>().mouseRollerHandle(constraints, event);
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
                    child: Selector<SketcherVM, Offset>(
                      selector: (_, sketcherVM) => sketcherVM.dragOffset,
                      builder: (_, dragOffset, child) => Transform.translate(
                        offset: dragOffset,
                        child: child,
                      ),
                      child: Selector<SketcherVM, double>(
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
                            Selector<SketcherVM, Set<RRect>>(
                              selector: (_, sketcherVM) => sketcherVM.rects,
                              shouldRebuild: (_, __) => true,
                              builder: (_, rects, __) => UnselectedSketcher(
                                rects: rects,
                                onSelected: context.read<SketcherVM>().onBlockSelected,
                                onDraggedBoard: (e) => context.read<SketcherVM>().boardDragHandle(constraints, e),
                              ),
                            ),
                            Selector<SketcherVM, Set<RRect>>(
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
                      Selector<SketcherVM, String>(
                        selector: (_, sketcherVM) => sketcherVM.indicatorString,
                        builder: (_, indicatorString, __) => Text(indicatorString),
                      ),
                      IconButton(
                        onPressed: () => context.read<SketcherVM>().reduceScale(constraints),
                        icon: const Text('-'),
                      ),
                      IconButton(onPressed: context.read<SketcherVM>().addScale, icon: const Text('+')),
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
