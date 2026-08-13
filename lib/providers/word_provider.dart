import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../data/goethe_a1_word_types.dart';
import '../data/goethe_a1_words.dart';
import '../models/word.dart';
import '../services/database_service.dart';

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
// fiiller/bağlaçlar ayrımı için wordType ile etiketlenir. İsimler (article
// dolu) hiçbir zaman fiil/bağlaç olarak etiketlenmez — "das Essen" (yemek)
// ile "essen" (yemek yemek) fiili gibi eş sesli kelimeleri karıştırmaz.
// HomeScreen tarafından tetiklenir.
final goetheSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final classifiedWords = goetheA1Words()
      .map((w) => w.copyWith(
            wordType: w.article.isEmpty ? classifyGoetheWordType(w.word) : null,
          ))
      .toList();
  await db.insertWordsIfAbsent(classifiedWords);
  ref.invalidate(wordsProvider);
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

      await db.insertWord(word);
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