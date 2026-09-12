import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_alert_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_switch.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().loadSettings();
    });
  }

  void _showAppInfoMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.only(top: 56, right: 16, left: 60),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPopupItem(
                    icon: Icons.open_in_new_rounded,
                    title: 'Consumer Terms',
                    onTap: () {
                      Navigator.pop(ctx);
                      _showPolicyDialog(
                        'Consumer Terms',
                        'Converter Nest is a 100% offline file converter. By using this application, you retain full ownership of all files and data processed. No data is sent to external servers.',
                      );
                    },
                  ),
                  Divider(color: AppColors.border, height: 1),
                  _buildPopupItem(
                    icon: Icons.open_in_new_rounded,
                    title: 'Acceptable Use Policy',
                    onTap: () {
                      Navigator.pop(ctx);
                      _showPolicyDialog(
                        'Acceptable Use Policy',
                        'Converter Nest is designed for personal, non-commercial, and lawful file conversion. You are solely responsible for ensuring you have rights to convert copyright-protected media.',
                      );
                    },
                  ),
                  Divider(color: AppColors.border, height: 1),
                  _buildPopupItem(
                    icon: Icons.open_in_new_rounded,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(ctx);
                      _showPolicyDialog(
                        'Privacy Policy',
                        'We value your absolute privacy. Converter Nest operates entirely offline on your device without collecting, transmitting, or sharing any personal data, analytics, or file contents.',
                      );
                    },
                  ),
                  Divider(color: AppColors.border, height: 1),
                  _buildPopupItem(
                    icon: Icons.article_outlined,
                    title: 'Licenses',
                    onTap: () {
                      Navigator.pop(ctx);
                      showLicensePage(
                        context: context,
                        applicationName: AppStrings.appName,
                        applicationVersion: 'Version 1.0.0 (1)',
                      );
                    },
                  ),
                  Divider(color: AppColors.border, height: 1),
                  _buildPopupItem(
                    icon: Icons.open_in_new_rounded,
                    title: 'Help & Support',
                    onTap: () async {
                      Navigator.pop(ctx);
                      final url = Uri.parse('https://github.com/CodeWith-AR');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  Divider(color: AppColors.border, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.base,
                      vertical: AppDimens.md,
                    ),
                    child: Text(
                      'Version 1.0.0 (10001)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.base,
          vertical: AppDimens.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          side: BorderSide(color: AppColors.border),
        ),
        title: Text(title, style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final settings = vm.settings;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenH,
          vertical: AppDimens.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Row(
              children: [
                const Text(AppStrings.settingsTitle, style: AppTextStyles.heading1),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAppInfoMenu(context),
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: AppDimens.iconMd,
                  ),
                  tooltip: 'App Information',
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),

            // WARNINGS section
            SettingsSection(
              title: AppStrings.settingsWarnings,
              children: [
                _SettingsToggleTile(
                  title: AppStrings.settingsBattery,
                  subtitle: AppStrings.settingsBatterySub,
                  value: settings.showBatteryWarning,
                  onChanged: vm.setBatteryWarning,
                ),
                _SettingsToggleTile(
                  title: AppStrings.settingsLargeFile,
                  subtitle: AppStrings.settingsLargeFileSub,
                  value: settings.showLargeFileWarning,
                  onChanged: vm.setLargeFileWarning,
                ),
                // Threshold slider
                Padding(
                  padding: const EdgeInsets.all(AppDimens.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppStrings.settingsThreshold,
                              style: AppTextStyles.heading3),
                          Text(
                            '${settings.largeFileThresholdMb} MB',
                            style: AppTextStyles.statMd
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceElevated,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primaryGlow,
                          trackHeight: 4,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: settings.largeFileThresholdMb.toDouble(),
                          min: 50,
                          max: 500,
                          divisions: 9,
                          onChanged: (v) => vm.setThreshold(v.toInt()),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('50 MB', style: AppTextStyles.caption),
                          Text('250 MB', style: AppTextStyles.caption),
                          Text('500 MB', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // STORAGE section
            SettingsSection(
              title: AppStrings.settingsStorage,
              children: [
                _SettingsActionTile(
                  title: AppStrings.settingsHistory,
                  subtitle: '${vm.historyCount} conversions stored',
                  actionLabel: AppStrings.actionClear,
                  actionColor: AppColors.error,
                  onAction: () async {
                    final confirmed = await AppAlertDialog.show(
                      context: context,
                      title: AppStrings.historyClearAll,
                      message: AppStrings.historyClearSub,
                      confirmLabel: AppStrings.actionClear,
                      isDestructive: true,
                    );
                    if (confirmed == true && context.mounted) {
                      await vm.clearHistory();
                      if (context.mounted) {
                        AppToast.show(context, 'History cleared',
                            type: ToastType.success);
                      }
                    }
                  },
                ),
                _SettingsNavTile(
                  title: AppStrings.settingsOutputLoc,
                  subtitle: AppStrings.settingsOutputSub,
                  onTap: () {},
                ),
              ],
            ),

            // PRIVACY section
            const SettingsSection(
              title: AppStrings.settingsPrivacy,
              children: [
                Padding(
                  padding: EdgeInsets.all(AppDimens.base),
                  child: Row(
                    children: [
                      _PrivacyLockIcon(),
                      SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.settingsPrivacyNote,
                                style: AppTextStyles.heading3),
                            SizedBox(height: AppDimens.xs),
                            Text(AppStrings.settingsPrivacySub,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      Icon(Icons.verified_rounded,
                          color: AppColors.success, size: AppDimens.iconMd),
                    ],
                  ),
                ),
              ],
            ),

            // ABOUT section
            SettingsSection(
              title: AppStrings.settingsAbout,
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppDimens.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.appName, style: AppTextStyles.heading3),
                      SizedBox(height: AppDimens.xs),
                      Text(AppStrings.aboutVersion,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Divider(color: AppColors.border, height: 1),
                _SettingsNavTile(
                  title: 'Rate the App',
                  subtitle: 'Help us improve',
                  trailing: const Icon(Icons.star_rounded,
                      color: AppColors.primary, size: AppDimens.iconMd),
                  onTap: () {
                    // TODO: Link to Play Store
                  },
                ),
                Divider(color: AppColors.border, height: 1),
                _SettingsNavTile(
                  title: 'Share with Friends',
                  subtitle: 'Spread the word',
                  trailing: Icon(Icons.share_rounded,
                      color: AppColors.textSecondary, size: AppDimens.iconMd),
                  onTap: () {
                    Share.share(
                        'Check out Converter Nest — free offline file converter! https://play.google.com/store/apps/details?id=com.converternest.app');
                  },
                ),
                Divider(color: AppColors.border, height: 1),
                _SettingsNavTile(
                  title: 'LinkedIn',
                  subtitle: 'Connect with Rehman',
                  trailing: Icon(Icons.open_in_new_rounded,
                      color: AppColors.textSecondary, size: AppDimens.iconMd),
                  onTap: () async {
                    final uri = Uri.parse('https://www.linkedin.com/in/rehman90/');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                Divider(color: AppColors.border, height: 1),
                _SettingsNavTile(
                  title: 'GitHub',
                  subtitle: 'CodeWith-AR repository',
                  trailing: Icon(Icons.open_in_new_rounded,
                      color: AppColors.textSecondary, size: AppDimens.iconMd),
                  onTap: () async {
                    final uri = Uri.parse('https://github.com/CodeWith-AR');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),

            // Bottom branding
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.heading3
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppDimens.xs),
                  const Text(
                    AppStrings.aboutMadeWith,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.base),
          ],
        ),
      ),
    );
  }
}

/// Toggle tile for settings with switch.
class _SettingsToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.base, vertical: AppDimens.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading3),
                const SizedBox(height: AppDimens.xs),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.md),
          AppSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PrivacyLockIcon extends StatelessWidget {
  const _PrivacyLockIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.iconXl,
      height: AppDimens.iconXl,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: const Icon(Icons.lock_rounded,
          color: AppColors.success, size: AppDimens.iconMd),
    );
  }
}

/// Action tile for settings with action button.
class _SettingsActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onAction;

  const _SettingsActionTile({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.base, vertical: AppDimens.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading3),
                const SizedBox(height: AppDimens.xs),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: actionColor,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.md, vertical: AppDimens.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                side: BorderSide(color: actionColor),
              ),
            ),
            child: Text(
              actionLabel,
              style: AppTextStyles.button.copyWith(color: actionColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation tile for settings with chevron or custom trailing.
class _SettingsNavTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsNavTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.base, vertical: AppDimens.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  const SizedBox(height: AppDimens.xs),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
