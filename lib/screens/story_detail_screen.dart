import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';

class StoryDetailScreen extends ConsumerWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentences =
        story.content.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(story.level),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(storyListControllerProvider).deleteStory(story.id!);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                story.title,
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              const Divider(color: AppColors.divider),
              const SizedBox(height: AppSizes.lg),
              for (final sentence in sentences) ...[
                Text(
                  sentence,
                  style: AppTextStyles.body.copyWith(fontSize: 17, height: 1.8),
                ),
                const SizedBox(height: AppSizes.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
