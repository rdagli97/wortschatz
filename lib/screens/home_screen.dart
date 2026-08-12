import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/home_menu_button.dart';
import 'word_categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
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
                MaterialPageRoute(builder: (_) => const WordCategoriesScreen()),
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