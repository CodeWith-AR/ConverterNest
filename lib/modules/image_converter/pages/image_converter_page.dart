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
import '../viewmodels/image_converter_viewmodel.dart';
import '../widgets/format_selector_grid.dart';
import '../widgets/image_options_sheet.dart';
import '../../shared/models/conversion_result_data.dart';
import '../../../app/routes/app_routes.dart';

class ImageConverterPage extends StatelessWidget {
  const ImageConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImageConverterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const AppBarWidget(
                  title: 'Image Converter',
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.screenH,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimens.sm),

                        // [1] File picker / preview
                        if (vm.selectedFile == null)
                          DragDropZone(
                            onTap: () => _pickFile(context),
                            title: 'Select an image',
                            subtitle: 'JPG, PNG, WebP, BMP, GIF, TIFF, TGA',
                          )
                        else
                          FilePreviewCard(
                            fileName: vm.selectedFile!.path
                                .split(Platform.pathSeparator)
                                .last,
                            sizeBytes: vm.inputSizeBytes,
                            format: vm.selectedFile!.path.split('.').last,
                            accentColor: AppColors.accentImage,
                            onRemove: vm.reset,
                          ),
                        const SizedBox(height: AppDimens.xl),

                        // [2] Format selector
                        if (vm.selectedFile != null) ...[
                          const Text(
                            'Convert to',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppDimens.md),
                          FormatSelectorGrid(
                            formats: ImageConverterViewModel.supportedFormats,
                            selected: vm.selectedOutputFormat,
                            onSelected: vm.setOutputFormat,
                            accentColor: AppColors.accentImage,
                          ),
                          const SizedBox(height: AppDimens.xl),

                          // [3] Advanced Options
                          const ImageOptionsSheet(),
                          const SizedBox(height: AppDimens.xl),

                          // [4] Privacy note
                          Row(
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                color: AppColors.textSecondary,
                                size: AppDimens.iconSm,
                              ),
                              const SizedBox(width: AppDimens.sm),
                              Text(
                                AppStrings.privacyNote,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.xl),

                          // [5] Convert button
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

          // Loading overlay
          if (vm.state == ImageConverterState.converting)
            const AppLoader(message: 'Converting image...'),
        ],
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      if (!context.mounted) return;
      context
          .read<ImageConverterViewModel>()
          .setFile(File(result.files.single.path!));
    }
  }

  Future<void> _convert(BuildContext context) async {
    final vm = context.read<ImageConverterViewModel>();
    await vm.convert();

    if (!context.mounted) return;

    if (vm.state == ImageConverterState.done && vm.resultFile != null) {
      context.push(AppRoutes.conversionResult,
          extra: ConversionResultData(
            outputFile: vm.resultFile!,
            inputFormat: vm.selectedFile!.path.split('.').last,
            outputFormat: vm.selectedOutputFormat!.toLowerCase(),
            inputSizeBytes: vm.inputSizeBytes,
            outputSizeBytes: await vm.resultFile!.length(),
            durationMs: vm.lastDurationMs,
            category: 'image',
            inputFileName:
                vm.selectedFile!.path.split(Platform.pathSeparator).last,
          ));
    } else if (vm.state == ImageConverterState.error) {
      AppToast.show(
        context,
        vm.error?.message ?? AppStrings.stateFailed,
        type: ToastType.error,
      );
    }
  }
}
