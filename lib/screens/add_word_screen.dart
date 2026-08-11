import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/wort_text_field.dart';
import '../widgets/article_selector.dart';

class AddWordScreen extends ConsumerStatefulWidget {
  const AddWordScreen({super.key});

  @override
  ConsumerState<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends ConsumerState<AddWordScreen> {
  final _wordController = TextEditingController();
  final _meaningEnController = TextEditingController();
  final _meaningTrController = TextEditingController();
  final _pluralController = TextEditingController();
  final _sentenceController = TextEditingController();
  final _translationEnController = TextEditingController();
  final _translationTrController = TextEditingController();

  String? _selectedArticle;

  @override
  void dispose() {
    _wordController.dispose();
    _meaningEnController.dispose();
    _meaningTrController.dispose();
    _pluralController.dispose();
    _sentenceController.dispose();
    _translationEnController.dispose();
    _translationTrController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Basit doğrulama: artikel seçili mi, kelime boş mu?
    if (_selectedArticle == null || _wordController.text.trim().isEmpty) {
      return;
    }

    final word = Word(
      article: _selectedArticle!,
      word: _wordController.text.trim(),
      meaningEn: _meaningEnController.text.trim(),
      meaningTr: _meaningTrController.text.trim(),
      plural: _pluralController.text.trim(),
      exampleSentence: _sentenceController.text.trim(),
      exampleTranslationEn: _translationEnController.text.trim(),
      exampleTranslationTr: _translationTrController.text.trim(),
    );

    final success =
        await ref.read(addWordControllerProvider.notifier).addWord(word);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addWordControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addWord)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          ArticleSelector(
            selected: _selectedArticle,
            onSelected: (article) =>
                setState(() => _selectedArticle = article),
          ),
          const SizedBox(height: AppSizes.md),
          WortTextField(controller: _wordController, label: AppStrings.word),
          const SizedBox(height: AppSizes.md),
          WortTextField(controller: _meaningEnController, label: 'İngilizce Anlamı'),
          const SizedBox(height: AppSizes.md),
          WortTextField(controller: _meaningTrController, label: 'Türkçe Anlamı'),
          const SizedBox(height: AppSizes.md),
          WortTextField(controller: _pluralController, label: AppStrings.plural),
          const SizedBox(height: AppSizes.md),
          WortTextField(
            controller: _sentenceController,
            label: AppStrings.exampleSentence,
            maxLines: 2,
          ),
          const SizedBox(height: AppSizes.md),
          WortTextField(
            controller: _translationEnController,
            label: 'İngilizce Çevirisi',
            maxLines: 2,
          ),
          const SizedBox(height: AppSizes.md),
          WortTextField(
            controller: _translationTrController,
            label: 'Türkçe Çevirisi',
            maxLines: 2,
          ),
          const SizedBox(height: AppSizes.lg),
          if (state.errorMessage != null) ...[
            Text(
              state.errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSizes.md),
          ],
          ElevatedButton(
            onPressed: state.isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: state.isSaving
                ? const SizedBox(
                    width: AppSizes.iconSm,
                    height: AppSizes.iconSm,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(AppStrings.save,
                    style: AppTextStyles.title.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}