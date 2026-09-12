import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'app_shell.dart';
import '../../modules/splash/pages/splash_page.dart';
import '../../modules/onboarding/pages/onboarding_page.dart';
import '../../modules/home/pages/home_page.dart';
import '../../modules/history/pages/history_page.dart';
import '../../modules/settings/pages/settings_page.dart';
import '../../modules/image_converter/pages/image_converter_page.dart';
import '../../modules/audio_converter/pages/audio_converter_page.dart';
import '../../modules/video_converter/pages/video_converter_page.dart';
import '../../modules/archive_manager/pages/archive_manager_page.dart';
import '../../modules/text_converter/pages/text_converter_page.dart';
import '../../modules/pdf_tools/pages/pdf_tools_page.dart';
import '../../modules/shared/pages/conversion_result_page.dart';
import '../../modules/shared/models/conversion_result_data.dart';
import '../../core/constants/app_motion.dart';

final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _historyKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _settingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final _navItems = [
  NavItem(
      icon: Icons.home_rounded, label: AppRoutes.home, navigatorKey: _homeKey),
  NavItem(
      icon: Icons.history_rounded,
      label: AppRoutes.history,
      navigatorKey: _historyKey),
  NavItem(
      icon: Icons.settings_rounded,
      label: AppRoutes.settings,
      navigatorKey: _settingsKey),
];

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash & Onboarding (outside shell — no bottom nav)
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (c, s) => _fadePage(child: const SplashPage(), state: s),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (c, s) => _fadePage(child: const OnboardingPage(), state: s),
    ),

    // Main shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          AppShell(navigationShell: shell, navItems: _navItems),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeKey,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (c, s) =>
                  _fadePage(child: const HomePage(), state: s),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _historyKey,
          routes: [
            GoRoute(
              path: AppRoutes.history,
              pageBuilder: (c, s) =>
                  _fadePage(child: const HistoryPage(), state: s),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsKey,
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              pageBuilder: (c, s) =>
                  _fadePage(child: const SettingsPage(), state: s),
            ),
          ],
        ),
      ],
    ),

    // Converter routes (full-screen, outside shell)
    GoRoute(
        path: AppRoutes.imageConverter,
        pageBuilder: (c, s) =>
            _fadePage(child: const ImageConverterPage(), state: s)),
    GoRoute(
        path: AppRoutes.audioConverter,
        pageBuilder: (c, s) =>
            _fadePage(child: const AudioConverterPage(), state: s)),
    GoRoute(
        path: AppRoutes.videoConverter,
        pageBuilder: (c, s) =>
            _fadePage(child: const VideoConverterPage(), state: s)),
    GoRoute(
        path: AppRoutes.archiveManager,
        pageBuilder: (c, s) =>
            _fadePage(child: const ArchiveManagerPage(), state: s)),
    GoRoute(
        path: AppRoutes.textConverter,
        pageBuilder: (c, s) =>
            _fadePage(child: const TextConverterPage(), state: s)),
    GoRoute(
        path: AppRoutes.pdfTools,
        pageBuilder: (c, s) =>
            _fadePage(child: const PdfToolsPage(), state: s)),

    // Shared result page
    GoRoute(
      path: AppRoutes.conversionResult,
      pageBuilder: (context, state) {
        final data = state.extra as ConversionResultData;
        return _fadePage(child: ConversionResultPage(data: data), state: state);
      },
    ),
  ],
);

CustomTransitionPage<T> _fadePage<T>(
    {required Widget child, required GoRouterState state}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.fadePage,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
