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

  Topic mainTopic = Topic.main(content: '中心主题');
  late Topic topic1 = Topic.sub(content: '分支主题1', father: [mainTopic]);
  late Topic topic2 = Topic.sub(content: '分支主题2', father: [mainTopic]);

  late List<Topic> topics = [mainTopic, topic1, topic2];
}
