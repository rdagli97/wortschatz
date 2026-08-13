import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home_menu_button.dart';
import 'goethe_screen.dart';
import 'word_categories_screen.dart';

class WordsHubScreen extends StatelessWidget {
  const WordsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.words)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            HomeMenuButton(
              label: AppStrings.myWorkspace,
              subtitle: AppStrings.myWorkspaceDesc,
              icon: Icons.person_outline,
              accentColor: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordCategoriesScreen()),
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
          ],
        ),
      ),
    );
  }
}
