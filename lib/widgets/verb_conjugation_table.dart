import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/goethe_a1_conjugations.dart';

// Bir fiilin ich/du/er-sie-es/wir/ihr/sie-Sie çekimlerini tablo halinde gösterir
class VerbConjugationTable extends StatelessWidget {
  final VerbConjugation conjugation;

  const VerbConjugationTable({super.key, required this.conjugation});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('ich', conjugation.ich),
      ('du', conjugation.du),
      ('er/sie/es', conjugation.erSieEs),
      ('wir', conjugation.wir),
      ('ihr', conjugation.ihr),
      ('sie/Sie', conjugation.sieSie),
    ];

    return Column(
      children: [
        for (final entry in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Text(
                    entry.$1,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.$2,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
