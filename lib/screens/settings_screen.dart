import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscure = true;
  bool _prefilled = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(apiKeyProvider);
    final state = ref.watch(apiKeyControllerProvider);

    // Kayıtlı anahtar geldiğinde alanı bir kere doldur (kullanıcı yazarken üzerine yazma)
    apiKeyAsync.whenData((key) {
      if (!_prefilled && key != null && key.isNotEmpty) {
        _apiKeyController.text = key;
        _prefilled = true;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text(AppStrings.geminiApiKey, style: AppTextStyles.title),
          const SizedBox(height: AppSizes.sm),
          Text(AppStrings.apiKeyInfo, style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscure,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              labelText: AppStrings.geminiApiKey,
              hintText: AppStrings.geminiApiKeyHint,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          if (state.infoMessage == 'saved')
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: Text(
                AppStrings.apiKeySaved,
                style: AppTextStyles.caption.copyWith(color: AppColors.das),
              ),
            ),
          if (state.infoMessage == 'cleared')
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: Text(
                AppStrings.apiKeyCleared,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ElevatedButton(
            onPressed: state.isSaving
                ? null
                : () => ref
                    .read(apiKeyControllerProvider.notifier)
                    .save(_apiKeyController.text),
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
          const SizedBox(height: AppSizes.sm),
          TextButton(
            onPressed: () {
              _apiKeyController.clear();
              _prefilled = true;
              ref.read(apiKeyControllerProvider.notifier).clear();
            },
            child: Text(
              AppStrings.clearApiKey,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
