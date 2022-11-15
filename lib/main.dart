import 'package:board_test/mind_mapping.dart';
import 'package:board_test/new_map_temp.dart';
import 'package:board_test/sketcher.dart';
import 'package:board_test/sketcher_controller.dart';
import 'package:board_test/topic.dart';
import 'package:board_test/topic_setting_block/double_setting_block.dart';
import 'package:board_test/topic_setting_block/dropdown_button_setting_block.dart';
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MindMapping(),
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: Sketcher(
                controller: controller,
                onTapSpace: () {
                  context.read<MindMapping>().selectedTopic = null;
                },
                child: MindMap(topic: context.read<MindMapping>().mainTopic),
              ),
            ),
            Container(
              width: 270,
              color: const Color.fromRGBO(245, 245, 245, 1),
              child: Selector<MindMapping, Topic?>(
                selector: (_, mindMapping) => mindMapping.selectedTopic,
                builder: (context, selectedTopic, child) {
                  if (selectedTopic == null) {
                    return const Center(child: Text('no selected'));
                  }

                  return ListView(
                    children: [
                      DoubleSettingBlock(
                        value: selectedTopic.style.textSize,
                        onChange: (value) {
                          selectedTopic.style = selectedTopic.style.copyWith(textSize: value);
                        },
                      ),
                      DropdownButtonSettingBlock(
                        value: selectedTopic.layout,
                        onChange: (value) {
                          selectedTopic.layout = value;
                        },
                        values: TopicLayout.values,
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
