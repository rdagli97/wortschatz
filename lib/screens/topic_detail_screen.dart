import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/topic.dart';

class TopicDetailScreen extends StatelessWidget {
  final Topic topic;

  const TopicDetailScreen({super.key, required this.topic});

  MarkdownStyleSheet _styleSheet(BuildContext context) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: AppTextStyles.body.copyWith(height: 1.5),
      h1: AppTextStyles.heading,
      h2: AppTextStyles.title.copyWith(color: AppColors.primary, fontSize: 20),
      h3: AppTextStyles.title.copyWith(color: AppColors.primary),
      strong: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
      em: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
      listBullet: AppTextStyles.body.copyWith(color: AppColors.primary),
      listIndent: AppSizes.lg,
      blockquote: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      blockquotePadding: const EdgeInsets.all(AppSizes.sm),
      code: AppTextStyles.body.copyWith(
        fontFamily: 'monospace',
        backgroundColor: AppColors.surfaceLight,
        color: AppColors.das,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      tableHead: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
      tableBody: AppTextStyles.body,
      tableBorder: TableBorder.all(color: AppColors.divider, width: 1),
      tableCellsPadding:
          const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
      tableHeadAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.keyword)),
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
          child: MarkdownBody(
            data: topic.explanation,
            selectable: true,
            styleSheet: _styleSheet(context),
          ),
        ),
      ),
    );
  }
}
