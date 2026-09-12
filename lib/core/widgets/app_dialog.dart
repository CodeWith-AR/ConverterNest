import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

/// Generic modal dialog container for custom content.
class AppDialog extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const AppDialog({
    super.key,
    required this.child,
    this.maxWidth,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.canvasDark.withValues(alpha: 0.7),
      builder: (_) => AppDialog(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 340),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: child,
        ),
      ),
    );
  }
}
