import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';

// Bir bağlacın fiili cümle sonuna gönderip göndermediğini gösteren rozet
class VerbPositionBadge extends StatelessWidget {
  final bool sendsVerbToEnd;

  const VerbPositionBadge({super.key, required this.sendsVerbToEnd});

  @override
  Widget build(BuildContext context) {
    final color = sendsVerbToEnd ? AppColors.die : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        sendsVerbToEnd ? AppStrings.verbToEnd : AppStrings.verbStaysSecond,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
