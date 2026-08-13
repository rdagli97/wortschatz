import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home_menu_button.dart';
import 'goethe_categories_screen.dart';

// Bir Goethe seviyesine (A1/A2/B1) girildiğinde kelime türüne göre ayrım:
// Kelimeler (isimler + diğer), Ayrılabilir/Düzenli/Düzensiz Fiiller, Bağlaçlar.
class GoetheWordTypeScreen extends StatelessWidget {
  final String level;
  final String title;

  const GoetheWordTypeScreen({
    super.key,
    required this.level,
    required this.title,
  });

  void _push(BuildContext context, String? wordType, String label) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoetheCategoriesScreen(
          level: level,
          wordType: wordType,
          title: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            HomeMenuButton(
              label: AppStrings.words,
              icon: Icons.style,
              accentColor: AppColors.primary,
              onTap: () => _push(context, null, AppStrings.words),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.separableVerbs,
              icon: Icons.call_split,
              accentColor: AppColors.das,
              onTap: () => _push(context, 'separableVerb', AppStrings.separableVerbs),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.regularVerbs,
              icon: Icons.repeat,
              accentColor: AppColors.der,
              onTap: () => _push(context, 'regularVerb', AppStrings.regularVerbs),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.irregularVerbs,
              icon: Icons.shuffle,
              accentColor: AppColors.die,
              onTap: () => _push(context, 'irregularVerb', AppStrings.irregularVerbs),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.conjunctions,
              icon: Icons.link,
              accentColor: AppColors.primaryDark,
              onTap: () => _push(context, 'conjunction', AppStrings.conjunctions),
            ),
          ],
        ),
      ),
    );
  }
}
