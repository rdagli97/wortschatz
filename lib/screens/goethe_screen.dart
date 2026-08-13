import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/word_progress_card.dart';
import 'goethe_word_type_screen.dart';

class GoetheScreen extends ConsumerWidget {
  const GoetheScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsProvider);
    final words = wordsAsync.value ?? const <Word>[];

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.goethe)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            _LevelCard(
              level: 'A1',
              label: AppStrings.goetheA1,
              color: AppColors.das,
              words: words,
            ),
            const SizedBox(height: AppSizes.md),
            _LevelCard(
              level: 'A2',
              label: AppStrings.goetheA2,
              color: AppColors.primary,
              words: words,
            ),
            const SizedBox(height: AppSizes.md),
            _LevelCard(
              level: 'B1',
              label: AppStrings.goetheB1,
              color: AppColors.die,
              words: words,
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String label;
  final Color color;
  final List<Word> words;

  const _LevelCard({
    required this.level,
    required this.label,
    required this.color,
    required this.words,
  });

  @override
  Widget build(BuildContext context) {
    final levelWords = words.where((w) => w.level == level).toList();
    final difficult =
        levelWords.where((w) => w.category == WordCategory.difficult).length;
    final learned =
        levelWords.where((w) => w.category == WordCategory.wellLearned).length;

    return WordProgressCard(
      label: 'Goethe $label',
      icon: Icons.flag_outlined,
      accentColor: color,
      total: levelWords.length,
      difficult: difficult,
      learned: learned,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoetheWordTypeScreen(
            level: level,
            title: 'Goethe $label',
          ),
        ),
      ),
    );
  }
}
