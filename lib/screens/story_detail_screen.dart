import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/story.dart';
import '../models/word.dart';
import '../models/workspace.dart';
import '../providers/ai_word_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/story_provider.dart';
import '../providers/word_provider.dart';
import '../providers/workspace_provider.dart';
import '../services/gemini_service.dart';
import '../widgets/article_badge.dart';
import 'settings_screen.dart';

// Almanca harf (ä/ö/ü/ß dahil) dizilerini kelime, geri kalanını ayraç sayar.
final _tokenPattern = RegExp(r'[A-Za-zÄÖÜäöüß]+|[^A-Za-zÄÖÜäöüß]+');
final _wordPattern = RegExp(r'^[A-Za-zÄÖÜäöüß]+$');

List<(String text, bool isWord)> _tokenize(String sentence) {
  return _tokenPattern
      .allMatches(sentence)
      .map((m) => (m.group(0)!, _wordPattern.hasMatch(m.group(0)!)))
      .toList();
}

class StoryDetailScreen extends ConsumerStatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  ConsumerState<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends ConsumerState<StoryDetailScreen> {
  // Aynı hikayeyi okurken aynı kelimeye tekrar dokunulursa (ör. "ich" pek
  // çok kez geçebilir) Gemini'ye tekrar istek atmamak için oturum içi
  // önbellek. Anahtar orijinal büyük/küçük harfiyle tutulur ("Essen"/"essen"
  // gibi eş sesli isim-fiil çiftleri karışmasın diye).
  final Map<String, Word> _wordCache = {};

  void _showWordSheet(BuildContext context, String word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (_) => _WordInfoSheet(
        word: word,
        cached: _wordCache[word],
        onResolved: (info) => _wordCache[word] = info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final sentences =
        story.content.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(story.level),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(storyListControllerProvider).deleteStory(story.id!);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                story.title,
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                AppStrings.storyTapHint,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              const Divider(color: AppColors.divider),
              const SizedBox(height: AppSizes.lg),
              for (final sentence in sentences) ...[
                Wrap(
                  children: [
                    for (final (text, isWord) in _tokenize(sentence))
                      isWord
                          ? InkWell(
                              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              onTap: () => _showWordSheet(context, text),
                              child: Text(
                                text,
                                style: AppTextStyles.body.copyWith(fontSize: 17, height: 1.8),
                              ),
                            )
                          : Text(
                              text,
                              style: AppTextStyles.body.copyWith(fontSize: 17, height: 1.8),
                            ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Bir hikaye kelimesine dokununca açılan: artikel/TR/EN bilgisi + çalışma
// alanına ekleme akışı.
class _WordInfoSheet extends ConsumerStatefulWidget {
  final String word;
  final Word? cached;
  final void Function(Word info) onResolved;

  const _WordInfoSheet({
    required this.word,
    required this.cached,
    required this.onResolved,
  });

  @override
  ConsumerState<_WordInfoSheet> createState() => _WordInfoSheetState();
}

class _WordInfoSheetState extends ConsumerState<_WordInfoSheet> {
  bool _isLoading = true;
  String? _error;
  bool _needsApiKey = false;
  Word? _info;
  bool _pickingWorkspace = false;
  String? _feedback;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    if (widget.cached != null) {
      _isLoading = false;
      _info = widget.cached;
    } else {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    final apiKey = await ref.read(apiKeyServiceProvider).getApiKey();
    if (!mounted) return;
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _needsApiKey = true;
        _error = AppStrings.aiNoApiKeyError;
      });
      return;
    }

    try {
      final info =
          await ref.read(geminiServiceProvider).generateWordDetails(widget.word, apiKey);
      widget.onResolved(info);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _info = info;
      });
    } on GeminiApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _needsApiKey = e.isInvalidKey;
        _error = e.isInvalidKey ? AppStrings.aiInvalidKeyError : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = AppStrings.aiGenericError;
      });
    }
  }

  Future<void> _addToWorkspace(Workspace workspace) async {
    final info = _info;
    if (info == null) return;

    final word = Word(
      article: info.article,
      word: info.word,
      meaningEn: info.meaningEn,
      meaningTr: info.meaningTr,
      plural: info.plural,
      exampleSentence: info.exampleSentence,
      exampleTranslationEn: info.exampleTranslationEn,
      exampleTranslationTr: info.exampleTranslationTr,
      workspaceId: workspace.id,
    );
    final success = await ref.read(addWordControllerProvider.notifier).addWord(word);
    if (!mounted) return;
    setState(() {
      _pickingWorkspace = false;
      _feedbackIsError = !success;
      _feedback = success
          ? '"${info.word}" "${workspace.name}" çalışma alanına eklendi.'
          : AppStrings.duplicateWordError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: _isLoading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            : _info == null
                ? _buildError()
                : _buildContent(_info!),
      ),
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _error ?? AppStrings.aiGenericError,
          style: AppTextStyles.caption.copyWith(color: AppColors.error),
        ),
        if (_needsApiKey) ...[
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
    );
  }

  Widget _buildContent(Word info) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (info.article.isNotEmpty) ...[
              ArticleBadge(article: info.article, fontSize: 16),
              const SizedBox(width: AppSizes.sm),
            ],
            Expanded(child: Text(info.word, style: AppTextStyles.title)),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        Text('${info.meaningTr} · ${info.meaningEn}', style: AppTextStyles.caption),
        const SizedBox(height: AppSizes.md),
        if (!_pickingWorkspace)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() {
                _pickingWorkspace = true;
                _feedback = null;
              }),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(AppStrings.storyWordAddButton,
                  style: AppTextStyles.body.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          )
        else ...[
          Text(AppStrings.storyWordPickWorkspace, style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.sm),
          Consumer(
            builder: (context, ref, _) {
              final workspacesAsync = ref.watch(workspacesProvider);
              return workspacesAsync.when(
                data: (workspaces) => Column(
                  children: [
                    for (final workspace in workspaces)
                      InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        onTap: () => _addToWorkspace(workspace),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                          child: Row(
                            children: [
                              Icon(
                                workspace.isDefault
                                    ? Icons.star_outline
                                    : Icons.folder_outlined,
                                color: AppColors.primary,
                                size: AppSizes.iconMd,
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(workspace.name, style: AppTextStyles.body),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (err, _) =>
                    Text('Hata: $err', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
              );
            },
          ),
        ],
        if (_feedback != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            _feedback!,
            style: AppTextStyles.caption
                .copyWith(color: _feedbackIsError ? AppColors.error : AppColors.das),
          ),
        ],
      ],
    );
  }
}
