import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wortschatz/screens/flashcard_screen.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/word_provider.dart';
import '../widgets/word_tile.dart';
import 'add_word_screen.dart';

class WordListScreen extends ConsumerWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myWords),
        actions: [
          // sadece kelime varsa Tekrar Et göster
          wordsAsync.maybeWhen(
            data: (words) => words.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlashcardScreen(words: words),
                      ),
                    ),
                    child: Text(
                      AppStrings.practice,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: wordsAsync.when(
        data: (words) {
          if (words.isEmpty) {
            return Center(
              child: Text(AppStrings.noWordsYet, style: AppTextStyles.caption),
            );
          }
          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return WordTile(
                word: word,
                onDelete: () {
                  ref
                      .read(addWordControllerProvider.notifier)
                      .deleteWord(word.id!);
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Hata: $err')),
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
