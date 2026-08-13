import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';
import '../models/workspace.dart';
import '../providers/word_provider.dart';
import '../providers/workspace_provider.dart';
import '../widgets/word_progress_card.dart';
import '../widgets/wort_text_field.dart';
import 'workspace_word_type_screen.dart';

// "Benim Çalışma Alanım" altındaki çalışma alanlarının listesi. Varsayılan
// çalışma alanı (seeder ile gelen kelimeler) burada, kullanıcının kendi
// oluşturduğu çalışma alanlarıyla birlikte listelenir.
class WorkspacesScreen extends ConsumerWidget {
  const WorkspacesScreen({super.key});

  Future<void> _showCreateWorkspaceDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(AppStrings.newWorkspaceDialogTitle, style: AppTextStyles.title),
        content: WortTextField(
          controller: nameController,
          label: AppStrings.workspaceNameLabel,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, nameController.text.trim()),
            child: Text(
              AppStrings.create,
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    await ref.read(workspaceControllerProvider).createWorkspace(name);
  }

  Future<void> _confirmDeleteWorkspace(
    BuildContext context,
    WidgetRef ref,
    Workspace workspace,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(AppStrings.deleteWorkspaceTitle, style: AppTextStyles.title),
        content: Text(
          '"${workspace.name}" ve içindeki tüm kelimeler silinecek. '
          'Bu işlem geri alınamaz.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              AppStrings.delete,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(workspaceControllerProvider).deleteWorkspace(workspace.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacesAsync = ref.watch(workspacesProvider);
    final wordsAsync = ref.watch(wordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myWorkspace)),
      body: workspacesAsync.when(
        data: (workspaces) {
          final words = wordsAsync.value ?? const <Word>[];
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: workspaces.length,
            itemBuilder: (context, index) {
              final workspace = workspaces[index];
              final workspaceWords = words
                  .where((w) => w.level == null && w.workspaceId == workspace.id)
                  .toList();
              final difficult = workspaceWords
                  .where((w) => w.category == WordCategory.difficult)
                  .length;
              final learned = workspaceWords
                  .where((w) => w.category == WordCategory.wellLearned)
                  .length;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: Row(
                  children: [
                    Expanded(
                      child: WordProgressCard(
                        label: workspace.name,
                        icon: workspace.isDefault ? Icons.star_outline : Icons.folder_outlined,
                        accentColor: workspace.isDefault ? AppColors.primary : AppColors.das,
                        total: workspaceWords.length,
                        difficult: difficult,
                        learned: learned,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkspaceWordTypeScreen(
                              workspaceId: workspace.id!,
                              title: workspace.name,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!workspace.isDefault) ...[
                      const SizedBox(width: AppSizes.sm),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
                        onPressed: () => _confirmDeleteWorkspace(context, ref, workspace),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Hata: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateWorkspaceDialog(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppStrings.newWorkspace,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
