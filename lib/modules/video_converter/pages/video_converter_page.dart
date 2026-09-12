import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/drag_drop_zone.dart';
import '../../../core/widgets/file_preview_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../image_converter/widgets/format_selector_grid.dart';
import '../viewmodels/video_converter_viewmodel.dart';
import '../widgets/video_options_sheet.dart';
import '../../shared/models/conversion_result_data.dart';
import '../../../app/routes/app_routes.dart';

class VideoConverterPage extends StatelessWidget {
  const VideoConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VideoConverterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const AppBarWidget(
                    title: 'Video Converter', showBackButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimens.sm),

                        if (vm.selectedFile == null)
                          DragDropZone(
                            onTap: () => _pickFile(context),
                            title: 'Select a video file',
                            subtitle: 'MP4, MKV, AVI, MOV, WebM, FLV, 3GP, TS',
                          )
                        else
                          FilePreviewCard(
                            fileName: vm.selectedFile!.path
                                .split(Platform.pathSeparator)
                                .last,
                            sizeBytes: vm.inputSizeBytes,
                            format: vm.selectedFile!.path.split('.').last,
                            accentColor: AppColors.accentVideo,
                            onRemove: vm.reset,
                          ),
                        const SizedBox(height: AppDimens.md),

                        // Warning banners
                        if (vm.showBatteryWarning)
                          const _WarningBanner(
                            icon: Icons.battery_alert_rounded,
                            message: AppStrings.warnBattery,
                            color: AppColors.warning,
                          ),
                        if (vm.showLargeFileWarning)
                          const _WarningBanner(
                            icon: Icons.storage_rounded,
                            message: AppStrings.warnLargeFile,
                            color: AppColors.warning,
                          ),

                        if (vm.selectedFile != null) ...[
                          const SizedBox(height: AppDimens.md),
                          const Text('Convert to',
                              style: AppTextStyles.heading3),
                          const SizedBox(height: AppDimens.md),
                          FormatSelectorGrid(
                            formats: VideoConverterViewModel.supportedFormats,
                            selected: vm.selectedOutputFormat,
                            onSelected: vm.setOutputFormat,
                            accentColor: AppColors.accentVideo,
                          ),
                          const SizedBox(height: AppDimens.xl),

                          const VideoOptionsSheet(),
                          const SizedBox(height: AppDimens.xl),

                          // Foreground service note
                          Container(
                            padding: const EdgeInsets.all(AppDimens.md),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusMd),
                              border: Border.all(
                                  color: AppColors.info.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: AppColors.info,
                                    size: AppDimens.iconSm),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: Text(
                                    'Video conversion runs in background — safe to switch apps',
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.info),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimens.md),

                          Row(
                            children: [
                              Icon(Icons.lock_rounded,
                                  color: AppColors.textSecondary,
                                  size: AppDimens.iconSm),
                              const SizedBox(width: AppDimens.sm),
                              Text(AppStrings.privacyNote,
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: AppDimens.xl),

                          AppButton.primary(
                            label: AppStrings.actionConvert,
                            onPressed:
                                vm.canConvert ? () => _convert(context) : null,
                          ),
                          const SizedBox(height: AppDimens.x2l),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (vm.state == VideoConverterState.converting)
            const AppLoader(message: 'Converting video...'),
        ],
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null && context.mounted) {
      await context
          .read<VideoConverterViewModel>()
          .setFile(File(result.files.single.path!));
    }
  }

  Future<void> _convert(BuildContext context) async {
    final vm = context.read<VideoConverterViewModel>();
    await vm.convert();
    if (!context.mounted) return;

    if (vm.state == VideoConverterState.done && vm.resultFile != null) {
      context.push(AppRoutes.conversionResult,
          extra: ConversionResultData(
            outputFile: vm.resultFile!,
            inputFormat: vm.selectedFile!.path.split('.').last,
            outputFormat: vm.selectedOutputFormat!.toLowerCase(),
            inputSizeBytes: vm.inputSizeBytes,
            outputSizeBytes: await vm.resultFile!.length(),
            durationMs: vm.lastDurationMs,
            category: 'video',
            inputFileName:
                vm.selectedFile!.path.split(Platform.pathSeparator).last,
          ));
    } else if (vm.state == VideoConverterState.error) {
      AppToast.show(context, vm.error?.message ?? AppStrings.stateFailed,
          type: ToastType.error);
    }
  }
}

class _WarningBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _WarningBanner(
      {required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppDimens.iconSm),
          const SizedBox(width: AppDimens.sm),
          Expanded(
              child: Text(message,
                  style: AppTextStyles.caption.copyWith(color: color))),
        ],
      ),
    );
  }
}
