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
  final int? workspaceId;            // kişisel kelimenin ait olduğu çalışma alanı (level null ise geçerli)
  final String? wordType;            // 'separableVerb'/'irregularVerb'/'regularVerb'/'conjunction', null = Kelimeler
  final String? conjugationJson;     // fiilse: {ich,du,er,wir,ihr,sieSie} JSON'u (bkz. VerbConjugation)
  final String? verbCase;            // fiilse nesne durumu: 'akkusativ'/'dativ'/'akkusativ+dativ'/'nominativ'
  final bool? sendsVerbToEnd;        // bağlaçsa: fiili cümle sonuna gönderiyor mu

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
    this.workspaceId,
    this.wordType,
    this.conjugationJson,
    this.verbCase,
    this.sendsVerbToEnd,
  });

  // Sadece belirtilen alanları değiştirerek yeni bir Word oluşturur
  Word copyWith({
    String? wordType,
    String? conjugationJson,
    String? verbCase,
    bool? sendsVerbToEnd,
  }) {
    return Word(
      id: id,
      article: article,
      word: word,
      meaningEn: meaningEn,
      meaningTr: meaningTr,
      plural: plural,
      exampleSentence: exampleSentence,
      exampleTranslationEn: exampleTranslationEn,
      exampleTranslationTr: exampleTranslationTr,
      correctStreak: correctStreak,
      reviewCount: reviewCount,
      level: level,
      workspaceId: workspaceId,
      wordType: wordType ?? this.wordType,
      conjugationJson: conjugationJson ?? this.conjugationJson,
      verbCase: verbCase ?? this.verbCase,
      sendsVerbToEnd: sendsVerbToEnd ?? this.sendsVerbToEnd,
    );
  }

  // Kaç kez tekrar edildiğine ve ardışık doğru sayısına göre kategori
  WordCategory get category {
    // Hiç tekrar edilmemiş (henüz test edilmemiş) kelime "yeni" kalır;
    // sırf yeni eklendi diye zorlanılan listesine düşmesin.
    if (reviewCount == 0) return WordCategory.newWord;
    if (correctStreak >= 3) return WordCategory.wellLearned;
    // Tek bir yanlış cevap bile (correctStreak sıfırlanır) kelimeyi anında
    // zorlanılan listesine taşır — daha önce 7 kere üst üste bilinmiş bir
    // kelime bile ilk yanlışta hemen buraya düşer, kullanıcı hatasını
    // gizlemeden direkt görsün.
    if (correctStreak == 0) return WordCategory.difficult;
    return WordCategory.newWord;
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
      'workspaceId': workspaceId,
      'wordType': wordType,
      'conjugationJson': conjugationJson,
      'verbCase': verbCase,
      'sendsVerbToEnd': sendsVerbToEnd == null ? null : (sendsVerbToEnd! ? 1 : 0),
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
      workspaceId: map['workspaceId'] as int?,
      wordType: map['wordType'] as String?,
      conjugationJson: map['conjugationJson'] as String?,
      verbCase: map['verbCase'] as String?,
      sendsVerbToEnd: map['sendsVerbToEnd'] == null ? null : (map['sendsVerbToEnd'] as int) == 1,
    );
  }
}