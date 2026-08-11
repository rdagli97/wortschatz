import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_sizes.dart';

class ArticleBadge extends StatelessWidget {
  final String article;
  final double fontSize;

  const ArticleBadge({
    super.key,
    required this.article,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forArticle(article);

    return Container(
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
        article,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}