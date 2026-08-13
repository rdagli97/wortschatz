import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wortschatz/screens/flashcard_screen.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/exercise_banner.dart';
import '../widgets/home_menu_button.dart';
import '../widgets/word_tile.dart';
import 'test_mode_screen.dart';
import 'word_detail_screen.dart';

class WordListScreen extends ConsumerWidget {
  // doluysa o Goethe seviyesindeki kelimeler ('A1'/'A2'/'B1') gösterilir;
  // null ise workspaceId'ye ait kişisel kelimeler gösterilir
  final String? level;
  // level doluyken kelime türü filtresi: null = Kelimeler (isim/diğer),
  // 'separableVerb'/'irregularVerb'/'regularVerb'/'conjunction' = ilgili tür
  final String? wordType;
  // level null iken kişisel kelimenin ait olduğu çalışma alanı
  final int? workspaceId;
  // null ise seviye/çalışma alanı içindeki tüm kelimeler gösterilir
  final WordCategory? category;
  final String title;
  final String emptyMessage;

  const WordListScreen({
    super.key,
    this.level,
    this.wordType,
    this.workspaceId,
    this.category,
    this.title = AppStrings.myWords,
    this.emptyMessage = AppStrings.noWordsYet,
  });

  List<Word> _filter(List<Word> words) {
    var result = level != null
        ? words.where((w) => w.level == level && w.wordType == wordType)
        : words.where((w) => w.level == null && w.workspaceId == workspaceId);
    if (category != null) {
      result = result.where((w) => w.category == category);
    }
    return result.toList();
  }

  // "Alıştırma" butonuna basınca: Tekrar Et / Test Modu seçimi
  void _showExerciseModeSheet(BuildContext context, List<Word> words) {
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
                label: AppStrings.exercisePracticeTitle,
                subtitle: AppStrings.exercisePracticeDesc,
                icon: Icons.style,
                accentColor: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashcardScreen(words: words),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.md),
              HomeMenuButton(
                label: AppStrings.exerciseTestTitle,
                subtitle: AppStrings.exerciseTestDesc,
                icon: Icons.edit_note,
                accentColor: AppColors.das,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showTestModeCountSheet(context, words);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // "Test Modu" seçilince: kaç kelimeden sınav olunacağını sor
  void _showTestModeCountSheet(BuildContext context, List<Word> words) {
    int selectedCount = words.length;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.testSetupTitle, style: AppTextStyles.title),
                const SizedBox(height: AppSizes.xs),
                Text(AppStrings.testSetupWordCountQuestion, style: AppTextStyles.caption),
                const SizedBox(height: AppSizes.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedCount,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceLight,
                      items: List.generate(words.length, (i) => i + 1)
                          .map(
                            (n) => DropdownMenuItem(
                              value: n,
                              child: Text('$n kelime', style: AppTextStyles.body),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setSheetState(() => selectedCount = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TestModeScreen(words: words, count: selectedCount),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    AppStrings.testSetupStart,
                    style: AppTextStyles.title.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: wordsAsync.when(
        data: (words) {
          final filtered = _filter(words);
          if (filtered.isEmpty) {
            return Center(
              child: Text(emptyMessage, style: AppTextStyles.caption),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.md, AppSizes.md, AppSizes.md, 0),
                child: ExerciseBanner(
                  wordCount: filtered.length,
                  onTap: () => _showExerciseModeSheet(context, filtered),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      0, AppSizes.md, 0, AppSizes.xxl),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final word = filtered[index];
                    return WordTile(
                      word: word,
                      onDelete: level != null
                          ? null
                          : () {
                              ref
                                  .read(addWordControllerProvider.notifier)
                                  .deleteWord(word.id!);
                            },
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WordDetailScreen(word: word),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}
