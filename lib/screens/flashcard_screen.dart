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

    if (state.isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.practice)),
        body: Center(
          child: Text(AppStrings.practiceComplete, style: AppTextStyles.title),
        ),
      );
    }

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
                  // Değerlendirme: kart çevrilince ❌ / ✅
                  SizedBox(
                    height: 72,
                    child: state.isRevealed
                        ? Row(
                            children: [
                              Expanded(
                                child: _AnswerButton(
                                  icon: Icons.close_rounded,
                                  color: AppColors.die,
                                  onTap: () => ref
                                      .read(flashcardControllerProvider.notifier)
                                      .answer(false),
                                ),
                              ),
                              const SizedBox(width: AppSizes.md),
                              Expanded(
                                child: _AnswerButton(
                                  icon: Icons.check_rounded,
                                  color: AppColors.das,
                                  onTap: () => ref
                                      .read(flashcardControllerProvider.notifier)
                                      .answer(true),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              AppStrings.tapToReveal,
                              style: AppTextStyles.caption,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Doğru/yanlış değerlendirme butonu (tinder tarzı ❌ / ✅)
class _AnswerButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: AppSizes.iconLg),
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