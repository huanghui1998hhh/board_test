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
  // late Topic topic1 =;
  // late Topic topic2 = Topic(content: '分支主题2', father: mainTopic);
  // late Topic topic3 =
  //     Topic(content: '分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3分支主题3', father: mainTopic);
  // late Topic topic11 = Topic.sub(content: '分支1的分支主题1', father: topic1);
  // late Topic topic12 = Topic.sub(content: '分支1的分支主题2', father: topic1);
  // late Topic topic31 = Topic.sub(content: '分支3的分支主题1', father: topic3);
  // late Topic topic32 = Topic.sub(content: '分支3的分支主题2', father: topic3);
  // late Topic topic33 = Topic.sub(content: '分支3的分支主题3', father: topic3);
  // late Topic topic34 = Topic.sub(content: '分支3的分支主题4', father: topic3);
  // late Topic topic35 = Topic.sub(content: '分支3的分支主题5', father: topic3);
}
