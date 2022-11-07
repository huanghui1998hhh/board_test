import 'package:board_test/topic.dart';
import 'package:flutter/cupertino.dart';

class MindMapping extends ChangeNotifier {
  Topic? _selectedTopic;
  Topic? get selectedTopic => _selectedTopic;
  set selectedTopic(Topic? newSelected) {
    if (newSelected == _selectedTopic) {
      return;
    }

    _selectedTopic = newSelected;
    notifyListeners();
  }

  set selectedTopicStyle(TopicStyle style) {
    selectedTopic?.style = style;
    notifyListeners();
  }

  Topic mainTopic = Topic(content: '中心主题', children: [
    Topic(content: '分支主题1', children: [
      Topic(content: '分支1的分支主题1'),
      Topic(content: '分支1的分支主题2'),
    ]),
    Topic(content: '分支主题2'),
    Topic(content: '分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3', children: [
      Topic(content: '分支3的分支主题1'),
      Topic(content: '分支3的分支主题2'),
      Topic(content: '分支3的分支主题3'),
      Topic(content: '分支3的分支主题4'),
      Topic(content: '分支3的分支主题5'),
      Topic(content: '分支3的分支主题6'),
      Topic(content: '分支3的分支主题7'),
      Topic(content: '分支3的分支主题8'),
    ]),
  ]);
}
