import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_sizes.dart';

class HomeMenuButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final bool enabled;
  final VoidCallback onTap;

  const HomeMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.enabled = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: enabled ? accentColor : AppColors.divider,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: enabled
                    ? accentColor.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icon,
                color: enabled ? accentColor : AppColors.textMuted,
                size: AppSizes.iconLg,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.title.copyWith(
                      color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(subtitle!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (!enabled)
              Text('Yakında',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
            if (enabled)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}