import 'package:board_test/mind_mapping.dart';
import 'package:board_test/sketcher_controller.dart';
import 'package:board_test/sketcker_content_stack.dart';
import 'package:board_test/transform_viewport.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sketcher extends StatefulWidget {
  final Widget child;
  final SketcherController controller;
  final VoidCallback onTapSpace;
  const Sketcher({
    Key? key,
    required this.controller,
    required this.child,
    required this.onTapSpace,
  }) : super(key: key);

  @override
  State<Sketcher> createState() => _SketcherState();
}

class _SketcherState extends State<Sketcher> {
  Widget? cache;

  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
      value: widget.controller,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            widget.controller.mouseRollerHandle(-event.scrollDelta);
          }
        },
        child: Stack(
          children: [
            TransformViewport(
              mindMap: context.read<MindMapping>(),
              controller: widget.controller,
              child: SketckerStack(
                controller: widget.controller,
                children: [
                  widget.child,
                ],
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
                      onPressed: () => context.read<SketcherController>().zoomOut(),
                      icon: const Text('-'),
                    ),
                    IconButton(
                      onPressed: () => context.read<SketcherController>().zoomIn(),
                      icon: const Text('+'),
                    ),
                    IconButton(
                      onPressed: () => context.read<MindMapping>().selectedTopic?.addSubTopic(),
                      icon: const Text('+++'),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<MindMapping>().deleteSelected();
                      },
                      icon: const Text('---'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
