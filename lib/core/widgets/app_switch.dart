import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimens.dart';
import '../constants/app_motion.dart';

/// Switch wrapper — never use raw Switch directly in pages.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? subtitle;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return _buildListTile(context);
    }
    return _buildSwitch();
  }

  Widget _buildSwitch() {
    return AnimatedScale(
      scale: 1.0,
      duration: AppMotion.controlState,
      curve: AppMotion.stateCurve,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.onPrimary,
        activeTrackColor: AppColors.primary,
        inactiveThumbColor: AppColors.textSecondary,
        inactiveTrackColor: AppColors.surfaceElevated,
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label!, style: AppTextStyles.heading3),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimens.xs),
                  Text(subtitle!, style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimens.md),
          _buildSwitch(),
        ],
      ),
    );
  }
}
