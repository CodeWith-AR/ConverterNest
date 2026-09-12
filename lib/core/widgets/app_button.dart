import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_motion.dart';

/// Unified button component — never use raw ElevatedButton / OutlinedButton /
/// TextButton / IconButton directly in pages.
class AppButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final _AppButtonVariant _variant;

  const AppButton._({
    this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    required _AppButtonVariant variant,
  }) : _variant = variant;

  /// Yellow background, black text — the single main CTA per screen.
  factory AppButton.primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        fullWidth: fullWidth,
        variant: _AppButtonVariant.primary,
      );

  /// surfaceElevated background, textPrimary text, border stroke.
  factory AppButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    bool fullWidth = true,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        fullWidth: fullWidth,
        variant: _AppButtonVariant.secondary,
      );

  /// Transparent background, primary text color.
  factory AppButton.text({
    required String label,
    required VoidCallback? onPressed,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        fullWidth: false,
        variant: _AppButtonVariant.text,
      );

  /// Error background, white text — for delete / irreversible actions.
  factory AppButton.destructive({
    required String label,
    required VoidCallback? onPressed,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        variant: _AppButtonVariant.destructive,
      );

  /// 44×44px touch target, icon centered.
  factory AppButton.icon({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) =>
      AppButton._(
        icon: icon,
        onPressed: onPressed,
        fullWidth: false,
        variant: _AppButtonVariant.icon,
      );

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _AppButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: AppDimens.buttonH,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.primaryDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: AppDimens.iconMd,
                    height: AppDimens.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(label!,
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.onPrimary)),
          ),
        );
      case _AppButtonVariant.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: AppDimens.buttonH,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              elevation: 0,
            ),
            child: Text(label!,
                style: AppTextStyles.button
                    .copyWith(color: AppColors.textPrimary)),
          ),
        );
      case _AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
          ),
          child: Text(label!,
              style: AppTextStyles.button.copyWith(color: AppColors.primary)),
        );
      case _AppButtonVariant.destructive:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: AppDimens.buttonH,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textStrong,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              elevation: 0,
            ),
            child: Text(label!,
                style:
                    AppTextStyles.button.copyWith(color: AppColors.textStrong)),
          ),
        );
      case _AppButtonVariant.icon:
        return AnimatedScale(
          scale: 1.0,
          duration: AppMotion.controlState,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: AppDimens.iconMd,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        );
    }
  }
}

enum _AppButtonVariant { primary, secondary, text, destructive, icon }
