import 'package:board_test/drawable.dart';

class Topic extends BlockDrawable {
  Topic({
    this.content = '',
    this.isMain = false,
  });

  String content;
  bool isMain;

  @override
  void draw() {
    super.draw();
    print(1);
  }
}
