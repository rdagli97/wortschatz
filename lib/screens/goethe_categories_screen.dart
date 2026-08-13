import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../models/word.dart';
import '../widgets/home_menu_button.dart';
import 'word_list_screen.dart';

// Bir Goethe seviyesi + kelime türü içindeki Tüm/Yeni/Zorlanılan/İyi
// Öğrenilmiş kırılımı. Goethe kelimeleri kullanıcı tarafından eklenemediği
// için WordCategoriesScreen'den farklı olarak kelime ekleme butonu yok.
class GoetheCategoriesScreen extends StatelessWidget {
  final String level;
  final String? wordType;
  final String title;

  const GoetheCategoriesScreen({
    super.key,
    required this.level,
    required this.wordType,
    required this.title,
  });

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
                  builder: (_) => WordListScreen(
                    level: level,
                    wordType: wordType,
                    title: title,
                    emptyMessage: AppStrings.noGoetheWordsYet,
                  ),
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
                    level: level,
                    wordType: wordType,
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
                    level: level,
                    wordType: wordType,
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
                    level: level,
                    wordType: wordType,
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
    );
  }
}
