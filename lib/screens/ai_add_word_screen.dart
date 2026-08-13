import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../providers/ai_word_provider.dart';
import '../providers/word_provider.dart';
import '../widgets/wort_text_field.dart';
import '../widgets/article_selector.dart';
import 'settings_screen.dart';

class AiAddWordScreen extends ConsumerStatefulWidget {
  final int workspaceId;

  const AiAddWordScreen({super.key, required this.workspaceId});

  @override
  ConsumerState<AiAddWordScreen> createState() => _AiAddWordScreenState();
}

class _AiAddWordScreenState extends ConsumerState<AiAddWordScreen> {
  final _germanWordController = TextEditingController();

  final _meaningEnController = TextEditingController();
  final _meaningTrController = TextEditingController();
  final _pluralController = TextEditingController();
  final _sentenceController = TextEditingController();
  final _translationEnController = TextEditingController();
  final _translationTrController = TextEditingController();
  String? _selectedArticle;

  // Review formu, sonuç geldiğinde bir kere dolduruluyor
  Word? _prefilledFrom;

  @override
  void dispose() {
    _germanWordController.dispose();
    _meaningEnController.dispose();
    _meaningTrController.dispose();
    _pluralController.dispose();
    _sentenceController.dispose();
    _translationEnController.dispose();
    _translationTrController.dispose();
    super.dispose();
  }

  void _fillReviewForm(Word word) {
    _selectedArticle = word.article.isEmpty ? null : word.article;
    _meaningEnController.text = word.meaningEn;
    _meaningTrController.text = word.meaningTr;
    _pluralController.text = word.plural;
    _sentenceController.text = word.exampleSentence;
    _translationEnController.text = word.exampleTranslationEn;
    _translationTrController.text = word.exampleTranslationTr;
  }

  Future<void> _generate() async {
    await ref.read(aiWordControllerProvider.notifier).generate(
          _germanWordController.text,
          widget.workspaceId,
        );
  }

  Future<void> _save(Word generated) async {
    final word = Word(
      article: _selectedArticle ?? '',
      word: generated.word,
      meaningEn: _meaningEnController.text.trim(),
      meaningTr: _meaningTrController.text.trim(),
      plural: _pluralController.text.trim(),
      exampleSentence: _sentenceController.text.trim(),
      exampleTranslationEn: _translationEnController.text.trim(),
      exampleTranslationTr: _translationTrController.text.trim(),
      workspaceId: widget.workspaceId,
    );

    final success =
        await ref.read(addWordControllerProvider.notifier).addWord(word);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiWordControllerProvider);
    final addState = ref.watch(addWordControllerProvider);

    final generated = aiState.generatedWord;
    if (generated != null && !identical(generated, _prefilledFrom)) {
      _fillReviewForm(generated);
      _prefilledFrom = generated;
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aiAddWordTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          WortTextField(
            controller: _germanWordController,
            label: AppStrings.aiWordInputLabel,
          ),
          const SizedBox(height: AppSizes.md),
          if (generated == null)
            ElevatedButton(
              onPressed: aiState.isLoading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: aiState.isLoading
                  ? const SizedBox(
                      width: AppSizes.iconSm,
                      height: AppSizes.iconSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppStrings.aiGenerate,
                      style: AppTextStyles.title.copyWith(color: Colors.white)),
            ),
          if (aiState.isLoading) ...[
            const SizedBox(height: AppSizes.sm),
            Text(AppStrings.aiGenerating, style: AppTextStyles.caption),
          ],
          if (aiState.errorMessage != null) ...[
            const SizedBox(height: AppSizes.md),
            Text(
              aiState.errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
            if (aiState.needsApiKey) ...[
              const SizedBox(height: AppSizes.sm),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                child: Text(AppStrings.goToSettings,
                    style: AppTextStyles.body.copyWith(color: AppColors.primary)),
              ),
            ],
          ],
          if (generated != null) ...[
            const Divider(height: AppSizes.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppStrings.aiReviewHint, style: AppTextStyles.caption),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(aiWordControllerProvider.notifier).reset();
                    setState(() {
                      _prefilledFrom = null;
                      _germanWordController.clear();
                    });
                  },
                  child: Text(
                    'Başka Kelime',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ArticleSelector(
              selected: _selectedArticle,
              onSelected: (article) => setState(() => _selectedArticle = article),
            ),
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
            if (addState.errorMessage != null) ...[
              Text(
                addState.errorMessage!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSizes.md),
            ],
            ElevatedButton(
              onPressed: addState.isSaving ? null : () => _save(generated),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: addState.isSaving
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
        ],
      ),
    );
  }
}
