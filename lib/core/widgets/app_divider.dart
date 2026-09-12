import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// Styled divider with optional label.
class AppDivider extends StatelessWidget {
  final String? label;
  final double height;

  const AppDivider({super.key, this.label, this.height = 1});

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return Row(
        children: [
          Expanded(child: Divider(color: AppColors.border, thickness: height)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
            child: Text(label!, style: AppTextStyles.caption),
          ),
          Expanded(child: Divider(color: AppColors.border, thickness: height)),
        ],
      );
    }
    return Divider(color: AppColors.border, thickness: height);
  }
}
