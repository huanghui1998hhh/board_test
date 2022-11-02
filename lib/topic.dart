import 'package:board_test/hover_indicatable.dart';

class Topic {
  Topic.sub({
    this.content = '',
    required Topic this.father,
  }) {
    father!.children.add(this);
  }

  Topic.main({this.content = ''}) : father = null;

  String content;

  Topic? father;
  List<Topic> children = [];

  RenderHoverIndicatable? render;
}
