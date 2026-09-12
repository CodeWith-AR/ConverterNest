import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/app_chip.dart';
import '../viewmodels/audio_converter_viewmodel.dart';

/// Collapsible advanced options for audio converter.
class AudioOptionsSheet extends StatefulWidget {
  const AudioOptionsSheet({super.key});

  @override
  State<AudioOptionsSheet> createState() => _AudioOptionsSheetState();
}

class _AudioOptionsSheetState extends State<AudioOptionsSheet> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AudioConverterViewModel>();
    final opts = vm.options;

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
                      // Bitrate
                      const Text('Bitrate', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Wrap(
                        spacing: AppDimens.sm,
                        children: ['64k', '128k', '192k', '256k', '320k']
                            .map(
                              (br) => AppChip(
                                label: br,
                                isSelected: opts.bitrate == br,
                                onTap: () => vm.updateBitrate(br),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Sample Rate
                      const Text('Sample Rate', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Wrap(
                        spacing: AppDimens.sm,
                        children: [22050, 44100, 48000]
                            .map(
                              (sr) => AppChip(
                                label: '${sr ~/ 1000}kHz',
                                isSelected: opts.sampleRate == sr,
                                onTap: () => vm.updateSampleRate(sr),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Channels
                      const Text('Channels', style: AppTextStyles.label),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          AppChip(
                              label: 'Mono',
                              isSelected: opts.channels == 1,
                              onTap: () => vm.updateChannels(1)),
                          const SizedBox(width: AppDimens.sm),
                          AppChip(
                              label: 'Stereo',
                              isSelected: opts.channels == 2,
                              onTap: () => vm.updateChannels(2)),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Volume
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Volume', style: AppTextStyles.label),
                          Text(
                            '${opts.volume.toStringAsFixed(1)}x',
                            style: AppTextStyles.statMd
                                .copyWith(color: AppColors.primary),
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
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: opts.volume,
                          min: 0.5,
                          max: 2.0,
                          divisions: 6,
                          onChanged: (v) => vm.updateVolume(v),
                        ),
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
