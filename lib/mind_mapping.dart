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

  Topic mainTopic = Topic(content: '中心主题');
}
