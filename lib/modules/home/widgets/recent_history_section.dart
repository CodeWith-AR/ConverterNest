import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/file_type_detector.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:go_router/go_router.dart';

/// "Recent Conversions" header + list of last 3 items or empty state.
class RecentHistorySection extends StatelessWidget {
  const RecentHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(AppStrings.homeRecent, style: AppTextStyles.heading2),
            TextButton(
              onPressed: () {
                // Navigate to the History tab (index 1)
                final shell = StatefulNavigationShell.of(context);
                shell.goBranch(1);
              },
              child: Text(
                AppStrings.homeSeeAll,
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        if (vm.recentJobs.isEmpty)
          const AppEmptyState(
            icon: Icons.history_rounded,
            title: AppStrings.stateNoHistory,
            subtitle: AppStrings.stateNoHistorySub,
          )
        else
          ...vm.recentJobs.map((job) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.sm),
                child: _RecentJobTile(
                  fileName: job.inputFileName,
                  inputFormat: job.inputFormat,
                  outputFormat: job.outputFormat,
                  category: job.category,
                  sizeBytes: job.outputSizeBytes,
                  timeAgo: Formatters.timeAgo(job.createdAt),
                ),
              )),
      ],
    );
  }
}

class _RecentJobTile extends StatelessWidget {
  final String fileName;
  final String inputFormat;
  final String outputFormat;
  final String category;
  final int sizeBytes;
  final String timeAgo;

  const _RecentJobTile({
    required this.fileName,
    required this.inputFormat,
    required this.outputFormat,
    required this.category,
    required this.sizeBytes,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final color = FileTypeDetector.accentColorForCategory(category);
    final icon = FileTypeDetector.iconForCategory(category);

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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, color: color, size: AppDimens.iconMd),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.xs),
                Row(
                  children: [
                    _FormatBadge(
                        label: inputFormat.toUpperCase(),
                        color: AppColors.textSecondary),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ),
                    _FormatBadge(
                        label: outputFormat.toUpperCase(), color: color),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.fileSize(sizeBytes),
                style: AppTextStyles.statSm,
              ),
              const SizedBox(height: AppDimens.xs),
              Text(timeAgo, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
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
