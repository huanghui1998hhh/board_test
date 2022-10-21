import 'package:board_test/mind_mapping.dart';
import 'package:board_test/sketcher.dart';
import 'package:board_test/sketcher_scrollbar.dart';
import 'package:board_test/sketcher_scrollbar_painter.dart';
import 'package:board_test/sketcher_vm.dart';
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
              return const Text(
                '你好',
                style: TextStyle(fontSize: 96),
              );
            },
          ),
        ),
      ),
    );
  }
}
