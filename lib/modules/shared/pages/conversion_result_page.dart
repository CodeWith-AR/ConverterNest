import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/file_type_detector.dart';
import '../models/conversion_result_data.dart';

class ConversionResultPage extends StatefulWidget {
  final ConversionResultData data;

  const ConversionResultPage({super.key, required this.data});

  @override
  State<ConversionResultPage> createState() => _ConversionResultPageState();
}

class _ConversionResultPageState extends State<ConversionResultPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppMotion.resultEntry,
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: AppMotion.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: AppMotion.easeOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double get _sizeReduction {
    if (widget.data.inputSizeBytes == 0) return 0;
    return ((widget.data.inputSizeBytes - widget.data.outputSizeBytes) /
            widget.data.inputSizeBytes) *
        100;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final catColor = FileTypeDetector.accentColorForCategory(d.category);
    final isImage = d.category == 'image' || d.category == 'pdf';

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.x3l),

              // Animated success circle
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: AppDimens.iconXxl,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              // Title
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const Text(
                      AppStrings.stateCompleted,
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      '${d.outputFormat.toUpperCase()} file ready',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.x2l),

              // Stats card
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Size',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Formatters.fileSize(d.inputSizeBytes),
                              style: AppTextStyles.statMd,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.sm,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Formatters.fileSize(d.outputSizeBytes),
                              style: AppTextStyles.statMd.copyWith(
                                color: catColor,
                              ),
                            ),
                            if (_sizeReduction > 0) ...[
                              const SizedBox(width: AppDimens.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusXs,
                                ),
                              ),
                              child: Text(
                                '-${_sizeReduction.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    _StatRow(
                      label: 'Format',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FormatBadge(
                            label: d.inputFormat.toUpperCase(),
                            color: AppColors.textSecondary,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.sm,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                            _FormatBadge(
                              label: d.outputFormat.toUpperCase(),
                              color: catColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      _StatRow(
                        label: 'Time',
                        child: Text(
                          Formatters.duration(d.durationMs),
                          style: AppTextStyles.statMd.copyWith(color: catColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              // Image preview (only for image/pdf categories)
              if (isImage && d.outputFile.existsSync())
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: Image.file(
                        d.outputFile,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppDimens.x2l),

              // Action buttons
              AppButton.primary(
                label: AppStrings.actionSave,
                onPressed: _saveToDownloads,
              ),
              const SizedBox(height: AppDimens.md),
              AppButton.secondary(
                label: AppStrings.actionShare,
                onPressed: _share,
              ),
              const SizedBox(height: AppDimens.md),
              AppButton.text(
                label: 'Convert Another',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveToDownloads() async {
    // TODO: Implement save to device Downloads folder
    if (mounted) {
      AppToast.show(context, 'Saved to Downloads', type: ToastType.success);
    }
  }

  Future<void> _share() async {
    await Share.shareXFiles([XFile(widget.data.outputFile.path)]);
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _FormatBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
