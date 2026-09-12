import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../utils/formatters.dart';

/// Shows selected file info — file icon, filename, size/format badge, remove button.
class FilePreviewCard extends StatelessWidget {
  final String fileName;
  final int sizeBytes;
  final String format;
  final Color accentColor;
  final VoidCallback onRemove;

  const FilePreviewCard({
    super.key,
    required this.fileName,
    required this.sizeBytes,
    required this.format,
    required this.accentColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.iconXl,
            height: AppDimens.iconXl,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(
              Icons.insert_drive_file_rounded,
              color: accentColor,
              size: AppDimens.iconMd,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.xs),
                Row(
                  children: [
                    Text(
                      Formatters.fileSize(sizeBytes),
                      style: AppTextStyles.statSm,
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                      ),
                      child: Text(
                        format.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: AppDimens.iconSm,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
