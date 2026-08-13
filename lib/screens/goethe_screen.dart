import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home_menu_button.dart';
import 'word_list_screen.dart';

class GoetheScreen extends StatelessWidget {
  const GoetheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.words)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            _LevelButton(level: 'A1', label: AppStrings.goetheA1, color: AppColors.das),
            const SizedBox(height: AppSizes.md),
            _LevelButton(level: 'A2', label: AppStrings.goetheA2, color: AppColors.primary),
            const SizedBox(height: AppSizes.md),
            _LevelButton(level: 'B1', label: AppStrings.goetheB1, color: AppColors.die),
          ],
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String level;
  final String label;
  final Color color;

  const _LevelButton({required this.level, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return HomeMenuButton(
      label: 'Goethe $label',
      icon: Icons.flag_outlined,
      accentColor: color,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WordListScreen(
            level: level,
            title: 'Goethe $label',
            emptyMessage: AppStrings.noGoetheWordsYet,
          ),
        ),
      ),
    );
  }
}
