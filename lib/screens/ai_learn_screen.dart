import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home_menu_button.dart';
import 'ask_ai_screen.dart';
import 'story_level_screen.dart';

// "AI ile Öğren" altındaki özellikler.
class AiLearnScreen extends StatelessWidget {
  const AiLearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aiLearn)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            HomeMenuButton(
              label: AppStrings.askAiTitle,
              subtitle: AppStrings.askAiDesc,
              icon: Icons.psychology_outlined,
              accentColor: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AskAiScreen()),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.storyRead,
              subtitle: AppStrings.storyReadDesc,
              icon: Icons.auto_stories_outlined,
              accentColor: AppColors.das,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoryLevelScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
