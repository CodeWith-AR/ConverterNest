import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/file_type_detector.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/app_storage_service.dart';
import '../../../data/models/conversion_job.dart';

/// Individual history entry tile matching stitch design.
class HistoryJobTile extends StatelessWidget {
  final ConversionJob job;
  final VoidCallback? onDelete;

  const HistoryJobTile({
    super.key,
    required this.job,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = FileTypeDetector.accentColorForCategory(job.category);
    final icon = FileTypeDetector.iconForCategory(job.category);
    final isCompleted = job.status == 'completed';

    return Dismissible(
      key: Key(job.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimens.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: InkWell(
        onTap: () => _showJobOptions(context),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Container(
              width: AppDimens.iconXl,
              height: AppDimens.iconXl,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppDimens.iconMd),
            ),
            const SizedBox(width: AppDimens.md),
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.inputFileName,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Row(
                    children: [
                      _FormatBadge(
                          label: job.inputFormat.toUpperCase(),
                          color: AppColors.textSecondary),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.textSecondary),
                      ),
                      _FormatBadge(
                          label: job.outputFormat.toUpperCase(), color: color),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xs),
                  if (isCompleted)
                    Text(
                      '${Formatters.fileSize(job.inputSizeBytes)} → ${Formatters.fileSize(job.outputSizeBytes)}  ·  ${Formatters.duration(job.durationMs)}',
                      style: AppTextStyles.statSm,
                    )
                  else
                    Text(
                      job.errorMessage ?? 'Unsupported codec error',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error),
                    ),
                ],
              ),
            ),
            // Status + time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                  ),
                  child: Text(
                    isCompleted ? 'DONE' : 'FAILED',
                    style: AppTextStyles.caption.copyWith(
                      color: isCompleted ? AppColors.success : AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.xs),
                Text(
                  Formatters.timeAgo(job.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showJobOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenH,
              vertical: AppDimens.base,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                Text(
                  job.outputFilePath.split('/').last.split('\\').last,
                  style: AppTextStyles.heading2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.xs),
                Text(
                  '${job.inputFormat.toUpperCase()} → ${job.outputFormat.toUpperCase()}  ·  ${Formatters.fileSize(job.outputSizeBytes)}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppDimens.md),
                ListTile(
                  leading:
                      const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                  title: const Text('Open File', style: AppTextStyles.bodyLarge),
                  onTap: () {
                    Navigator.pop(ctx);
                    OpenFile.open(job.outputFilePath);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.folder_open_rounded, color: AppColors.primary),
                  title:
                      const Text('Show In Folder', style: AppTextStyles.bodyLarge),
                  subtitle: const Text('Downloads/ConverterNest',
                      style: AppTextStyles.caption),
                  onTap: () {
                    Navigator.pop(ctx);
                    AppStorageService.openFolder(job.category);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.share_rounded, color: AppColors.primary),
                  title: const Text('Share File', style: AppTextStyles.bodyLarge),
                  onTap: () {
                    Navigator.pop(ctx);
                    Share.shareXFiles([XFile(job.outputFilePath)]);
                  },
                ),
                if (onDelete != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                    title: Text('Delete from History',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onDelete!();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _FormatBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimens.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
