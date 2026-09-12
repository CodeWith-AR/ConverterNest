import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../settings/viewmodels/settings_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/category_grid.dart';
import '../widgets/recent_history_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadRecentJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenH,
          vertical: AppDimens.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar row
            Row(
              children: [
                // App Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                const Text(AppStrings.appName, style: AppTextStyles.heading2),
                const Spacer(),
                // Theme Switcher (Moon / Sun)
                IconButton(
                  onPressed: () => context.read<SettingsViewModel>().toggleTheme(),
                  icon: Icon(
                    settingsVm.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: settingsVm.isDarkMode
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    size: AppDimens.iconMd,
                  ),
                  tooltip: settingsVm.isDarkMode
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),

            // Hero text
            const Text(AppStrings.homeGreeting, style: AppTextStyles.displayLg),
            const SizedBox(height: AppDimens.xs),
            Text(
              AppStrings.homeSubtitle,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppDimens.xl),

            // Choose a category
            const Text(AppStrings.homeCategory, style: AppTextStyles.heading2),
            const SizedBox(height: AppDimens.md),

            // Category grid
            const CategoryGrid(),
            const SizedBox(height: AppDimens.xl),

            // Recent conversions
            const RecentHistorySection(),
            const SizedBox(height: AppDimens.xl),
          ],
        ),
      ),
    );
  }
}
