import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

/// Progress indicator wrapper — never use raw CircularProgressIndicator
/// or LinearProgressIndicator directly in pages.
class AppProgressIndicator extends StatelessWidget {
  final double? value;
  final bool isLinear;
  final Color? color;
  final double strokeWidth;
  final double height;

  const AppProgressIndicator({
    super.key,
    this.value,
    this.isLinear = false,
    this.color,
    this.strokeWidth = 3,
    this.height = 4,
  });

  const AppProgressIndicator.circular({
    super.key,
    this.value,
    this.color,
    this.strokeWidth = 3,
  })  : isLinear = false,
        height = 4;

  const AppProgressIndicator.linear({
    super.key,
    this.value,
    this.color,
    this.height = 4,
  })  : isLinear = true,
        strokeWidth = 3;

  @override
  Widget build(BuildContext context) {
    if (isLinear) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: SizedBox(
          height: height,
          child: LinearProgressIndicator(
            value: value,
            color: color ?? AppColors.primary,
            backgroundColor: AppColors.surfaceElevated,
          ),
        ),
      );
    }
    return SizedBox(
      width: AppDimens.iconMd,
      height: AppDimens.iconMd,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        color: color ?? AppColors.primary,
      ),
    );
  }
}
