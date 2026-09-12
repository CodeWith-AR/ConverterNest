import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_motion.dart';

class NavItem {
  const NavItem(
      {required this.icon, required this.label, required this.navigatorKey});
  final IconData icon;
  final String label;
  final GlobalKey<NavigatorState> navigatorKey;
}

class _BouncyNavIcon extends StatelessWidget {
  const _BouncyNavIcon({required this.icon, required this.selected});
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: selected ? 1.15 : 1.0,
        duration: AppMotion.navBounce,
        curve: AppMotion.bounceCurve,
        child: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textSecondary,
          size: AppDimens.iconMd,
        ),
      );
}

class AppShell extends StatefulWidget {
  const AppShell(
      {required this.navigationShell, required this.navItems, super.key});
  final StatefulNavigationShell navigationShell;
  final List<NavItem> navItems;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _prevIndex = 0;

  void _handleBack() {
    final key =
        widget.navItems[widget.navigationShell.currentIndex].navigatorKey;
    if (key.currentState?.canPop() ?? false) {
      key.currentState!.pop();
      return;
    }
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.navigationShell.currentIndex;
    final forward = idx >= _prevIndex;
    _prevIndex = idx;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBack(),
      child: Scaffold(
        body: PageTransitionSwitcher(
          duration: AppMotion.branchSlide,
          reverse: !forward,
          transitionBuilder: (child, pri, sec) => SharedAxisTransition(
            animation: pri,
            secondaryAnimation: sec,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
          child:
              KeyedSubtree(key: ValueKey(idx), child: widget.navigationShell),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: NavigationBar(
            selectedIndex: idx,
            onDestinationSelected: (i) => widget.navigationShell.goBranch(
              i,
              initialLocation: i == idx,
            ),
            destinations: [
              for (var i = 0; i < widget.navItems.length; i++)
                NavigationDestination(
                  icon: _BouncyNavIcon(
                      icon: widget.navItems[i].icon, selected: idx == i),
                  label: widget.navItems[i].label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
