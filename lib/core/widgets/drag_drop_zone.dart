import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_motion.dart';

/// File picker zone with dashed border — tap to select file.
class DragDropZone extends StatefulWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final bool isActive;

  const DragDropZone({
    super.key,
    required this.onTap,
    this.title = 'Tap to select file',
    this.subtitle = 'or drag and drop here',
    this.isActive = false,
  });

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive || _isHovered;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppMotion.controlState,
        curve: AppMotion.stateCurve,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGlow : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: DottedBorder(
          color: active ? AppColors.primary : AppColors.borderStrong,
          strokeWidth: 2,
          dashPattern: const [8, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(AppDimens.radiusMd),
          padding: const EdgeInsets.all(AppDimens.x2l),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_upload_rounded,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  size: AppDimens.iconXxl,
                ),
                const SizedBox(height: AppDimens.md),
                Text(widget.title, style: AppTextStyles.heading3),
                const SizedBox(height: AppDimens.xs),
                Text(widget.subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
