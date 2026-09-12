import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_motion.dart';

/// 2-column grid of selectable format chips.
class FormatSelectorGrid extends StatelessWidget {
  final List<String> formats;
  final String? selected;
  final ValueChanged<String> onSelected;
  final Color accentColor;

  const FormatSelectorGrid({
    super.key,
    required this.formats,
    required this.selected,
    required this.onSelected,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimens.sm,
        mainAxisSpacing: AppDimens.sm,
        childAspectRatio: 2.5,
      ),
      itemCount: formats.length,
      itemBuilder: (context, index) {
        final format = formats[index];
        final isSelected = format == selected;

        return GestureDetector(
          onTap: () => onSelected(format),
          child: AnimatedContainer(
            duration: AppMotion.controlState,
            curve: AppMotion.stateCurve,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? accentColor : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(
                color: isSelected ? accentColor : AppColors.border,
              ),
            ),
            child: Text(
              format,
              style: AppTextStyles.button.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
