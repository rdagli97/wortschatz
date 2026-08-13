class Story {
  final int? id;
  final String level;      // 'A1' / 'A2' / 'B1'
  final String topic;      // kullanıcının girdiği ya da AI'ın seçtiği konu
  final String title;
  final String content;    // her satırda bir cümle
  final int createdAt;     // epoch milisaniye

  const Story({
    this.id,
    required this.level,
    required this.topic,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level,
      'topic': topic,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'] as int?,
      level: map['level'] as String? ?? '',
      topic: map['topic'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: map['createdAt'] as int? ?? 0,
    );
  }
}
