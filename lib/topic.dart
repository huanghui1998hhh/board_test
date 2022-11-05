class Topic {
  Topic({
    this.content = '',
    List<Topic>? children,
  }) : children = children ?? [];

  String content;

  List<Topic> children = [];
}
