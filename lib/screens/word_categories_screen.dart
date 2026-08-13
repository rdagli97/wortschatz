import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../widgets/home_menu_button.dart';
import 'add_word_screen.dart';
import 'ai_add_word_screen.dart';
import 'word_list_screen.dart';

class WordCategoriesScreen extends StatelessWidget {
  final int workspaceId;
  final String title;

  const WordCategoriesScreen({
    super.key,
    required this.workspaceId,
    this.title = AppStrings.words,
  });

  void _showAddWordModeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HomeMenuButton(
                label: AppStrings.addWordManual,
                subtitle: AppStrings.addWordManualDesc,
                icon: Icons.edit_note,
                accentColor: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddWordScreen(workspaceId: workspaceId),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.md),
              HomeMenuButton(
                label: AppStrings.addWordAi,
                subtitle: AppStrings.addWordAiDesc,
                icon: Icons.auto_awesome,
                accentColor: AppColors.das,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiAddWordScreen(workspaceId: workspaceId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                MaterialPageRoute(
                  builder: (_) => WordListScreen(workspaceId: workspaceId),
                ),
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
                  builder: (_) => WordListScreen(
                    workspaceId: workspaceId,
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
                  builder: (_) => WordListScreen(
                    workspaceId: workspaceId,
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
                  builder: (_) => WordListScreen(
                    workspaceId: workspaceId,
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
        onPressed: () => _showAddWordModeSheet(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppStrings.addWord,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
