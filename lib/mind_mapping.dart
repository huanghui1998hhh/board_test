import 'package:flutter/cupertino.dart';

class MindMapping extends ChangeNotifier {
  Set<RRect> rects = {
    RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 200, 200), const Radius.circular(20)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(200, 200, 200, 200), const Radius.circular(60)),
    RRect.fromRectAndRadius(const Rect.fromLTWH(400, 400, 800, 200), const Radius.circular(80)),
  };

  Set<RRect> selectedTemp = {};

  void onBlockSelected(RRect block) {
    rects.addAll(selectedTemp);
    selectedTemp.clear();
    rects.remove(block);
    selectedTemp.add(block);

    notifyListeners();
  }
}
