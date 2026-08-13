import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants/app_strings.dart';
import '../models/story.dart';
import '../models/topic.dart';
import '../models/word.dart';
import '../models/workspace.dart';

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
      version: 7,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workspaces(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            isDefault INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE topics(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keyword TEXT NOT NULL,
            explanation TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE stories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            level TEXT NOT NULL,
            topic TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');
        final defaultWorkspaceId = await db.insert('workspaces', {
          'name': AppStrings.defaultWorkspaceName,
          'isDefault': 1,
        });

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
            reviewCount INTEGER NOT NULL DEFAULT 0,
            level TEXT,
            workspaceId INTEGER,
            wordType TEXT
          )
        ''');

        // Başlangıç kelimeleri (varsayılan çalışma alanına ait)
        final seedWords = _seedWords();
        for (final word in seedWords) {
          final map = word.toMap()..['workspaceId'] = defaultWorkspaceId;
          await db.insert('words', map);
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
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE words ADD COLUMN level TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE words ADD COLUMN workspaceId INTEGER');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS workspaces(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              isDefault INTEGER NOT NULL DEFAULT 0
            )
          ''');
          // Var olan kişisel kelimeler (level yok, henüz çalışma alanı da yok)
          // yeni oluşturulan varsayılan çalışma alanına taşınır.
          final defaultWorkspaceId = await db.insert('workspaces', {
            'name': AppStrings.defaultWorkspaceName,
            'isDefault': 1,
          });
          await db.update(
            'words',
            {'workspaceId': defaultWorkspaceId},
            where: 'level IS NULL AND workspaceId IS NULL',
          );
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE words ADD COLUMN wordType TEXT');
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS topics(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              keyword TEXT NOT NULL,
              explanation TEXT NOT NULL,
              createdAt INTEGER NOT NULL
            )
          ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS stories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              level TEXT NOT NULL,
              topic TEXT NOT NULL,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              createdAt INTEGER NOT NULL
            )
          ''');
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

  // READ - tüm çalışma alanlarını getir (varsayılan en üstte)
  Future<List<Workspace>> getWorkspaces() async {
    final db = await _db;
    final maps = await db.query('workspaces', orderBy: 'isDefault DESC, id ASC');
    return maps.map((map) => Workspace.fromMap(map)).toList();
  }

  // CREATE - yeni, boş bir çalışma alanı oluştur
  Future<int> createWorkspace(String name) async {
    final db = await _db;
    return await db.insert('workspaces', {'name': name, 'isDefault': 0});
  }

  // DELETE - çalışma alanını ve içindeki tüm kelimeleri sil
  Future<void> deleteWorkspace(int id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('words', where: 'workspaceId = ?', whereArgs: [id]);
      await txn.delete('workspaces', where: 'id = ?', whereArgs: [id]);
    });
  }

  // SEED - Goethe listelerini yükler; aynı seviyede aynı kelime zaten varsa
  // atlar (seeder birden fazla kez çalıştırılsa da kelimeler çoğalmaz).
  // Eşleştirme büyük/küçük harfe duyarlıdır: "Essen" (isim) ile "essen"
  // (fiil) gibi eş sesli kelimeler birbirine karışmaz. Daha önce eklenmiş
  // ama wordType'ı yanlış ya da boş kalmış kelimeler varsa (örn. kelime türü
  // sınıflandırması sonradan eklendiyse/düzeltildiyse) bu alan geriye dönük
  // olarak güncellenir.
  Future<int> insertWordsIfAbsent(List<Word> words) async {
    final db = await _db;
    final existing = await db.query('words', columns: ['id', 'word', 'level', 'wordType']);
    final existingByKey = {
      for (final row in existing)
        '${(row['word'] as String).trim()}|${row['level'] as String? ?? ''}': row,
    };

    var inserted = 0;
    final batch = db.batch();
    for (final word in words) {
      final key = '${word.word.trim()}|${word.level ?? ''}';
      final existingRow = existingByKey[key];
      if (existingRow == null) {
        batch.insert('words', word.toMap());
        inserted++;
      } else if (existingRow['wordType'] != word.wordType) {
        batch.update(
          'words',
          {'wordType': word.wordType},
          where: 'id = ?',
          whereArgs: [existingRow['id']],
        );
      }
    }
    await batch.commit(noResult: true);
    return inserted;
  }

  // SEED - bir çalışma alanına, orada aynı isimde kelime yoksa ekler
  // (büyük/küçük harfe duyarlı eşleştirme, ör. "Essen"/"essen" karışmasın).
  Future<int> insertWordsIfAbsentForWorkspace(int workspaceId, List<Word> words) async {
    final db = await _db;
    final existing = await db.query(
      'words',
      columns: ['word'],
      where: 'workspaceId = ? AND level IS NULL',
      whereArgs: [workspaceId],
    );
    final existingWords = existing.map((row) => (row['word'] as String).trim()).toSet();

    var inserted = 0;
    final batch = db.batch();
    for (final word in words) {
      final key = word.word.trim();
      if (existingWords.contains(key)) continue;
      existingWords.add(key);
      batch.insert('words', word.toMap());
      inserted++;
    }
    await batch.commit(noResult: true);
    return inserted;
  }

  // CREATE - "Merak Ettiğini Sor" ile üretilen konu anlatımını kaydet
  Future<int> insertTopic(Topic topic) async {
    final db = await _db;
    return await db.insert('topics', topic.toMap());
  }

  // READ - kaydedilmiş konu anlatımlarını getir (en yeni üstte)
  Future<List<Topic>> getTopics() async {
    final db = await _db;
    final maps = await db.query('topics', orderBy: 'createdAt DESC');
    return maps.map((map) => Topic.fromMap(map)).toList();
  }

  // DELETE - kaydedilmiş bir konu anlatımını sil
  Future<int> deleteTopic(int id) async {
    final db = await _db;
    return await db.delete('topics', where: 'id = ?', whereArgs: [id]);
  }

  // CREATE - "Hikaye Oku" ile üretilen hikayeyi kaydet
  Future<int> insertStory(Story story) async {
    final db = await _db;
    return await db.insert('stories', story.toMap());
  }

  // READ - kaydedilmiş hikayeleri getir (en yeni üstte)
  Future<List<Story>> getStories() async {
    final db = await _db;
    final maps = await db.query('stories', orderBy: 'createdAt DESC');
    return maps.map((map) => Story.fromMap(map)).toList();
  }

  // DELETE - kaydedilmiş bir hikayeyi sil
  Future<int> deleteStory(int id) async {
    final db = await _db;
    return await db.delete('stories', where: 'id = ?', whereArgs: [id]);
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
