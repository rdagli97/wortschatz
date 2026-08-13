import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/goethe_a1_conjugations.dart';
import '../data/goethe_a1_verb_cases.dart';
import '../data/goethe_a1_word_types.dart';
import '../models/word.dart';
import '../widgets/article_badge.dart';
import '../widgets/verb_case_badge.dart';
import '../widgets/verb_conjugation_table.dart';
import '../widgets/verb_position_badge.dart';

class WordDetailScreen extends StatelessWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    // Çoğul yalnızca isimler için anlamlı; fiil/bağlaç/diğer kelimelerde
    // (article boş) her zaman boş olduğu için gösterilmez.
    final hasPlural = word.article.isNotEmpty;
    final sendsVerbToEnd = word.wordType == 'conjunction'
        ? conjunctionSendsVerbToEnd(word.word)
        : null;
    final conjugation = conjugatePresentTense(word.word, word.wordType);
    final objectCase = verbCase(word.word, word.wordType);

    return Scaffold(
      appBar: AppBar(title: Text(word.word)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text(
                    word.word,
                    style: AppTextStyles.flashcardWord,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ArticleBadge(article: word.article, fontSize: 20),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    '${word.meaningTr}  ·  ${word.meaningEn}',
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                  if (sendsVerbToEnd != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    Center(child: VerbPositionBadge(sendsVerbToEnd: sendsVerbToEnd)),
                  ],
                  if (hasPlural) ...[
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Çoğul: ${word.plural}',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: AppSizes.lg),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    word.exampleSentence,
                    style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(word.exampleTranslationTr,
                      style: AppTextStyles.caption, textAlign: TextAlign.center),
                  Text(word.exampleTranslationEn,
                      style: AppTextStyles.caption, textAlign: TextAlign.center),
                ],
              ),
            ),
            if (conjugation != null) ...[
              const SizedBox(height: AppSizes.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.presentTenseConjugation, style: AppTextStyles.title),
                        if (objectCase != null) VerbCaseBadge(verbCase: objectCase),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    VerbConjugationTable(conjugation: conjugation),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.lg),
            _StatsCard(word: word),
          ],
        ),
      ),
    );
  }
}

// Öğrenme durumu: kategori rozeti + tekrar/seri sayıları
class _StatsCard extends StatelessWidget {
  final Word word;

  const _StatsCard({required this.word});

  (String, Color) _categoryInfo() {
    switch (word.category) {
      case WordCategory.newWord:
        return (AppStrings.categoryNew, AppColors.das);
      case WordCategory.difficult:
        return (AppStrings.categoryDifficult, AppColors.die);
      case WordCategory.wellLearned:
        return (AppStrings.categoryWellLearned, AppColors.der);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _categoryInfo();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.timesReviewed, style: AppTextStyles.body),
              Text('${word.reviewCount}', style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.correctStreakLabel, style: AppTextStyles.body),
              Text('${word.correctStreak}', style: AppTextStyles.title),
            ],
          ),
        ],
      ),
    );
  }
}
