import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';

class DatabaseService {
  static Database? _database;

  // Veritabanına erişim (yoksa oluştur)
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'wortschatz.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE words(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            article TEXT NOT NULL,
            word TEXT NOT NULL,
            meaningEn TEXT NOT NULL,
            meaningTr TEXT NOT NULL,
            plural TEXT NOT NULL,
            exampleSentence TEXT NOT NULL,
            exampleTranslationEn TEXT NOT NULL,
            exampleTranslationTr TEXT NOT NULL,
            correctStreak INTEGER NOT NULL DEFAULT 0,
            reviewCount INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Başlangıç kelimeleri (Goethe A1'den seçme)
        final seedWords = _seedWords();
        for (final word in seedWords) {
          await db.insert('words', word.toMap());
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE words ADD COLUMN correctStreak INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE words ADD COLUMN reviewCount INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  // CREATE - kelime ekle
  Future<int> insertWord(Word word) async {
    final db = await _db;
    return await db.insert('words', word.toMap());
  }

  // READ - tüm kelimeleri getir (en yeni üstte)
  Future<List<Word>> getWords() async {
    final db = await _db;
    final maps = await db.query('words', orderBy: 'id DESC');
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  // DELETE - kelime sil
  Future<int> deleteWord(int id) async {
    final db = await _db;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  // UPDATE - tekrar sonucunu işle (doğru: streak +1, yanlış: streak 0'a döner)
  Future<void> recordAnswer(int id, bool correct) async {
    final db = await _db;
    if (correct) {
      await db.rawUpdate(
        'UPDATE words SET reviewCount = reviewCount + 1, correctStreak = correctStreak + 1 WHERE id = ?',
        [id],
      );
    } else {
      await db.rawUpdate(
        'UPDATE words SET reviewCount = reviewCount + 1, correctStreak = 0 WHERE id = ?',
        [id],
      );
    }
  }

  // İlk açılışta yüklenecek başlangıç kelimeleri
  List<Word> _seedWords() {
    return const [
      Word(
        article: 'das',
        word: 'Haus',
        meaningEn: 'house',
        meaningTr: 'ev',
        plural: 'Häuser',
        exampleSentence: 'Das Haus ist groß.',
        exampleTranslationEn: 'The house is big.',
        exampleTranslationTr: 'Ev büyük.',
      ),
      Word(
        article: 'der',
        word: 'Tisch',
        meaningEn: 'table',
        meaningTr: 'masa',
        plural: 'Tische',
        exampleSentence: 'Die Fotos liegen auf dem Tisch.',
        exampleTranslationEn: 'The photos are on the table.',
        exampleTranslationTr: 'Fotoğraflar masanın üstünde.',
      ),
      Word(
        article: 'die',
        word: 'Frau',
        meaningEn: 'woman',
        meaningTr: 'kadın',
        plural: 'Frauen',
        exampleSentence: 'Das ist Frau Becker.',
        exampleTranslationEn: 'This is Mrs. Becker.',
        exampleTranslationTr: 'Bu Bayan Becker.',
      ),
      Word(
        article: 'der',
        word: 'Zug',
        meaningEn: 'train',
        meaningTr: 'tren',
        plural: 'Züge',
        exampleSentence: 'Ich fahre gern mit dem Zug.',
        exampleTranslationEn: 'I like traveling by train.',
        exampleTranslationTr: 'Trenle seyahat etmeyi severim.',
      ),
      Word(
        article: 'die',
        word: 'Stadt',
        meaningEn: 'city',
        meaningTr: 'şehir',
        plural: 'Städte',
        exampleSentence: 'Heidelberg ist eine alte Stadt.',
        exampleTranslationEn: 'Heidelberg is an old city.',
        exampleTranslationTr: 'Heidelberg eski bir şehir.',
      ),
      Word(
        article: 'das',
        word: 'Buch',
        meaningEn: 'book',
        meaningTr: 'kitap',
        plural: 'Bücher',
        exampleSentence: 'Gute Bücher sind oft teuer.',
        exampleTranslationEn: 'Good books are often expensive.',
        exampleTranslationTr: 'İyi kitaplar genelde pahalıdır.',
      ),
    ];
  }
}
