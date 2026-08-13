import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/german_text.dart';
import '../models/word.dart';
import '../services/gemini_service.dart';
import 'settings_provider.dart';
import 'word_provider.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class AiWordState {
  final bool isLoading;
  final String? errorMessage;
  final bool needsApiKey;
  final Word? generatedWord;

  const AiWordState({
    this.isLoading = false,
    this.errorMessage,
    this.needsApiKey = false,
    this.generatedWord,
  });

  AiWordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? needsApiKey,
    Word? generatedWord,
  }) {
    return AiWordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      needsApiKey: needsApiKey ?? false,
      generatedWord: generatedWord ?? this.generatedWord,
    );
  }
}

class AiWordController extends Notifier<AiWordState> {
  @override
  AiWordState build() => const AiWordState();

  Future<void> generate(String germanWord, int workspaceId) async {
    final trimmed = germanWord.trim();
    if (trimmed.isEmpty) return;

    state = const AiWordState(isLoading: true);

    final apiKey = await ref.read(apiKeyServiceProvider).getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      state = const AiWordState(
        errorMessage: AppStrings.aiNoApiKeyError,
        needsApiKey: true,
      );
      return;
    }

    // Aynı akıştaki manuel eklemeyle aynı kural: aynı çalışma alanında tam
    // eşleşen kişisel kelime zaten varsa API'ye para/istek harcamadan önce
    // durdur. Goethe seed listeleri ayrı bir alan olduğu için buraya dahil
    // edilmez.
    final normalized = stripLeadingGermanArticle(trimmed).toLowerCase();
    final existingWords = await ref.read(databaseServiceProvider).getWords();
    final isDuplicate = existingWords.any(
      (w) =>
          w.level == null &&
          w.workspaceId == workspaceId &&
          w.word.trim().toLowerCase() == normalized,
    );
    if (isDuplicate) {
      state = const AiWordState(errorMessage: AppStrings.duplicateWordError);
      return;
    }

    try {
      final word = await ref
          .read(geminiServiceProvider)
          .generateWordDetails(trimmed, apiKey);
      state = AiWordState(generatedWord: word);
    } on GeminiApiException catch (e) {
      state = AiWordState(
        errorMessage:
            e.isInvalidKey ? AppStrings.aiInvalidKeyError : e.message,
        needsApiKey: e.isInvalidKey,
      );
    } catch (_) {
      state = const AiWordState(errorMessage: AppStrings.aiGenericError);
    }
  }

  void reset() => state = const AiWordState();
}

final aiWordControllerProvider =
    NotifierProvider<AiWordController, AiWordState>(AiWordController.new);
