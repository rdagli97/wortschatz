import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../models/topic.dart';
import '../services/gemini_service.dart';
import 'ai_word_provider.dart';
import 'settings_provider.dart';
import 'word_provider.dart';

// Kaydedilmiş konu anlatımlarını getiren FutureProvider
final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  return ref.watch(databaseServiceProvider).getTopics();
});

class TopicListController {
  final Ref ref;
  const TopicListController(this.ref);

  Future<void> deleteTopic(int id) async {
    await ref.read(databaseServiceProvider).deleteTopic(id);
    ref.invalidate(topicsProvider);
  }
}

final topicListControllerProvider =
    Provider<TopicListController>(TopicListController.new);

class AskAiState {
  final bool isLoading;
  final String? errorMessage;
  final bool needsApiKey;
  final Topic? lastTopic;

  const AskAiState({
    this.isLoading = false,
    this.errorMessage,
    this.needsApiKey = false,
    this.lastTopic,
  });
}

class AskAiController extends Notifier<AskAiState> {
  @override
  AskAiState build() => const AskAiState();

  Future<Topic?> ask(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return null;

    state = const AskAiState(isLoading: true);

    final apiKey = await ref.read(apiKeyServiceProvider).getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      state = const AskAiState(
        errorMessage: AppStrings.aiNoApiKeyError,
        needsApiKey: true,
      );
      return null;
    }

    try {
      final explanation =
          await ref.read(geminiServiceProvider).explainTopic(trimmed, apiKey);
      final topic = Topic(
        keyword: trimmed,
        explanation: explanation,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await ref.read(databaseServiceProvider).insertTopic(topic);
      ref.invalidate(topicsProvider);
      state = AskAiState(lastTopic: topic);
      return topic;
    } on GeminiApiException catch (e) {
      state = AskAiState(
        errorMessage: e.isInvalidKey ? AppStrings.aiInvalidKeyError : e.message,
        needsApiKey: e.isInvalidKey,
      );
      return null;
    } catch (_) {
      state = const AskAiState(errorMessage: AppStrings.askAiGenericError);
      return null;
    }
  }
}

final askAiControllerProvider =
    NotifierProvider<AskAiController, AskAiState>(AskAiController.new);
