import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/topic.dart';
import '../providers/topic_provider.dart';
import '../widgets/wort_text_field.dart';
import 'settings_screen.dart';
import 'topic_detail_screen.dart';

class AskAiScreen extends ConsumerStatefulWidget {
  const AskAiScreen({super.key});

  @override
  ConsumerState<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen> {
  final _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final topic =
        await ref.read(askAiControllerProvider.notifier).ask(_keywordController.text);
    if (topic != null && mounted) {
      _keywordController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(askAiControllerProvider);
    final topicsAsync = ref.watch(topicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.askAiTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WortTextField(
              controller: _keywordController,
              label: AppStrings.askAiInputLabel,
            ),
            const SizedBox(height: AppSizes.md),
            ElevatedButton(
              onPressed: state.isLoading ? null : _ask,
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
                  : Text(AppStrings.askAiButton,
                      style: AppTextStyles.title.copyWith(color: Colors.white)),
            ),
            if (state.isLoading) ...[
              const SizedBox(height: AppSizes.sm),
              Text(AppStrings.askAiGenerating, style: AppTextStyles.caption),
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
            Text(AppStrings.askAiHistoryTitle, style: AppTextStyles.title),
            const SizedBox(height: AppSizes.sm),
            Expanded(
              child: topicsAsync.when(
                data: (topics) {
                  if (topics.isEmpty) {
                    return Center(
                      child: Text(AppStrings.askAiEmptyHistory,
                          style: AppTextStyles.caption, textAlign: TextAlign.center),
                    );
                  }
                  return ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) => _TopicTile(topic: topics[index]),
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

class _TopicTile extends StatelessWidget {
  final Topic topic;

  const _TopicTile({required this.topic});

  String get _formattedDate {
    final date = DateTime.fromMillisecondsSinceEpoch(topic.createdAt);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  // Önizleme için markdown işaretlerini (#, *, -, |, `) temizler
  String get _plainPreview {
    return topic.explanation
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'[*_`]'), '')
        .replaceAll(RegExp(r'^[-|]\s*', multiLine: true), '')
        .replaceAll('\n', ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
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
                  Text(topic.keyword, style: AppTextStyles.title),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    _plainPreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(_formattedDate,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
