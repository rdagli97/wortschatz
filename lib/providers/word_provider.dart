import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
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
// veritabanına yükler. HomeScreen tarafından tetiklenir.
final goetheSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final inserted = await db.insertWordsIfAbsent(goetheA1Words());
  if (inserted > 0) {
    ref.invalidate(wordsProvider);
  }
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
      // farklı kelimeleri birbirine karıştırmaz. Sadece kişisel kelimelerle
      // kıyaslanır; Goethe seed listeleri ayrı bir alan olduğu için burada
      // "zaten var" saymaz.
      final isDuplicate = existingWords.any(
        (w) =>
            w.level == null &&
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