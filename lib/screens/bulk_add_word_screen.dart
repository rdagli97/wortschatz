import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/bulk_add_word_provider.dart';
import '../widgets/wort_text_field.dart';
import 'settings_screen.dart';

class BulkAddWordScreen extends ConsumerStatefulWidget {
  final int workspaceId;

  const BulkAddWordScreen({super.key, required this.workspaceId});

  @override
  ConsumerState<BulkAddWordScreen> createState() => _BulkAddWordScreenState();
}

class _BulkAddWordScreenState extends ConsumerState<BulkAddWordScreen> {
  static const _maxWords = 5;

  final _inputController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  List<String> _parseWords() {
    final seen = <String>{};
    final words = <String>[];
    for (final raw in _inputController.text.split(',')) {
      final word = raw.trim();
      if (word.isEmpty) continue;
      if (seen.add(word.toLowerCase())) words.add(word);
    }
    return words;
  }

  Future<void> _submit() async {
    final words = _parseWords();
    if (words.isEmpty) return;
    if (words.length > _maxWords) {
      setState(() {
        _validationError =
            'En fazla $_maxWords kelime ekleyebilirsin. Şu an ${words.length} kelime girdin.';
      });
      return;
    }
    setState(() => _validationError = null);
    await ref
        .read(bulkAddWordControllerProvider.notifier)
        .addWords(words, widget.workspaceId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulkAddWordControllerProvider);
    final showForm = !state.isProcessing && state.results.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.bulkAddTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showForm) ...[
              WortTextField(
                controller: _inputController,
                label: AppStrings.bulkAddInputLabel,
                maxLines: 4,
              ),
              const SizedBox(height: AppSizes.xs),
              Text(AppStrings.bulkAddMaxHint, style: AppTextStyles.caption),
              if (_validationError != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  _validationError!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ],
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
                  AppStrings.bulkAddStart,
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
              ),
            ],
            if (state.blockingError != null) ...[
              const SizedBox(height: AppSizes.md),
              Text(
                state.blockingError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
              if (state.needsApiKey) ...[
                const SizedBox(height: AppSizes.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Text(AppStrings.goToSettings,
                        style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ],
            if (state.results.isNotEmpty) ...[
              const SizedBox(height: AppSizes.md),
              Text(
                state.isProcessing
                    ? '${state.processedCount} / ${state.results.length} kelime işlendi'
                    : '${state.addedCount} / ${state.results.length} kelime eklendi',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: ListView.builder(
                  itemCount: state.results.length,
                  itemBuilder: (context, index) => _ResultTile(result: state.results[index]),
                ),
              ),
              if (state.isFinished) ...[
                const SizedBox(height: AppSizes.md),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    AppStrings.bulkAddDone,
                    style: AppTextStyles.title.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final BulkWordResult result;

  const _ResultTile({required this.result});

  (IconData, Color, String) get _statusInfo {
    switch (result.status) {
      case BulkWordStatus.added:
        return (Icons.check_circle, AppColors.das, AppStrings.bulkAddStatusAdded);
      case BulkWordStatus.duplicate:
        return (Icons.info_outline, AppColors.textSecondary, AppStrings.bulkAddStatusDuplicate);
      case BulkWordStatus.error:
        return (Icons.cancel, AppColors.die, AppStrings.bulkAddStatusError);
      case BulkWordStatus.checking:
        return (Icons.hourglass_top, AppColors.primary, AppStrings.bulkAddStatusChecking);
      case BulkWordStatus.pending:
        return (Icons.schedule, AppColors.textMuted, AppStrings.bulkAddStatusPending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _statusInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          result.status == BulkWordStatus.checking
              ? SizedBox(
                  width: AppSizes.iconMd,
                  height: AppSizes.iconMd,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              : Icon(icon, color: color, size: AppSizes.iconMd),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.word, style: AppTextStyles.body),
                Text(
                  result.errorMessage ?? label,
                  style: AppTextStyles.caption.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
