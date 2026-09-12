import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_motion.dart';
import 'app_progress_indicator.dart';

/// Conversion progress card — shows file name, status, and animated progress bar.
class ConversionProgressCard extends StatelessWidget {
  final String fileName;
  final String statusText;
  final double progress; // 0.0 to 1.0
  final Color? accentColor;

  const ConversionProgressCard({
    super.key,
    required this.fileName,
    required this.statusText,
    required this.progress,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimens.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName,
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.statSm.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(statusText, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppDimens.md),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: AppMotion.progress,
            curve: AppMotion.progressCurve,
            builder: (context, value, _) {
              return AppProgressIndicator.linear(
                value: value,
                color: color,
                height: 4,
              );
            },
          ),
        ],
      ),
    );
  }
}
