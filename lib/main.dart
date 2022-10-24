import 'package:board_test/aspect_ratio_constraint_box.dart';
import 'package:board_test/mind_mapping.dart';
import 'package:board_test/sketcher.dart';
import 'package:board_test/sketcher_scrollbar.dart';
import 'package:board_test/sketcher_scrollbar_painter.dart';
import 'package:board_test/sketcher_vm.dart';
import 'package:board_test/sketcker_content_stack.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hover_indicatable.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final controller = SketcherController();
  final _text = TextEditingController(text: 'asdklgjhasdlkjgha撒了开个价是露可简单');
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MindMapping(),
      builder: (context, child) => SketcherScrollbar(
        controller: controller,
        scrollAxis: SketcherScrollAxis.vertical,
        thickness: 20,
        thumbVisibility: true,
        trackVisibility: true,
        margin: const EdgeInsets.only(bottom: 20),
        child: SketcherScrollbar(
          controller: controller,
          scrollAxis: SketcherScrollAxis.horizontal,
          thickness: 20,
          thumbVisibility: true,
          trackVisibility: true,
          margin: const EdgeInsets.only(right: 20),
          child: Sketcher(
            controller: controller,
            builder: (context) {
              return SketcherContnetStack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: HoverIndicatable(
                      child: AspectRatioConstraintBox(
                        idealRatio: 3,
                        threshold: 40,
                        child: EditableText(
                          style: const TextStyle(fontSize: 20, color: Colors.black),
                          controller: _text,
                          backgroundCursorColor: Colors.blue,
                          cursorColor: Colors.red,
                          focusNode: _focusNode,
                          maxLines: null,
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
