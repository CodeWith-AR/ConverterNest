import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/app_chip.dart';
import '../viewmodels/image_converter_viewmodel.dart';

/// Collapsible advanced options panel for image converter.
class ImageOptionsSheet extends StatefulWidget {
  const ImageOptionsSheet({super.key});

  @override
  State<ImageOptionsSheet> createState() => _ImageOptionsSheetState();
}

class _ImageOptionsSheetState extends State<ImageOptionsSheet> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImageConverterViewModel>();
    final opts = vm.options;
    final isLossy =
        vm.selectedOutputFormat == 'JPG' || vm.selectedOutputFormat == 'WebP';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.base,
              vertical: AppDimens.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: AppColors.textSecondary,
                  size: AppDimens.iconMd,
                ),
                const SizedBox(width: AppDimens.md),
                const Text('Advanced Options', style: AppTextStyles.heading3),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: AppMotion.controlState,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.branchSlide,
          curve: AppMotion.slideCurve,
          child: _expanded
              ? Container(
                  margin: const EdgeInsets.only(top: AppDimens.sm),
                  padding: const EdgeInsets.all(AppDimens.base),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quality slider (only for lossy formats)
                      if (isLossy) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quality', style: AppTextStyles.label),
                            Text(
                              '${opts.quality}%',
                              style: AppTextStyles.statMd.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.sm),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.surfaceElevated,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primaryGlow,
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                          ),
                          child: Slider(
                            value: opts.quality.toDouble(),
                            min: 10,
                            max: 100,
                            divisions: 9,
                            onChanged: (v) => vm.updateQuality(v.toInt()),
                          ),
                        ),
                        const SizedBox(height: AppDimens.md),
                      ],

                      // Rotation
                      const Text('Rotate', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          for (final deg in [0, 90, 180, 270])
                            Padding(
                              padding: const EdgeInsets.only(
                                right: AppDimens.sm,
                              ),
                              child: AppChip(
                                label: '$deg°',
                                isSelected: opts.rotationDegrees == deg,
                                onTap: () => vm.updateRotation(deg),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Flip
                      const Text('Flip', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          AppChip(
                            label: 'Horizontal',
                            isSelected: opts.flipH,
                            onTap: vm.toggleFlipH,
                          ),
                          const SizedBox(width: AppDimens.sm),
                          AppChip(
                            label: 'Vertical',
                            isSelected: opts.flipV,
                            onTap: vm.toggleFlipV,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
