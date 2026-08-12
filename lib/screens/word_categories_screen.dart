import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../widgets/home_menu_button.dart';
import 'add_word_screen.dart';
import 'word_list_screen.dart';

class WordCategoriesScreen extends StatelessWidget {
  const WordCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.words)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            HomeMenuButton(
              label: AppStrings.allWords,
              icon: Icons.list,
              accentColor: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordListScreen()),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.newlyAddedWords,
              icon: Icons.fiber_new,
              accentColor: AppColors.das,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WordListScreen(
                    category: WordCategory.newWord,
                    title: AppStrings.newlyAddedWords,
                    emptyMessage: AppStrings.noNewWordsYet,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.difficultWords,
              icon: Icons.trending_down,
              accentColor: AppColors.die,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WordListScreen(
                    category: WordCategory.difficult,
                    title: AppStrings.difficultWords,
                    emptyMessage: AppStrings.noDifficultWordsYet,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.wellLearnedWords,
              icon: Icons.check_circle,
              accentColor: AppColors.der,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WordListScreen(
                    category: WordCategory.wellLearned,
                    title: AppStrings.wellLearnedWords,
                    emptyMessage: AppStrings.noWellLearnedWordsYet,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddWordScreen()),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppStrings.addWord,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
