import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home_menu_button.dart';
import 'story_generate_screen.dart';

// "Hikaye Oku" altındaki seviye seçimi: A1, A2, B1 ve tüm seviyelerin
// karıştığı doğal "Karma" modu için hikaye üretimi var.
class StoryLevelScreen extends StatelessWidget {
  const StoryLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.storyRead)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            HomeMenuButton(
              label: AppStrings.goetheA1,
              icon: Icons.auto_stories_outlined,
              accentColor: AppColors.das,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StoryGenerateScreen(level: 'A1'),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.goetheA2,
              icon: Icons.auto_stories_outlined,
              accentColor: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StoryGenerateScreen(level: 'A2'),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.goetheB1,
              icon: Icons.auto_stories_outlined,
              accentColor: AppColors.die,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StoryGenerateScreen(level: 'B1'),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppSizes.lg),
            HomeMenuButton(
              label: AppStrings.storyMixedLevel,
              subtitle: AppStrings.storyMixedLevelDesc,
              icon: Icons.auto_awesome,
              accentColor: AppColors.primaryDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StoryGenerateScreen(level: 'Karma'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
