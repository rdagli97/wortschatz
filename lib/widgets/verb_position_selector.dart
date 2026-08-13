import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_text_styles.dart';

// Manuel bağlaç eklerken fiili cümle sonuna gönderip göndermediğini seçtirir.
class VerbPositionSelector extends StatelessWidget {
  final bool? selected;
  final ValueChanged<bool> onSelected;

  const VerbPositionSelector({super.key, required this.selected, required this.onSelected});

  static const _options = <(bool, String)>[
    (true, AppStrings.verbToEnd),
    (false, AppStrings.verbStaysSecond),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.verbPositionSelectLabel, style: AppTextStyles.caption),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: _options.map((option) {
            final isSelected = selected == option.$1;
            return GestureDetector(
              onTap: () => onSelected(option.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: Text(
                  option.$2,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
