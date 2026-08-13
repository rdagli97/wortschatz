import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/test_mode_provider.dart';
import '../widgets/article_badge.dart';
import 'test_mode_screen.dart';

class TestResultScreen extends StatelessWidget {
  final List<TestAnswer> answers;

  const TestResultScreen({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    final correctCount = answers.where((a) => a.isCorrect).length;
    final wrongWords = answers.where((a) => !a.isCorrect).map((a) => a.word).toList();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.testResultTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    '$correctCount / ${answers.length}',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(AppStrings.testResultCorrectSuffix, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, 0, AppSizes.md, AppSizes.md),
              itemCount: answers.length,
              itemBuilder: (context, index) =>
                  _AnswerReviewCard(answer: answers[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, 0, AppSizes.md, AppSizes.md),
            child: Column(
              children: [
                if (wrongWords.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TestModeScreen(
                            words: wrongWords,
                            count: wrongWords.length,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.die,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                      child: Text(
                        AppStrings.testResultRetryWrong,
                        style: AppTextStyles.title.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
                SizedBox(
                  width: double.infinity,
                  child: wrongWords.isNotEmpty
                      ? OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: Text(
                            AppStrings.testResultDone,
                            style: AppTextStyles.title.copyWith(color: AppColors.primary),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: Text(
                            AppStrings.testResultDone,
                            style: AppTextStyles.title.copyWith(color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  final TestAnswer answer;

  const _AnswerReviewCard({required this.answer});

  @override
  Widget build(BuildContext context) {
    final correct = answer.isCorrect;
    final statusColor = correct ? AppColors.das : AppColors.die;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(correct ? Icons.check_circle : Icons.cancel, color: statusColor),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${answer.word.meaningTr} · ${answer.word.meaningEn}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    ArticleBadge(article: answer.word.article),
                    const SizedBox(width: AppSizes.sm),
                    Text(answer.word.word, style: AppTextStyles.title),
                  ],
                ),
                if (!correct) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '${AppStrings.testResultYourAnswer}: '
                    '${answer.selectedArticle.isEmpty ? "—" : answer.selectedArticle} '
                    '${answer.typedWord.trim().isEmpty ? "(boş)" : answer.typedWord}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.die),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
