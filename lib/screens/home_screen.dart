import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/word_provider.dart';
import '../widgets/home_menu_button.dart';
import 'settings_screen.dart';
import 'words_hub_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Goethe A1 listesini bir kere, tekrarsız olarak veritabanına yükler.
    ref.watch(goetheSeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text('Was möchtest du lernen?', style: AppTextStyles.heading),
            const SizedBox(height: AppSizes.xl),
            HomeMenuButton(
              label: AppStrings.words,
              icon: Icons.style,
              accentColor: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordsHubScreen()),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.regularVerbs,
              icon: Icons.repeat,
              accentColor: AppColors.der,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.irregularVerbs,
              icon: Icons.shuffle,
              accentColor: AppColors.die,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.conjunctions,
              icon: Icons.link,
              accentColor: AppColors.das,
              enabled: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}