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
import '../../../core/utils/formatters.dart';
import '../viewmodels/archive_viewmodel.dart';
import '../../shared/models/conversion_result_data.dart';
import '../../../app/routes/app_routes.dart';

class ArchiveManagerPage extends StatelessWidget {
  const ArchiveManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ArchiveViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const AppBarWidget(
                    title: 'Archive Manager', showBackButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimens.sm),

                        // Mode selector
                        Row(
                          children: [
                            Expanded(
                              child: AppChip(
                                label: 'Create Archive',
                                isSelected: vm.mode == ArchiveMode.create,
                                onTap: () => vm.setMode(ArchiveMode.create),
                              ),
                            ),
                            const SizedBox(width: AppDimens.sm),
                            Expanded(
                              child: AppChip(
                                label: 'Extract Archive',
                                isSelected: vm.mode == ArchiveMode.extract,
                                onTap: () => vm.setMode(ArchiveMode.extract),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.xl),

                        if (vm.mode == ArchiveMode.create)
                          ..._buildCreateMode(context, vm),
                        if (vm.mode == ArchiveMode.extract)
                          ..._buildExtractMode(context, vm),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (vm.state == ArchiveState.processing)
            const AppLoader(message: 'Processing archive...'),
        ],
      ),
    );
  }

  List<Widget> _buildCreateMode(BuildContext context, ArchiveViewModel vm) {
    return [
      if (vm.selectedFiles.isEmpty)
        DragDropZone(
          onTap: () => _pickMultipleFiles(context),
          title: 'Select files to compress',
          subtitle: 'Create ZIP, TAR archives from any files',
        )
      else ...[
        AppButton.secondary(
          label: 'Add More Files',
          onPressed: () => _pickMultipleFiles(context),
        ),
        const SizedBox(height: AppDimens.md),
      ],

      // Selected files list
      if (vm.selectedFiles.isNotEmpty) ...[
        ...vm.selectedFiles.asMap().entries.map((entry) {
          final file = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.sm),
            child: FilePreviewCard(
              fileName: file.path.split(Platform.pathSeparator).last,
              sizeBytes: file.lengthSync(),
              format: file.path.split('.').last,
              accentColor: AppColors.accentArchive,
              onRemove: () => vm.removeFile(entry.key),
            ),
          );
        }),

        // Summary
        Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${vm.selectedFiles.length} files',
                  style: AppTextStyles.statSm),
              Text(Formatters.fileSize(vm.totalSizeBytes),
                  style:
                      AppTextStyles.statSm.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),

        // Archive name
        const Text('Archive name', style: AppTextStyles.label),
        const SizedBox(height: AppDimens.sm),
        AppTextField(
          initialValue: vm.archiveName,
          onChanged: vm.setArchiveName,
          hint: 'my_archive',
        ),
        const SizedBox(height: AppDimens.md),

        // Output format
        const Text('Format', style: AppTextStyles.label),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: ['ZIP', 'TAR']
              .map((fmt) => Padding(
                    padding: const EdgeInsets.only(right: AppDimens.sm),
                    child: AppChip(
                      label: fmt,
                      isSelected: vm.outputFormat == fmt,
                      onTap: () => vm.setOutputFormat(fmt),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppDimens.xl),

        AppButton.primary(
          label: 'Create Archive',
          onPressed: vm.canCreate ? () => _createArchive(context) : null,
        ),
        const SizedBox(height: AppDimens.x2l),
      ],
    ];
  }

  List<Widget> _buildExtractMode(BuildContext context, ArchiveViewModel vm) {
    return [
      if (vm.archiveFile == null)
        DragDropZone(
          onTap: () => _pickArchiveFile(context),
          title: 'Select an archive',
          subtitle: 'ZIP, TAR, GZ, TGZ, BZ2, XZ, 7Z',
        )
      else ...[
        FilePreviewCard(
          fileName: vm.archiveFile!.path.split(Platform.pathSeparator).last,
          sizeBytes: vm.archiveFile!.lengthSync(),
          format: vm.archiveFile!.path.split('.').last,
          accentColor: AppColors.accentArchive,
          onRemove: vm.reset,
        ),
        const SizedBox(height: AppDimens.md),

        // Archive contents preview
        if (vm.archiveContents.isNotEmpty) ...[
          const Text('Contents', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimens.sm),
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...vm.archiveContents.take(10).map((name) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            name.endsWith('/')
                                ? Icons.folder_rounded
                                : Icons.insert_drive_file_rounded,
                            color: AppColors.textSecondary,
                            size: AppDimens.iconSm,
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                              child: Text(name,
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    )),
                if (vm.archiveContents.length > 10)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.sm),
                    child: Text(
                      '... and ${vm.archiveContents.length - 10} more files',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimens.xl),

        AppButton.primary(
          label: 'Extract All',
          onPressed: vm.canExtract ? () => _extractArchive(context) : null,
        ),
        const SizedBox(height: AppDimens.x2l),
      ],
    ];
  }

  Future<void> _pickMultipleFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && context.mounted) {
      context.read<ArchiveViewModel>().addFiles(
            result.files
                .where((f) => f.path != null)
                .map((f) => File(f.path!))
                .toList(),
          );
    }
  }

  Future<void> _pickArchiveFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'tar', 'gz', 'bz2', 'gzip'],
    );
    if (result != null && result.files.single.path != null && context.mounted) {
      await context
          .read<ArchiveViewModel>()
          .setArchiveFile(File(result.files.single.path!));
    }
  }

  Future<void> _createArchive(BuildContext context) async {
    final vm = context.read<ArchiveViewModel>();
    await vm.createArchive();
    if (!context.mounted) return;

    if (vm.state == ArchiveState.done && vm.resultArchive != null) {
      context.push(AppRoutes.conversionResult,
          extra: ConversionResultData(
            outputFile: vm.resultArchive!,
            inputFormat: '${vm.selectedFiles.length} files',
            outputFormat: vm.outputFormat.toLowerCase(),
            inputSizeBytes: vm.totalSizeBytes,
            outputSizeBytes: await vm.resultArchive!.length(),
            durationMs: vm.lastDurationMs,
            category: 'archive',
            inputFileName: '${vm.archiveName}.${vm.outputFormat.toLowerCase()}',
          ));
    } else if (vm.state == ArchiveState.error) {
      AppToast.show(context, vm.error?.message ?? AppStrings.stateFailed,
          type: ToastType.error);
    }
  }

  Future<void> _extractArchive(BuildContext context) async {
    final vm = context.read<ArchiveViewModel>();
    await vm.extractArchive();
    if (!context.mounted) return;

    if (vm.state == ArchiveState.done) {
      AppToast.show(
          context, 'Extracted to ${vm.extractedDir?.path ?? "folder"}',
          type: ToastType.success);
    } else if (vm.state == ArchiveState.error) {
      AppToast.show(context, vm.error?.message ?? AppStrings.stateFailed,
          type: ToastType.error);
    }
  }
}
