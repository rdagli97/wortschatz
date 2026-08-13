import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';
import '../widgets/wort_text_field.dart';
import 'settings_screen.dart';
import 'story_detail_screen.dart';

class StoryGenerateScreen extends ConsumerStatefulWidget {
  final String level;

  const StoryGenerateScreen({super.key, required this.level});

  @override
  ConsumerState<StoryGenerateScreen> createState() => _StoryGenerateScreenState();
}

class _StoryGenerateScreenState extends ConsumerState<StoryGenerateScreen> {
  final _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final story = await ref
        .read(generateStoryControllerProvider.notifier)
        .generate(widget.level, _topicController.text);
    if (story != null && mounted) {
      _topicController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generateStoryControllerProvider);
    final storiesAsync = ref.watch(storiesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('${AppStrings.storyRead} · ${widget.level}')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WortTextField(
              controller: _topicController,
              label: AppStrings.storyTopicInputLabel,
            ),
            const SizedBox(height: AppSizes.md),
            ElevatedButton(
              onPressed: state.isLoading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: AppSizes.iconSm,
                      height: AppSizes.iconSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppStrings.storyGenerateButton,
                      style: AppTextStyles.title.copyWith(color: Colors.white)),
            ),
            if (state.isLoading) ...[
              const SizedBox(height: AppSizes.sm),
              Text(AppStrings.storyGenerating, style: AppTextStyles.caption),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSizes.md),
              Text(
                state.errorMessage!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
              if (state.needsApiKey) ...[
                const SizedBox(height: AppSizes.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Text(AppStrings.goToSettings,
                        style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSizes.lg),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppSizes.sm),
            Text(AppStrings.storyHistoryTitle, style: AppTextStyles.title),
            const SizedBox(height: AppSizes.sm),
            Expanded(
              child: storiesAsync.when(
                data: (stories) {
                  final levelStories =
                      stories.where((s) => s.level == widget.level).toList();
                  if (levelStories.isEmpty) {
                    return Center(
                      child: Text(AppStrings.storyEmptyHistory,
                          style: AppTextStyles.caption, textAlign: TextAlign.center),
                    );
                  }
                  return ListView.builder(
                    itemCount: levelStories.length,
                    itemBuilder: (context, index) => _StoryTile(story: levelStories[index]),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(child: Text('Hata: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryTile extends ConsumerWidget {
  final Story story;

  const _StoryTile({required this.story});

  String get _formattedDate {
    final date = DateTime.fromMillisecondsSinceEpoch(story.createdAt);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title, style: AppTextStyles.title),
                  if (story.topic.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(story.topic, style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: AppSizes.xs),
                  Text(_formattedDate,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
              onPressed: () =>
                  ref.read(storyListControllerProvider).deleteStory(story.id!),
            ),
          ],
        ),
      ),
    );
  }
}
