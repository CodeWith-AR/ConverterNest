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
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/drag_drop_zone.dart';
import '../../../core/widgets/file_preview_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_text_field.dart';
import '../viewmodels/pdf_tools_viewmodel.dart';
import '../../shared/models/conversion_result_data.dart';
import '../../../app/routes/app_routes.dart';

class PdfToolsPage extends StatelessWidget {
  const PdfToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PdfToolsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const AppBarWidget(title: 'PDF Tools', showBackButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimens.sm),

                        // Mode selector
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _ModeChip(
                                  icon: Icons.image_rounded,
                                  label: 'Images → PDF',
                                  isSelected:
                                      vm.mode == PdfToolMode.imagesToPdf,
                                  onTap: () =>
                                      vm.setMode(PdfToolMode.imagesToPdf)),
                              const SizedBox(width: AppDimens.sm),
                              _ModeChip(
                                  icon: Icons.photo_library_rounded,
                                  label: 'PDF → Images',
                                  isSelected:
                                      vm.mode == PdfToolMode.pdfToImages,
                                  onTap: () =>
                                      vm.setMode(PdfToolMode.pdfToImages)),
                              const SizedBox(width: AppDimens.sm),
                              _ModeChip(
                                  icon: Icons.merge_type_rounded,
                                  label: 'Merge',
                                  isSelected: vm.mode == PdfToolMode.mergePdfs,
                                  onTap: () =>
                                      vm.setMode(PdfToolMode.mergePdfs)),
                              const SizedBox(width: AppDimens.sm),
                              _ModeChip(
                                  icon: Icons.content_cut_rounded,
                                  label: 'Split',
                                  isSelected: vm.mode == PdfToolMode.splitPdf,
                                  onTap: () =>
                                      vm.setMode(PdfToolMode.splitPdf)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimens.xl),

                        if (vm.mode == PdfToolMode.imagesToPdf)
                          ..._buildImagesToPdf(context, vm),
                        if (vm.mode == PdfToolMode.pdfToImages)
                          ..._buildPdfToImages(context, vm),
                        if (vm.mode == PdfToolMode.mergePdfs)
                          ..._buildMergePdfs(context, vm),
                        if (vm.mode == PdfToolMode.splitPdf)
                          ..._buildSplitPdf(context, vm),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (vm.state == PdfToolsState.processing)
            const AppLoader(message: 'Processing PDF...'),
        ],
      ),
    );
  }

  List<Widget> _buildImagesToPdf(BuildContext context, PdfToolsViewModel vm) {
    return [
      AppButton.secondary(
        label: 'Add Images',
        onPressed: () => _pickImages(context),
      ),
      const SizedBox(height: AppDimens.md),
      if (vm.selectedImages.isNotEmpty) ...[
        ...vm.selectedImages.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.sm),
              child: FilePreviewCard(
                fileName: entry.value.path.split(Platform.pathSeparator).last,
                sizeBytes: entry.value.lengthSync(),
                format: entry.value.path.split('.').last,
                accentColor: AppColors.accentPdf,
                onRemove: () => vm.removeImage(entry.key),
              ),
            )),
        const SizedBox(height: AppDimens.md),
        const Text('Page Format', style: AppTextStyles.label),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: ['A4', 'Letter']
              .map((fmt) => Padding(
                    padding: const EdgeInsets.only(right: AppDimens.sm),
                    child: AppChip(
                        label: fmt,
                        isSelected: vm.pageFormat == fmt,
                        onTap: () => vm.setPageFormat(fmt)),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppDimens.xl),
        AppButton.primary(
          label: 'Create PDF',
          onPressed:
              vm.selectedImages.isNotEmpty ? () => _execute(context) : null,
        ),
        const SizedBox(height: AppDimens.x2l),
      ],
    ];
  }

  List<Widget> _buildPdfToImages(BuildContext context, PdfToolsViewModel vm) {
    return [
      if (vm.selectedPdf == null)
        DragDropZone(
          onTap: () => _pickPdf(context, forMode: PdfToolMode.pdfToImages),
          title: 'Select a PDF',
          subtitle: 'Each page will be converted to an image',
        )
      else ...[
        FilePreviewCard(
          fileName: vm.selectedPdf!.path.split(Platform.pathSeparator).last,
          sizeBytes: vm.selectedPdf!.lengthSync(),
          format: 'pdf',
          accentColor: AppColors.accentPdf,
          onRemove: vm.reset,
        ),
        if (vm.totalPages != null) ...[
          const SizedBox(height: AppDimens.sm),
          Text('${vm.totalPages} pages',
              style: AppTextStyles.statMd.copyWith(color: AppColors.primary)),
        ],
        const SizedBox(height: AppDimens.md),
        const Text('Output Format', style: AppTextStyles.label),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: ['JPG', 'PNG']
              .map((fmt) => Padding(
                    padding: const EdgeInsets.only(right: AppDimens.sm),
                    child: AppChip(
                        label: fmt,
                        isSelected: vm.outputImageFormat == fmt.toLowerCase(),
                        onTap: () =>
                            vm.setOutputImageFormat(fmt.toLowerCase())),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppDimens.md),
        const Text('DPI', style: AppTextStyles.label),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: [72, 150, 300]
              .map((d) => Padding(
                    padding: const EdgeInsets.only(right: AppDimens.sm),
                    child: AppChip(
                        label: '${d}dpi',
                        isSelected: vm.dpi == d,
                        onTap: () => vm.setDpi(d)),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppDimens.xl),
        AppButton.primary(
          label: 'Convert to Images',
          onPressed: () => _execute(context),
        ),
        const SizedBox(height: AppDimens.x2l),
      ],
    ];
  }

  List<Widget> _buildMergePdfs(BuildContext context, PdfToolsViewModel vm) {
    return [
      AppButton.secondary(
        label: 'Add PDFs',
        onPressed: () => _pickMultiplePdfs(context),
      ),
      const SizedBox(height: AppDimens.md),
      if (vm.selectedPdfs.isNotEmpty) ...[
        ...vm.selectedPdfs.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.sm),
              child: FilePreviewCard(
                fileName: entry.value.path.split(Platform.pathSeparator).last,
                sizeBytes: entry.value.lengthSync(),
                format: 'pdf',
                accentColor: AppColors.accentPdf,
                onRemove: () => vm.removePdf(entry.key),
              ),
            )),
        const SizedBox(height: AppDimens.xl),
        AppButton.primary(
          label: 'Merge PDFs',
          onPressed:
              vm.selectedPdfs.length >= 2 ? () => _execute(context) : null,
        ),
        const SizedBox(height: AppDimens.x2l),
      ],
    ];
  }

  List<Widget> _buildSplitPdf(BuildContext context, PdfToolsViewModel vm) {
    return [
      if (vm.splitPdfFile == null)
        DragDropZone(
          onTap: () => _pickPdf(context, forMode: PdfToolMode.splitPdf),
          title: 'Select a PDF to split',
          subtitle: 'Extract specific page ranges',
        )
      else ...[
        FilePreviewCard(
          fileName: vm.splitPdfFile!.path.split(Platform.pathSeparator).last,
          sizeBytes: vm.splitPdfFile!.lengthSync(),
          format: 'pdf',
          accentColor: AppColors.accentPdf,
          onRemove: vm.reset,
        ),
        if (vm.splitTotalPages != null) ...[
          const SizedBox(height: AppDimens.sm),
          Text('${vm.splitTotalPages} total pages',
              style: AppTextStyles.statMd.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Page', style: AppTextStyles.label),
                    const SizedBox(height: AppDimens.sm),
                    AppTextField(
                      initialValue: vm.startPage.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = int.tryParse(v);
                        if (val != null) vm.setStartPage(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Page', style: AppTextStyles.label),
                    const SizedBox(height: AppDimens.sm),
                    AppTextField(
                      initialValue: vm.endPage.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = int.tryParse(v);
                        if (val != null) vm.setEndPage(val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Will extract pages ${vm.startPage}–${vm.endPage} (${vm.endPage - vm.startPage + 1} pages)',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: AppDimens.xl),
        AppButton.primary(
          label: 'Extract Pages',
          onPressed: vm.splitPdfFile != null ? () => _execute(context) : null,
        ),
        const SizedBox(height: AppDimens.x2l),
      ],
    ];
  }

  Future<void> _pickImages(BuildContext context) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null && context.mounted) {
      context.read<PdfToolsViewModel>().addImages(
            result.files
                .where((f) => f.path != null)
                .map((f) => File(f.path!))
                .toList(),
          );
    }
  }

  Future<void> _pickPdf(BuildContext context,
      {required PdfToolMode forMode}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null && context.mounted) {
      final file = File(result.files.single.path!);
      final vm = context.read<PdfToolsViewModel>();
      if (forMode == PdfToolMode.pdfToImages) {
        await vm.setPdfFile(file);
      } else {
        await vm.setSplitPdf(file);
      }
    }
  }

  Future<void> _pickMultiplePdfs(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result != null && context.mounted) {
      context.read<PdfToolsViewModel>().addPdfs(
            result.files
                .where((f) => f.path != null)
                .map((f) => File(f.path!))
                .toList(),
          );
    }
  }

  Future<void> _execute(BuildContext context) async {
    final vm = context.read<PdfToolsViewModel>();
    await vm.execute();
    if (!context.mounted) return;

    if (vm.state == PdfToolsState.done) {
      if (vm.resultFile != null) {
        context.push(AppRoutes.conversionResult,
            extra: ConversionResultData(
              outputFile: vm.resultFile!,
              inputFormat: 'PDF',
              outputFormat: 'PDF',
              inputSizeBytes: 0,
              outputSizeBytes: await vm.resultFile!.length(),
              durationMs: vm.lastDurationMs,
              category: 'pdf',
              inputFileName: 'PDF Tools',
            ));
      } else {
        AppToast.show(context, 'Converted ${vm.resultFiles?.length ?? 0} pages',
            type: ToastType.success);
      }
    } else if (vm.state == PdfToolsState.error) {
      AppToast.show(context, vm.error?.message ?? AppStrings.stateFailed,
          type: ToastType.error);
    }
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md, vertical: AppDimens.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: AppDimens.iconSm,
                color:
                    isSelected ? AppColors.onPrimary : AppColors.textSecondary),
            const SizedBox(width: AppDimens.xs),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
