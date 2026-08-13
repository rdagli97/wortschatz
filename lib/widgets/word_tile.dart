import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/goethe_a1_word_types.dart';
import '../models/word.dart';
import 'article_badge.dart';
import 'verb_position_badge.dart';

class WordTile extends StatelessWidget {
  final Word word;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const WordTile({
    super.key,
    required this.word,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sendsVerbToEnd = word.wordType == 'conjunction'
        ? (word.sendsVerbToEnd ?? conjunctionSendsVerbToEnd(word.word))
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            ArticleBadge(article: word.article),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.word, style: AppTextStyles.title),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '${word.meaningTr} · ${word.meaningEn}',
                    style: AppTextStyles.caption,
                  ),
                  if (sendsVerbToEnd != null) ...[
                    const SizedBox(height: AppSizes.xs),
                    VerbPositionBadge(sendsVerbToEnd: sendsVerbToEnd),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}