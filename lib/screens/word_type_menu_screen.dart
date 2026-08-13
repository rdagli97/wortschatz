import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home_menu_button.dart';

// "Benim Çalışma Alanım" ve "Goethe" altında ortak kullanılan kelime türü
// menüsü. "Kelimeler" seçili alana göre farklı bir ekrana götürür; diğerleri
// henüz eklenmedi.
class WordTypeMenuScreen extends StatelessWidget {
  final String title;
  final Widget wordsDestination;

  const WordTypeMenuScreen({
    super.key,
    required this.title,
    required this.wordsDestination,
  });

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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => wordsDestination),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.regularVerbs,
              icon: Icons.repeat,
              accentColor: AppColors.der,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.irregularVerbs,
              icon: Icons.shuffle,
              accentColor: AppColors.die,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.separableVerbs,
              icon: Icons.call_split,
              accentColor: AppColors.das,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.md),
            HomeMenuButton(
              label: AppStrings.conjunctions,
              icon: Icons.link,
              accentColor: AppColors.primaryDark,
              enabled: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
