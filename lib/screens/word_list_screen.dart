import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wortschatz/screens/flashcard_screen.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/word_tile.dart';
import 'word_detail_screen.dart';

class WordListScreen extends ConsumerWidget {
  // null ise kişisel kelimeler ('Benim Çalışma Alanım'), doluysa o Goethe
  // seviyesindeki kelimeler ('A1'/'A2'/'B1') gösterilir
  final String? level;
  // null ise seviye içindeki tüm kelimeler gösterilir
  final WordCategory? category;
  final String title;
  final String emptyMessage;

  const WordListScreen({
    super.key,
    this.level,
    this.category,
    this.title = AppStrings.myWords,
    this.emptyMessage = AppStrings.noWordsYet,
  });

  List<Word> _filter(List<Word> words) {
    var result = words.where((w) => w.level == level);
    if (category != null) {
      result = result.where((w) => w.category == category);
    }
    return result.toList();
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
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSizes.xxl * 2),
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
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Hata: $err')),
      ),
      floatingActionButton: wordsAsync.maybeWhen(
        data: (words) {
          final filtered = _filter(words);
          if (filtered.isEmpty) return null;
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FlashcardScreen(words: filtered),
              ),
            ),
            icon: const Icon(Icons.style_outlined, color: Colors.white),
            label: Text(
              AppStrings.practice,
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}
