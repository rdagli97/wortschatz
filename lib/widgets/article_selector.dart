import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_text_styles.dart';

class ArticleSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const ArticleSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const articles = ['der', 'die', 'das'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.article, style: AppTextStyles.caption),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: articles.map((article) {
            final isSelected = selected == article;
            final color = AppColors.forArticle(article);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSizes.sm),
                child: GestureDetector(
                  onTap: () => onSelected(article),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    decoration: BoxDecoration(
                      color: isSelected ? color : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected ? color : AppColors.divider,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      article,
                      style: AppTextStyles.article.copyWith(
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}