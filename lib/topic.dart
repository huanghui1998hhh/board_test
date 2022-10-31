class Topic {
  Topic.sub({
    this.content = '',
    required List<Topic> father,
  }) : father = father.toList() {
    for (var e in father) {
      e.children.add(this);
    }
  }

  Topic.main({this.content = ''}) : father = [];

  String content;

  List<Topic> father;
  List<Topic> children = [];
}
