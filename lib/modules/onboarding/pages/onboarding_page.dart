import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/app_button.dart';
import '../../../app/routes/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      imagePath: 'assets/images/onboarding_1.png',
      icon: Icons.swap_horiz_rounded,
      iconColor: AppColors.primary,
      title: 'Convert Anything',
      subtitle: 'Images, audio, video, documents, archives — all in one place.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding_2.png',
      icon: Icons.shield_rounded,
      iconColor: AppColors.success,
      title: 'Your Files Stay Private',
      subtitle:
          'Nothing leaves your phone. No uploads, no servers, no tracking. Ever.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding_3.png',
      icon: Icons.favorite_rounded,
      iconColor: AppColors.primary,
      title: 'Free Forever',
      subtitle:
          'No subscriptions, no limits, no hidden costs. Built for everyone.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.branchSlide,
        curve: AppMotion.slideCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Page view
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimens.x2l),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image illustration
                      SizedBox(
                        height: 200,
                        child: Image.asset(
                          page.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: page.iconColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              page.icon,
                              color: page.iconColor,
                              size: 56,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.x2l),
                      Text(
                        page.title,
                        style: AppTextStyles.displayLg
                            .copyWith(color: AppColors.textStrong),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.md),
                      Text(
                        page.subtitle,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Top skip button
            if (!isLast)
              Positioned(
                top: AppDimens.screenV,
                right: AppDimens.screenH,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),

            // Bottom section
            Positioned(
              left: 0,
              right: 0,
              bottom: AppDimens.x2l,
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.surfaceElevated,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: AppDimens.sm,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Action button
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppDimens.x2l),
                    child: isLast
                        ? AppButton.primary(
                            label: 'Get Started',
                            onPressed: _finish,
                          )
                        : AppButton.primary(
                            label: 'Next →',
                            onPressed: _next,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.imagePath,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
