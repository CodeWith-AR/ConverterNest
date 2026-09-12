import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../viewmodels/video_converter_viewmodel.dart';

/// Collapsible advanced options for video converter.
class VideoOptionsSheet extends StatefulWidget {
  const VideoOptionsSheet({super.key});

  @override
  State<VideoOptionsSheet> createState() => _VideoOptionsSheetState();
}

class _VideoOptionsSheetState extends State<VideoOptionsSheet> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VideoConverterViewModel>();
    final opts = vm.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.base, vertical: AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.tune_rounded,
                    color: AppColors.textSecondary, size: AppDimens.iconMd),
                const SizedBox(width: AppDimens.md),
                const Text('Advanced Options', style: AppTextStyles.heading3),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: AppMotion.controlState,
                  child: Icon(Icons.expand_more_rounded,
                      color: AppColors.textSecondary),
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
                      // Resolution
                      const Text('Resolution', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Wrap(
                        spacing: AppDimens.sm,
                        runSpacing: AppDimens.sm,
                        children: [
                          null,
                          '1920:1080',
                          '1280:720',
                          '854:480',
                          '640:360'
                        ]
                            .map(
                              (res) => AppChip(
                                label: res == null
                                    ? 'Original'
                                    : res == '1920:1080'
                                        ? '1080p'
                                        : res == '1280:720'
                                            ? '720p'
                                            : res == '854:480'
                                                ? '480p'
                                                : '360p',
                                isSelected: opts.resolution == res,
                                onTap: () => vm.updateResolution(res),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppDimens.md),

                      // FPS
                      const Text('Frame Rate', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Wrap(
                        spacing: AppDimens.sm,
                        children: [null, 60, 30, 24]
                            .map(
                              (f) => AppChip(
                                label: f == null ? 'Original' : '${f}fps',
                                isSelected: opts.fps == f,
                                onTap: () => vm.updateFps(f),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Quality (CRF)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quality', style: AppTextStyles.label),
                          Text('CRF ${opts.crf}',
                              style: AppTextStyles.statMd
                                  .copyWith(color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Best Quality',
                              style:
                                  AppTextStyles.caption.copyWith(fontSize: 10)),
                          Text('Smallest Size',
                              style:
                                  AppTextStyles.caption.copyWith(fontSize: 10)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceElevated,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primaryGlow,
                          trackHeight: 4,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: opts.crf.toDouble(),
                          min: 18,
                          max: 35,
                          divisions: 17,
                          onChanged: (v) => vm.updateCrf(v.toInt()),
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Special options
                      const Text('Special', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          AppCheckbox(
                              value: opts.extractAudioOnly,
                              onChanged: (_) => vm.toggleExtractAudio()),
                          const SizedBox(width: AppDimens.sm),
                          const Text('Extract audio only (→ MP3)',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Row(
                        children: [
                          AppCheckbox(
                              value: opts.muteVideo,
                              onChanged: (_) => vm.toggleMuteVideo()),
                          const SizedBox(width: AppDimens.sm),
                          const Text('Remove audio (mute)',
                              style: AppTextStyles.bodySmall),
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
