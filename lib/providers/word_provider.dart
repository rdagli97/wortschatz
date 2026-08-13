import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../data/goethe_a1_conjugations.dart';
import '../data/goethe_a1_verb_cases.dart';
import '../data/goethe_a1_word_types.dart';
import '../data/goethe_a1_words.dart';
import '../models/word.dart';
import '../services/database_service.dart';

// Bir kelime için wordType/çekim/nesne durumu/fiil sırası bilgisini,
// classifyGoetheWordType'ın tanıdığı ~157 kelimelik doğrulanmış listeye göre
// hesaplayıp ekler; bu liste elle doğrulandığı için AI'ın döndürdüğü
// (varsa) değerlerin önüne geçer. Listede olmayan kelimeler (AI'ın kendi
// belirlediği wordType/çekim/nesne durumu ile) değişmeden kalır. İsimler
// hiçbir zaman dokunulmaz.
Word withGoetheGrammar(Word w) {
  if (w.article.isNotEmpty) return w;
  final type = classifyGoetheWordType(w.word);
  if (type == null) return w;
  if (type == 'conjunction') {
    return w.copyWith(wordType: type, sendsVerbToEnd: conjunctionSendsVerbToEnd(w.word));
  }
  final conjugation = conjugatePresentTense(w.word, type);
  return w.copyWith(
    wordType: type,
    conjugationJson: conjugation?.toJson(),
    verbCase: verbCase(w.word, type),
  );
}

// Varsayılan çalışma alanına örnek olarak eklenen düzenli/düzensiz/ayrılabilir
// fiiller ile bağlaçlar — Goethe A1 verisinden, zaten dilbilgisi olarak
// doğrulanmış (çekim/nesne durumu/fiil sırası bilgisi hazır) bir alt küme.
const _defaultWorkspaceSeedWordNames = {
  // Düzenli fiiller
  'machen', 'spielen', 'kaufen', 'kochen', 'arbeiten', 'wohnen', 'suchen', 'lernen',
  // Düzensiz fiiller
  'gehen', 'kommen', 'sehen', 'essen', 'trinken', 'sprechen', 'haben', 'sein',
  // Ayrılabilir fiiller
  'aufstehen', 'einkaufen', 'anrufen', 'fernsehen', 'ankommen', 'aufhören',
  // Bağlaçlar
  'und', 'oder', 'aber', 'denn',
};

// DatabaseService'e erişim
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Tüm kelimeleri getiren FutureProvider (liste ekranının kaynağı)
final wordsProvider = FutureProvider<List<Word>>((ref) async {
  return ref.watch(databaseServiceProvider).getWords();
});

// Goethe A1 listesini bir kere (uygulama her açılışında, tekrarsız olarak)
// veritabanına yükler. Her kelime, kelimeler/ayrılabilir-düzenli-düzensiz
// fiiller/bağlaçlar ayrımı için wordType (ve fiil/bağlaçsa çekim/nesne
// durumu/fiil sırası bilgisiyle) etiketlenir. İsimler (article dolu) hiçbir
// zaman fiil/bağlaç olarak etiketlenmez — "das Essen" (yemek) ile "essen"
// (yemek yemek) fiili gibi eş sesli kelimeleri karıştırmaz. HomeScreen
// tarafından tetiklenir.
final goetheSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final classifiedWords = goetheA1Words().map(withGoetheGrammar).toList();
  await db.insertWordsIfAbsent(classifiedWords);
  ref.invalidate(wordsProvider);
});

// Varsayılan çalışma alanına, "Düzenli/Düzensiz/Ayrılabilir Fiiller" ve
// "Bağlaçlar" bölümlerinin boş görünmemesi için örnek kelimeler ekler.
// Kullanıcı bunları silebilir; sadece daha önce eklenmemişse eklenir.
// HomeScreen tarafından tetiklenir.
final defaultWorkspaceSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final workspaces = await db.getWorkspaces();
  final workspaceId = workspaces
      .where((w) => w.isDefault)
      .map((w) => w.id)
      .whereType<int>()
      .firstOrNull;
  if (workspaceId == null) return;

  final seedWords = goetheA1Words()
      .where((w) => _defaultWorkspaceSeedWordNames.contains(w.word.toLowerCase()))
      .map((w) => withGoetheGrammar(Word(
            article: w.article,
            word: w.word,
            meaningEn: w.meaningEn,
            meaningTr: w.meaningTr,
            plural: w.plural,
            exampleSentence: w.exampleSentence,
            exampleTranslationEn: w.exampleTranslationEn,
            exampleTranslationTr: w.exampleTranslationTr,
            workspaceId: workspaceId,
          )))
      .toList();

  final inserted = await db.insertWordsIfAbsentForWorkspace(workspaceId, seedWords);
  if (inserted > 0) ref.invalidate(wordsProvider);
});

// Kelime ekleme işleminin durumu
class AddWordState {
  final bool isSaving;
  final String? errorMessage;

  const AddWordState({this.isSaving = false, this.errorMessage});

  AddWordState copyWith({bool? isSaving, String? errorMessage}) {
    return AddWordState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class AddWordController extends Notifier<AddWordState> {
  @override
  AddWordState build() => const AddWordState();

  Future<bool> addWord(Word word) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final db = ref.read(databaseServiceProvider);
      final existingWords = await db.getWords();
      // tam eşleşme (kelime metni birebir aynı) — "Zeit" ile "Hochzeit" gibi
      // farklı kelimeleri birbirine karıştırmaz. Sadece aynı çalışma alanındaki
      // kişisel kelimelerle kıyaslanır; başka bir çalışma alanında veya Goethe
      // seed listelerinde aynı kelime olması "zaten var" saymaz.
      final isDuplicate = existingWords.any(
        (w) =>
            w.level == null &&
            w.workspaceId == word.workspaceId &&
            w.word.trim().toLowerCase() == word.word.trim().toLowerCase(),
      );
      if (isDuplicate) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: AppStrings.duplicateWordError,
        );
        return false;
      }

      // Artikeli olmayan (AI ile eklenmiş) kelime bilinen bir fiil/bağlaçsa
      // doğrulanmış wordType/çekim/nesne durumu bilgisiyle etiketlenir;
      // bilinmiyorsa AI'ın kendi belirlediği bilgiler (varsa) korunur.
      final classified = word.article.isEmpty ? withGoetheGrammar(word) : word;

      await db.insertWord(classified);
      // Kelime listesini yenile (yeni kelime görünsün)
      ref.invalidate(wordsProvider);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Kelime kaydedilemedi');
      return false;
    }
  }

  Future<void> deleteWord(int id) async {
    await ref.read(databaseServiceProvider).deleteWord(id);
    ref.invalidate(wordsProvider);
  }
}

final addWordControllerProvider =
    NotifierProvider<AddWordController, AddWordState>(AddWordController.new);