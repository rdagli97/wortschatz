class Word {
  final int? id;
  final String article;              // der / die / das
  final String word;                 // Haus
  final String meaningEn;            // House
  final String meaningTr;            // Ev
  final String plural;               // Häuser
  final String exampleSentence;      // Das Haus ist groß.
  final String exampleTranslationEn; // The house is big.
  final String exampleTranslationTr; // Ev büyük.

  const Word({
    this.id,
    required this.article,
    required this.word,
    required this.meaningEn,
    required this.meaningTr,
    required this.plural,
    required this.exampleSentence,
    required this.exampleTranslationEn,
    required this.exampleTranslationTr,
  });

  // SQLite'a yazmak için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'article': article,
      'word': word,
      'meaningEn': meaningEn,
      'meaningTr': meaningTr,
      'plural': plural,
      'exampleSentence': exampleSentence,
      'exampleTranslationEn': exampleTranslationEn,
      'exampleTranslationTr': exampleTranslationTr,
    };
  }

  // SQLite'tan okunan Map'i Word nesnesine çevir
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      article: map['article'] as String? ?? '',
      word: map['word'] as String? ?? '',
      meaningEn: map['meaningEn'] as String? ?? '',
      meaningTr: map['meaningTr'] as String? ?? '',
      plural: map['plural'] as String? ?? '',
      exampleSentence: map['exampleSentence'] as String? ?? '',
      exampleTranslationEn: map['exampleTranslationEn'] as String? ?? '',
      exampleTranslationTr: map['exampleTranslationTr'] as String? ?? '',
    );
  }
}