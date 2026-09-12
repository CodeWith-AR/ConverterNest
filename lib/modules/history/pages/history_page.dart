import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_alert_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_progress_indicator.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/app_storage_service.dart';
import 'package:open_file/open_file.dart';
import '../viewmodels/history_viewmodel.dart';
import '../widgets/history_job_tile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return SafeArea(
      child: vm.isLoading
          ? const Center(child: AppProgressIndicator.circular())
          : CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.screenH,
                      vertical: AppDimens.screenV,
                    ),
                    child: Row(
                      children: [
                        const Text(AppStrings.historyTitle,
                            style: AppTextStyles.heading1),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final res = await AppStorageService.openFolder();
                            if (res.type != ResultType.done && context.mounted) {
                              AppToast.show(
                                context,
                                'Folder: Downloads/ConverterNest/',
                                type: ToastType.info,
                              );
                            }
                          },
                          icon: const Icon(Icons.folder_open_rounded, size: 16),
                          label: const Text('Show In Folder'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.sm,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusSm),
                            ),
                            textStyle: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (vm.totalConversions > 0) ...[
                          const SizedBox(width: AppDimens.xs),
                          IconButton(
                            onPressed: () => _confirmClearAll(context, vm),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.textSecondary,
                              size: AppDimens.iconMd,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenH),
                    child: AppTextField(
                      hintText: AppStrings.historySearch,
                      prefixIcon: Icon(Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: AppDimens.iconMd),
                      onChanged: vm.setSearch,
                    ),
                  ),
                ),

                // Stats row (only when >0 jobs)
                if (vm.totalConversions > 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenH,
                        vertical: AppDimens.md,
                      ),
                      child: Row(
                        children: [
                          _StatCard(
                            value: '${vm.totalConversions}',
                            label: 'Conversions',
                          ),
                          const SizedBox(width: AppDimens.sm),
                          _StatCard(
                            value: vm.totalConversions > 0
                                ? '${(vm.successCount / vm.totalConversions * 100).toStringAsFixed(0)}%'
                                : '0%',
                            label: 'Success',
                          ),
                          const SizedBox(width: AppDimens.sm),
                          _StatCard(
                            value: Formatters.fileSize(vm.totalSavedBytes),
                            label: 'Saved',
                          ),
                        ],
                      ),
                    ),
                  ),

                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenH),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.md),
                        child: Row(
                          children: HistoryFilter.values.map((filter) {
                            final label = filter == HistoryFilter.all
                                ? 'All'
                                : filter.name[0].toUpperCase() +
                                    filter.name.substring(1);
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: AppDimens.sm),
                              child: AppChip(
                                label: label,
                                isSelected: vm.activeFilter == filter,
                                onTap: () => vm.setFilter(filter),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                // List or empty state
                if (vm.filteredJobs.isEmpty)
                  const SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.history_rounded,
                      title: AppStrings.stateNoHistory,
                      subtitle: AppStrings.stateNoHistorySub,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = vm.filteredJobs[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: AppDimens.screenH,
                            right: AppDimens.screenH,
                            bottom: index == vm.filteredJobs.length - 1
                                ? AppDimens.x2l
                                : AppDimens.sm,
                          ),
                          child: HistoryJobTile(
                            job: job,
                            onDelete: () {
                              vm.deleteJob(job.id);
                              AppToast.show(
                                  context, 'Deleted ${job.inputFileName}',
                                  type: ToastType.info);
                            },
                          ),
                        );
                      },
                      childCount: vm.filteredJobs.length,
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _confirmClearAll(
      BuildContext context, HistoryViewModel vm) async {
    final confirmed = await AppAlertDialog.show(
      context: context,
      title: AppStrings.historyClearAll,
      message: AppStrings.historyClearSub,
      confirmLabel: AppStrings.actionClear,
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      await vm.clearAll();
      if (context.mounted) {
        AppToast.show(context, 'History cleared', type: ToastType.success);
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppDimens.md, horizontal: AppDimens.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: AppTextStyles.statLg.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppDimens.xs),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
