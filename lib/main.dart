import 'package:board_test/mind_mapping.dart';
import 'package:board_test/new_map_temp.dart';
import 'package:board_test/sketcher.dart';
import 'package:board_test/sketcher_scrollbar.dart';
import 'package:board_test/sketcher_scrollbar_painter.dart';
import 'package:board_test/sketcher_controller.dart';
import 'package:board_test/topic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MindMapping(),
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: SketcherScrollbar(
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
                    onTapSpace: () {
                      context.read<MindMapping>().selectedTopic = null;
                    },
                    child: MindMap(topic: context.read<MindMapping>().mainTopic),
                  ),
                ),
              ),
            ),
            Container(
              width: 270,
              color: const Color.fromRGBO(245, 245, 245, 1),
              child: Selector<MindMapping, Topic?>(
                selector: (_, mindMapping) => mindMapping.selectedTopic,
                builder: (context, selectedTopic, child) {
                  if (selectedTopic == null) {
                    return const SizedBox();
                  }
                  return ListView(
                    children: [
                      Selector<MindMapping, double>(
                        selector: (_, mindMapping) => mindMapping.selectedTopic!.style.textSize,
                        builder: (context, textSize, child) => Slider(
                          value: textSize,
                          min: 5,
                          max: 96,
                          onChanged: (value) => context.read<MindMapping>().selectedTopicStyle =
                              context.read<MindMapping>().selectedTopic!.style.copyWith(textSize: value),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
