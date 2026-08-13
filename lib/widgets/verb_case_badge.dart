import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';

// Bir fiilin nesne durumunu (Rektion) gösteren rozet: Akkusativ/Dativ/ikisi/hiçbiri
class VerbCaseBadge extends StatelessWidget {
  final String verbCase;

  const VerbCaseBadge({super.key, required this.verbCase});

  (String, Color) get _info {
    switch (verbCase) {
      case 'dativ':
        return (AppStrings.verbCaseDativ, AppColors.die);
      case 'akkusativ+dativ':
        return (AppStrings.verbCaseBoth, AppColors.primary);
      case 'nominativ':
        return (AppStrings.verbCaseNominativ, AppColors.textSecondary);
      default:
        return (AppStrings.verbCaseAkkusativ, AppColors.der);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
