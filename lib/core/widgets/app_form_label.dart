import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimens.dart';

/// Form field label — shown above/beside every input, optional required marker.
class AppFormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const AppFormLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.label),
          if (isRequired) ...[
            const SizedBox(width: AppDimens.xs),
            Text('*',
                style: AppTextStyles.label.copyWith(color: AppColors.error)),
          ],
        ],
      ),
    );
  }
}
