import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/word_provider.dart';
import '../widgets/home_menu_button.dart';
import 'ai_learn_screen.dart';
import 'goethe_screen.dart';
import 'settings_screen.dart';
import 'word_type_menu_screen.dart';
import 'workspaces_screen.dart';

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
              label: AppStrings.myWorkspace,
              subtitle: AppStrings.myWorkspaceDesc,
              icon: Icons.person_outline,
              accentColor: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WordTypeMenuScreen(
                    title: AppStrings.myWorkspace,
                    wordsDestination: WorkspacesScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.goethe,
              subtitle: AppStrings.goetheDesc,
              icon: Icons.school_outlined,
              accentColor: AppColors.das,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoetheScreen()),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.aiLearn,
              subtitle: AppStrings.aiLearnDesc,
              icon: Icons.auto_awesome,
              accentColor: AppColors.die,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiLearnScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
