// Kelimenin öğrenilme durumu (correctStreak/reviewCount'tan türetilir)
enum WordCategory { newWord, difficult, wellLearned }

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
  final int correctStreak;           // ardışık doğru bilme sayısı (yanlışta 0'a döner)
  final int reviewCount;             // toplam tekrar (doğru+yanlış) sayısı
  final String? level;               // null = kullanıcının kendi kelimesi, 'A1'/'A2'/'B1' = Goethe listesi

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
    this.correctStreak = 0,
    this.reviewCount = 0,
    this.level,
  });

  // Kaç kez tekrar edildiğine ve ardışık doğru sayısına göre kategori
  WordCategory get category {
    // 3 tekrardan az kelime, doğru bilinmiş olsa bile henüz "iyi öğrenilmiş"
    // sayılacak kadar tekrar edilmemiştir; zorlanılan listesine düşmesin.
    if (reviewCount < 3) return WordCategory.newWord;
    if (correctStreak >= 3) return WordCategory.wellLearned;
    return WordCategory.difficult;
  }

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
      'correctStreak': correctStreak,
      'reviewCount': reviewCount,
      'level': level,
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
      correctStreak: map['correctStreak'] as int? ?? 0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      level: map['level'] as String?,
    );
  }
}