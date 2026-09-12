import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/drag_drop_zone.dart';
import '../../../core/widgets/file_preview_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../image_converter/widgets/format_selector_grid.dart';
import '../viewmodels/text_converter_viewmodel.dart';
import '../../shared/models/conversion_result_data.dart';
import '../../../app/routes/app_routes.dart';

class TextConverterPage extends StatelessWidget {
  const TextConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TextConverterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const AppBarWidget(
                    title: 'Text & Data Converter', showBackButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimens.sm),

                        // Input format tabs
                        const Text('Input format',
                            style: AppTextStyles.heading3),
                        const SizedBox(height: AppDimens.sm),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: TextConverterViewModel.inputFormats
                                .map(
                                  (fmt) => Padding(
                                    padding: const EdgeInsets.only(
                                        right: AppDimens.sm),
                                    child: AppChip(
                                      label: fmt,
                                      isSelected: vm.selectedInputFormat == fmt,
                                      onTap: () => vm.setInputFormat(fmt),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: AppDimens.xl),

                        // Mode toggle
                        if (vm.selectedInputFormat != null) ...[
                          Row(
                            children: [
                              AppChip(
                                label: 'Pick File',
                                isSelected: !vm.isPasteMode,
                                onTap: () => vm.setPasteMode(false),
                              ),
                              const SizedBox(width: AppDimens.sm),
                              AppChip(
                                label: 'Paste Text',
                                isSelected: vm.isPasteMode,
                                onTap: () => vm.setPasteMode(true),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.md),

                          if (vm.isPasteMode)
                            AppTextField(
                              maxLines: 8,
                              hint:
                                  'Paste your ${vm.selectedInputFormat} content here...',
                              onChanged: vm.setPastedText,
                            )
                          else if (vm.selectedFile == null)
                            DragDropZone(
                              onTap: () => _pickFile(context),
                              title: 'Select a ${vm.selectedInputFormat} file',
                              subtitle: 'Tap to browse',
                            )
                          else
                            FilePreviewCard(
                              fileName: vm.selectedFile!.path
                                  .split(Platform.pathSeparator)
                                  .last,
                              sizeBytes: vm.inputSizeBytes,
                              format: vm.selectedFile!.path.split('.').last,
                              accentColor: AppColors.accentText,
                              onRemove: vm.reset,
                            ),
                          const SizedBox(height: AppDimens.xl),

                          // Output format selector
                          if (vm.availableOutputFormats.isNotEmpty) ...[
                            const Text('Convert to',
                                style: AppTextStyles.heading3),
                            const SizedBox(height: AppDimens.sm),
                            FormatSelectorGrid(
                              formats: vm.availableOutputFormats,
                              selected: vm.selectedOutputFormat,
                              onSelected: vm.setOutputFormat,
                              accentColor: AppColors.accentText,
                            ),
                            const SizedBox(height: AppDimens.xl),
                          ],

                          // Preview section
                          if (vm.preview.isNotEmpty) ...[
                            _PreviewSection(preview: vm.preview),
                            const SizedBox(height: AppDimens.xl),
                          ],

                          // Privacy note
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
          if (vm.state == TextConverterState.converting)
            const AppLoader(message: 'Converting text...'),
        ],
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    final vm = context.read<TextConverterViewModel>();
    final ext = vm.selectedInputFormat?.toLowerCase();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          ext != null ? [ext] : ['txt', 'md', 'html', 'csv', 'json', 'xml'],
    );
    if (result != null && result.files.single.path != null && context.mounted) {
      vm.setFile(File(result.files.single.path!));
    }
  }

  Future<void> _convert(BuildContext context) async {
    final vm = context.read<TextConverterViewModel>();
    await vm.convert();
    if (!context.mounted) return;

    if (vm.state == TextConverterState.done && vm.resultFile != null) {
      context.push(AppRoutes.conversionResult,
          extra: ConversionResultData(
            outputFile: vm.resultFile!,
            inputFormat: vm.selectedInputFormat!.toLowerCase(),
            outputFormat: vm.selectedOutputFormat!.toLowerCase(),
            inputSizeBytes: vm.inputSizeBytes,
            outputSizeBytes: await vm.resultFile!.length(),
            durationMs: vm.lastDurationMs,
            category: 'text',
            inputFileName: vm.isPasteMode
                ? 'Pasted text'
                : vm.selectedFile!.path.split(Platform.pathSeparator).last,
          ));
    } else if (vm.state == TextConverterState.error) {
      AppToast.show(context, vm.error?.message ?? AppStrings.stateFailed,
          type: ToastType.error);
    }
  }
}

class _PreviewSection extends StatefulWidget {
  final String preview;
  const _PreviewSection({required this.preview});

  @override
  State<_PreviewSection> createState() => _PreviewSectionState();
}

class _PreviewSectionState extends State<_PreviewSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              const Text('Preview output', style: AppTextStyles.heading3),
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
        AnimatedSize(
          duration: AppMotion.branchSlide,
          curve: AppMotion.slideCurve,
          child: _expanded
              ? Container(
                  margin: const EdgeInsets.only(top: AppDimens.sm),
                  padding: const EdgeInsets.all(AppDimens.md),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    widget.preview,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontFamily: 'IBMPlexMono'),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
