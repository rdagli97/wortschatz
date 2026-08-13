import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../models/story.dart';
import '../services/gemini_service.dart';
import 'ai_word_provider.dart';
import 'settings_provider.dart';
import 'word_provider.dart';

// Kaydedilmiş hikayeleri getiren FutureProvider
final storiesProvider = FutureProvider<List<Story>>((ref) async {
  return ref.watch(databaseServiceProvider).getStories();
});

class StoryListController {
  final Ref ref;
  const StoryListController(this.ref);

  Future<void> deleteStory(int id) async {
    await ref.read(databaseServiceProvider).deleteStory(id);
    ref.invalidate(storiesProvider);
  }
}

final storyListControllerProvider =
    Provider<StoryListController>(StoryListController.new);

class GenerateStoryState {
  final bool isLoading;
  final String? errorMessage;
  final bool needsApiKey;
  final Story? lastStory;

  const GenerateStoryState({
    this.isLoading = false,
    this.errorMessage,
    this.needsApiKey = false,
    this.lastStory,
  });
}

class GenerateStoryController extends Notifier<GenerateStoryState> {
  @override
  GenerateStoryState build() => const GenerateStoryState();

  Future<Story?> generate(String level, String topic) async {
    state = const GenerateStoryState(isLoading: true);

    final apiKey = await ref.read(apiKeyServiceProvider).getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      state = const GenerateStoryState(
        errorMessage: AppStrings.aiNoApiKeyError,
        needsApiKey: true,
      );
      return null;
    }

    try {
      final generated =
          await ref.read(geminiServiceProvider).generateStory(level, topic, apiKey);
      final story = Story(
        level: level,
        topic: topic.trim(),
        title: generated.title,
        content: generated.content,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await ref.read(databaseServiceProvider).insertStory(story);
      ref.invalidate(storiesProvider);
      state = GenerateStoryState(lastStory: story);
      return story;
    } on GeminiApiException catch (e) {
      state = GenerateStoryState(
        errorMessage: e.isInvalidKey ? AppStrings.aiInvalidKeyError : e.message,
        needsApiKey: e.isInvalidKey,
      );
      return null;
    } catch (_) {
      state = const GenerateStoryState(errorMessage: AppStrings.aiGenericError);
      return null;
    }
  }
}

final generateStoryControllerProvider =
    NotifierProvider<GenerateStoryController, GenerateStoryState>(
        GenerateStoryController.new);
