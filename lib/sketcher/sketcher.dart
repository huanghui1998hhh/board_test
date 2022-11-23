import 'package:board_test/composited_scale_transform_follower/composited_scale_transform_follower.dart';
import 'package:board_test/model/mind_mapping.dart';
import 'package:board_test/sketcher/sketcher_controller.dart';
import 'package:board_test/sketcher/sketcher_scrollbar/sketcher_scrollbar.dart';
import 'package:board_test/sketcher/sketcher_scrollbar/sketcher_scrollbar_painter.dart';
import 'package:board_test/sketcher/sketcher_tool_bar/sketcher_tool_bar.dart';
import 'package:board_test/sketcher/sketcker_content_stack.dart';
import 'package:board_test/topic_setting_block/value_selector.dart';
import 'package:board_test/sketcher/transform_viewport.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Sketcher extends StatefulWidget {
  final Widget child;
  final SketcherController? controller;
  const Sketcher({
    Key? key,
    this.controller,
    required this.child,
  }) : super(key: key);

  @override
  State<Sketcher> createState() => _SketcherState();
}

class _SketcherState extends State<Sketcher> {
  SketcherController? _controller;
  SketcherController get _effectiveController => widget.controller ?? (_controller ??= SketcherController());

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.delete) {
            context.read<MindMapping>().selectedTopic?.remove();
          }
        }

        return KeyEventResult.handled;
      },
      child: SketcherScrollbar(
        controller: _effectiveController,
        scrollAxis: SketcherScrollAxis.vertical,
        thickness: 20,
        thumbVisibility: true,
        trackVisibility: true,
        margin: const EdgeInsets.only(bottom: 20),
        child: SketcherScrollbar(
          controller: _effectiveController,
          scrollAxis: SketcherScrollAxis.horizontal,
          thickness: 20,
          thumbVisibility: true,
          trackVisibility: true,
          margin: const EdgeInsets.only(right: 20),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                _effectiveController.mouseRollerHandle(-event.scrollDelta);
              }
            },
            child: Stack(
              children: [
                TransformViewport(
                  mindMap: context.read<MindMapping>(),
                  controller: _effectiveController,
                  child: SketckerStack(
                    controller: _effectiveController,
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
                        ValueSelector<SketcherController, String>(
                          controller: _effectiveController,
                          valueBuilder: (_, controller) => controller.indicatorString,
                          builder: (_, indicatorString, __) => Text(indicatorString),
                        ),
                        IconButton(
                          onPressed: () => _effectiveController.zoomOut(),
                          icon: const Text('-'),
                        ),
                        IconButton(
                          onPressed: () => _effectiveController.zoomIn(),
                          icon: const Text('+'),
                        ),
                        IconButton(
                          onPressed: () => context.read<MindMapping>().selectedTopic?.addSubTopic(),
                          icon: const Text('+++'),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<MindMapping>().selectedTopic?.remove();
                          },
                          icon: const Text('---'),
                        ),
                      ],
                    ),
                  ),
                ),
                CompositedScaleTransformFollower(
                  link: context.read<MindMapping>().layerLink,
                  targetAnchor: Alignment.topCenter,
                  followerAnchor: Alignment.bottomCenter,
                  showWhenUnlinked: false,
                  followScaleTransform: false,
                  offset: const Offset(0, -15),
                  child: SketcherToolBar(mindMapping: context.read<MindMapping>()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
