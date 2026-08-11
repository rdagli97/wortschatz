import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/article_badge.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final List<Word> words;
  const FlashcardScreen({super.key, required this.words});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran açılınca oturumu başlat (kelimeleri karıştır)
    Future.microtask(() {
      ref.read(flashcardControllerProvider.notifier).start(widget.words);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardControllerProvider);
    final word = state.currentWord;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.practice)),
      body: word == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                children: [
                  // İlerleme göstergesi
                  Text(
                    '${state.currentIndex + 1} / ${state.shuffledWords.length}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Kart (dokununca çevrilir)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref
                          .read(flashcardControllerProvider.notifier)
                          .reveal(),
                      child: _Flashcard(word: word, isRevealed: state.isRevealed),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Sonraki butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLastCard
                          ? null
                          : () => ref
                              .read(flashcardControllerProvider.notifier)
                              .next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                      child: Text(
                        state.isLastCard
                            ? AppStrings.practiceComplete
                            : AppStrings.next,
                        style: AppTextStyles.title.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Kartın kendisi
class _Flashcard extends StatelessWidget {
  final Word word;
  final bool isRevealed;

  const _Flashcard({required this.word, required this.isRevealed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kelime (her zaman görünür)
              Text(word.word, style: AppTextStyles.flashcardWord,
                  textAlign: TextAlign.center),
              if (!isRevealed) ...[
                const SizedBox(height: AppSizes.lg),
                Text(AppStrings.tapToReveal, style: AppTextStyles.caption),
              ],
              // Çevrilince görünen detaylar
              if (isRevealed) ...[
                const SizedBox(height: AppSizes.lg),
                ArticleBadge(article: word.article, fontSize: 20),
                const SizedBox(height: AppSizes.md),
                Text('${word.meaningTr}  ·  ${word.meaningEn}',
                    style: AppTextStyles.title, textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.sm),
                Text('Çoğul: ${word.plural}',
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSizes.lg),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSizes.md),
                Text(word.exampleSentence,
                    style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.sm),
                Text(word.exampleTranslationTr,
                    style: AppTextStyles.caption, textAlign: TextAlign.center),
                Text(word.exampleTranslationEn,
                    style: AppTextStyles.caption, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}