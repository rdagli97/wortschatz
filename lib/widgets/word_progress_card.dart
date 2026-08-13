import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

// Bir çalışma alanı ya da Goethe seviyesi için toplam/zorlanılan/öğrenilen
// kelime sayısını ve öğrenilen/toplam oranını gösteren, motive edici bir kart.
class WordProgressCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final int total;
  final int difficult;
  final int learned;
  final VoidCallback onTap;

  const WordProgressCard({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.total,
    required this.difficult,
    required this.learned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : learned / total;
    final percent = (progress * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: accentColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(icon, color: accentColor, size: AppSizes.iconLg),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(label, style: AppTextStyles.title),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            if (total == 0) ...[
              const SizedBox(height: AppSizes.md),
              Text(AppStrings.statsEmptyLabel, style: AppTextStyles.caption),
            ] else ...[
              const SizedBox(height: AppSizes.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceLight,
                  color: AppColors.das,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '%$percent ${AppStrings.statsLearnedLabel.toLowerCase()}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.das, fontWeight: FontWeight.bold),
                  ),
                  Text('$learned / $total', style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                '${AppStrings.statsTotalLabel}: $total  ·  '
                '${AppStrings.statsDifficultLabel}: $difficult  ·  '
                '${AppStrings.statsLearnedLabel}: $learned',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
