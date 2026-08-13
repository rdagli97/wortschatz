class Topic {
  final int? id;
  final String keyword;      // kullanıcının merak ettiği konu, örn. "ins - zu farkı"
  final String explanation;  // Gemini'nin ürettiği konu anlatımı
  final int createdAt;       // epoch milisaniye

  const Topic({
    this.id,
    required this.keyword,
    required this.explanation,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'keyword': keyword,
      'explanation': explanation,
      'createdAt': createdAt,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as int?,
      keyword: map['keyword'] as String? ?? '',
      explanation: map['explanation'] as String? ?? '',
      createdAt: map['createdAt'] as int? ?? 0,
    );
  }
}
