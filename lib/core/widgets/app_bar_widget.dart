import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// Custom app bar widget matching Converter Nest design.
class AppBarWidget extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppBarWidget({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenH,
        vertical: AppDimens.md,
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: AppDimens.iconMd,
              ),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          if (leading != null) leading!,
          if (title != null)
            Expanded(
              child: Text(title!, style: AppTextStyles.heading1),
            )
          else
            const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
