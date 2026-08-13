import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../providers/test_mode_provider.dart';
import '../widgets/wort_text_field.dart';
import 'test_result_screen.dart';

class TestModeScreen extends ConsumerStatefulWidget {
  final List<Word> words;
  final int count;

  const TestModeScreen({super.key, required this.words, required this.count});

  @override
  ConsumerState<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends ConsumerState<TestModeScreen> {
  final _wordController = TextEditingController();
  String? _selectedArticle;

  @override
  void initState() {
    super.initState();
    // Ekran açılınca oturumu başlat (kelimeleri karıştır ve seç)
    Future.microtask(() => ref
        .read(testModeControllerProvider.notifier)
        .start(widget.words, widget.count));
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final word = ref.read(testModeControllerProvider).currentWord;
    if (word == null || _wordController.text.trim().isEmpty) return;

    // Sadece isimlerin artikeli vardır; fiil/bağlaç gibi kelimelerde artikel
    // hiç sorulmuyor, doğrudan boş kabul edilir.
    final isNoun = word.article.isNotEmpty;
    if (isNoun && _selectedArticle == null) return;

    final controller = ref.read(testModeControllerProvider.notifier);
    await controller.submitAnswer(
      article: isNoun ? _selectedArticle! : '',
      typedWord: _wordController.text,
    );
    if (!mounted) return;

    final state = ref.read(testModeControllerProvider);
    if (state.isFinished) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultScreen(answers: state.answers),
        ),
      );
    } else {
      _wordController.clear();
      setState(() => _selectedArticle = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testModeControllerProvider);
    final word = state.currentWord;
    final isNoun = word?.article.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.exerciseTestTitle)),
      body: word == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${state.currentIndex + 1} / ${state.words.length}',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Text(
                          word.meaningTr,
                          style: AppTextStyles.title,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          word.meaningEn,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (isNoun) ...[
                    const SizedBox(height: AppSizes.lg),
                    Text(AppStrings.article, style: AppTextStyles.caption),
                    const SizedBox(height: AppSizes.sm),
                    _ArticleDropdown(
                      selected: _selectedArticle,
                      onChanged: (value) =>
                          setState(() => _selectedArticle = value),
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  WortTextField(
                    controller: _wordController,
                    label: AppStrings.testWriteHint,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Text(
                      state.isLastWord ? AppStrings.testSeeResult : AppStrings.next,
                      style: AppTextStyles.title.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Artikel seçimi için sade bir dropdown (sadece isim olan kelimelerde gösterilir)
class _ArticleDropdown extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _ArticleDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = ['der', 'die', 'das'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          hint: Text(
            AppStrings.article,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          dropdownColor: AppColors.surface,
          items: options
              .map(
                (a) => DropdownMenuItem(
                  value: a,
                  child: Text(
                    a,
                    style: AppTextStyles.body.copyWith(color: AppColors.forArticle(a)),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
