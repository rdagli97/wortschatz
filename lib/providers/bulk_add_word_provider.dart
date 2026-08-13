import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/german_text.dart';
import '../data/goethe_a1_word_types.dart';
import '../models/word.dart';
import '../services/gemini_service.dart';
import 'ai_word_provider.dart';
import 'settings_provider.dart';
import 'word_provider.dart';

enum BulkWordStatus { pending, checking, added, duplicate, error }

class BulkWordResult {
  final String word;
  final BulkWordStatus status;
  final String? errorMessage;

  const BulkWordResult({
    required this.word,
    this.status = BulkWordStatus.pending,
    this.errorMessage,
  });

  BulkWordResult copyWith({BulkWordStatus? status, String? errorMessage}) {
    return BulkWordResult(
      word: word,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class BulkAddState {
  final bool isProcessing;
  final List<BulkWordResult> results;
  final String? blockingError;
  final bool needsApiKey;

  const BulkAddState({
    this.isProcessing = false,
    this.results = const [],
    this.blockingError,
    this.needsApiKey = false,
  });

  int get addedCount => results.where((r) => r.status == BulkWordStatus.added).length;
  int get processedCount => results
      .where((r) => r.status != BulkWordStatus.pending && r.status != BulkWordStatus.checking)
      .length;
  bool get isFinished => !isProcessing && results.isNotEmpty && blockingError == null;
}

class BulkAddWordController extends Notifier<BulkAddState> {
  @override
  BulkAddState build() => const BulkAddState();

  void _setResult(int index, BulkWordResult result) {
    final updated = [...state.results];
    updated[index] = result;
    state = BulkAddState(isProcessing: state.isProcessing, results: updated);
  }

  Future<void> addWords(List<String> words, int workspaceId) async {
    state = BulkAddState(
      isProcessing: true,
      results: words.map((w) => BulkWordResult(word: w)).toList(),
    );

    final apiKey = await ref.read(apiKeyServiceProvider).getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      state = const BulkAddState(
        blockingError: AppStrings.aiNoApiKeyError,
        needsApiKey: true,
      );
      return;
    }

    final db = ref.read(databaseServiceProvider);
    final existingWords = await db.getWords();
    final addedInBatch = <String>{};

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      _setResult(i, BulkWordResult(word: word, status: BulkWordStatus.checking));

      final normalized = stripLeadingGermanArticle(word).toLowerCase();
      final isDuplicate = addedInBatch.contains(normalized) ||
          existingWords.any(
            (w) =>
                w.level == null &&
                w.workspaceId == workspaceId &&
                w.word.trim().toLowerCase() == normalized,
          );
      if (isDuplicate) {
        _setResult(i, BulkWordResult(word: word, status: BulkWordStatus.duplicate));
        continue;
      }

      try {
        final generated =
            await ref.read(geminiServiceProvider).generateWordDetails(word, apiKey);
        await db.insertWord(Word(
          article: generated.article,
          word: generated.word,
          meaningEn: generated.meaningEn,
          meaningTr: generated.meaningTr,
          plural: generated.plural,
          exampleSentence: generated.exampleSentence,
          exampleTranslationEn: generated.exampleTranslationEn,
          exampleTranslationTr: generated.exampleTranslationTr,
          workspaceId: workspaceId,
          wordType: generated.article.isEmpty
              ? classifyGoetheWordType(generated.word)
              : null,
        ));
        addedInBatch.add(normalized);
        _setResult(i, BulkWordResult(word: word, status: BulkWordStatus.added));
      } on GeminiApiException catch (e) {
        _setResult(
          i,
          BulkWordResult(
            word: word,
            status: BulkWordStatus.error,
            errorMessage: e.isInvalidKey ? AppStrings.aiInvalidKeyError : e.message,
          ),
        );
        // Anahtar geçersizse kalan kelimeler de aynı hatayı alacağı için
        // gereksiz istek atmadan burada durur.
        if (e.isInvalidKey) {
          for (var j = i + 1; j < words.length; j++) {
            _setResult(
              j,
              BulkWordResult(
                word: words[j],
                status: BulkWordStatus.error,
                errorMessage: AppStrings.aiInvalidKeyError,
              ),
            );
          }
          break;
        }
      } catch (_) {
        _setResult(
          i,
          BulkWordResult(
            word: word,
            status: BulkWordStatus.error,
            errorMessage: AppStrings.aiGenericError,
          ),
        );
      }
    }

    if (state.addedCount > 0) {
      ref.invalidate(wordsProvider);
    }
    state = BulkAddState(isProcessing: false, results: state.results);
  }
}

final bulkAddWordControllerProvider =
    NotifierProvider<BulkAddWordController, BulkAddState>(BulkAddWordController.new);
