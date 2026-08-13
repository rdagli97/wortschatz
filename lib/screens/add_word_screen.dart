import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/goethe_a1_conjugations.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/wort_text_field.dart';
import '../widgets/article_selector.dart';
import '../widgets/word_type_selector.dart';
import '../widgets/verb_case_selector.dart';
import '../widgets/verb_position_selector.dart';

class AddWordScreen extends ConsumerStatefulWidget {
  final int workspaceId;

  const AddWordScreen({super.key, required this.workspaceId});

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

  final _ichController = TextEditingController();
  final _duController = TextEditingController();
  final _erController = TextEditingController();
  final _wirController = TextEditingController();
  final _ihrController = TextEditingController();
  final _sieSieController = TextEditingController();

  String? _selectedArticle;
  ManualWordType _selectedType = ManualWordType.noun;
  String _selectedVerbCase = 'akkusativ';
  bool? _sendsVerbToEnd;

  @override
  void dispose() {
    _wordController.dispose();
    _meaningEnController.dispose();
    _meaningTrController.dispose();
    _pluralController.dispose();
    _sentenceController.dispose();
    _translationEnController.dispose();
    _translationTrController.dispose();
    _ichController.dispose();
    _duController.dispose();
    _erController.dispose();
    _wirController.dispose();
    _ihrController.dispose();
    _sieSieController.dispose();
    super.dispose();
  }

  bool get _isVerb =>
      _selectedType == ManualWordType.regularVerb ||
      _selectedType == ManualWordType.irregularVerb ||
      _selectedType == ManualWordType.separableVerb;

  String get _verbWordType {
    switch (_selectedType) {
      case ManualWordType.regularVerb:
        return 'regularVerb';
      case ManualWordType.irregularVerb:
        return 'irregularVerb';
      case ManualWordType.separableVerb:
        return 'separableVerb';
      default:
        throw StateError('_verbWordType yalnızca fiil türlerinde çağrılmalı');
    }
  }

  Future<void> _save() async {
    final wordText = _wordController.text.trim();
    if (wordText.isEmpty) return;

    var article = '';
    var plural = '';
    String? wordType;
    String? conjugationJson;
    String? verbCase;
    bool? sendsVerbToEnd;

    if (_selectedType == ManualWordType.noun) {
      if (_selectedArticle == null) return;
      article = _selectedArticle!;
      plural = _pluralController.text.trim();
    } else if (_isVerb) {
      final ich = _ichController.text.trim();
      final du = _duController.text.trim();
      final er = _erController.text.trim();
      if (ich.isEmpty || du.isEmpty || er.isEmpty) return;
      wordType = _verbWordType;
      conjugationJson = VerbConjugation(
        ich: ich,
        du: du,
        erSieEs: er,
        wir: _wirController.text.trim().isEmpty ? wordText : _wirController.text.trim(),
        ihr: _ihrController.text.trim().isEmpty ? wordText : _ihrController.text.trim(),
        sieSie:
            _sieSieController.text.trim().isEmpty ? wordText : _sieSieController.text.trim(),
      ).toJson();
      verbCase = _selectedVerbCase;
    } else {
      if (_sendsVerbToEnd == null) return;
      wordType = 'conjunction';
      sendsVerbToEnd = _sendsVerbToEnd;
    }

    final word = Word(
      article: article,
      word: wordText,
      meaningEn: _meaningEnController.text.trim(),
      meaningTr: _meaningTrController.text.trim(),
      plural: plural,
      exampleSentence: _sentenceController.text.trim(),
      exampleTranslationEn: _translationEnController.text.trim(),
      exampleTranslationTr: _translationTrController.text.trim(),
      workspaceId: widget.workspaceId,
      wordType: wordType,
      conjugationJson: conjugationJson,
      verbCase: verbCase,
      sendsVerbToEnd: sendsVerbToEnd,
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
          WordTypeSelector(
            selected: _selectedType,
            onSelected: (type) => setState(() => _selectedType = type),
          ),
          const SizedBox(height: AppSizes.md),
          if (_selectedType == ManualWordType.noun) ...[
            ArticleSelector(
              selected: _selectedArticle,
              onSelected: (article) =>
                  setState(() => _selectedArticle = article),
            ),
            const SizedBox(height: AppSizes.md),
          ],
          WortTextField(controller: _wordController, label: AppStrings.word),
          const SizedBox(height: AppSizes.md),
          WortTextField(controller: _meaningEnController, label: 'İngilizce Anlamı'),
          const SizedBox(height: AppSizes.md),
          WortTextField(controller: _meaningTrController, label: 'Türkçe Anlamı'),
          const SizedBox(height: AppSizes.md),
          if (_selectedType == ManualWordType.noun) ...[
            WortTextField(controller: _pluralController, label: AppStrings.plural),
            const SizedBox(height: AppSizes.md),
          ],
          if (_isVerb) ...[
            Text(AppStrings.presentTenseConjugation, style: AppTextStyles.caption),
            const SizedBox(height: AppSizes.sm),
            WortTextField(controller: _ichController, label: 'ich'),
            const SizedBox(height: AppSizes.sm),
            WortTextField(controller: _duController, label: 'du'),
            const SizedBox(height: AppSizes.sm),
            WortTextField(controller: _erController, label: 'er / sie / es'),
            const SizedBox(height: AppSizes.sm),
            WortTextField(controller: _wirController, label: 'wir'),
            const SizedBox(height: AppSizes.sm),
            WortTextField(controller: _ihrController, label: 'ihr'),
            const SizedBox(height: AppSizes.sm),
            WortTextField(controller: _sieSieController, label: 'sie / Sie'),
            const SizedBox(height: AppSizes.md),
            VerbCaseSelector(
              selected: _selectedVerbCase,
              onSelected: (value) => setState(() => _selectedVerbCase = value),
            ),
            const SizedBox(height: AppSizes.md),
          ],
          if (_selectedType == ManualWordType.conjunction) ...[
            VerbPositionSelector(
              selected: _sendsVerbToEnd,
              onSelected: (value) => setState(() => _sendsVerbToEnd = value),
            ),
            const SizedBox(height: AppSizes.md),
          ],
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
