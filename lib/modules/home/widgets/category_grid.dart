import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/category_card.dart';
import '../../../app/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

/// 2-column grid of 6 category cards with staggered entrance animation.
class CategoryGrid extends StatefulWidget {
  const CategoryGrid({super.key});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasAnimated = false;

  static const List<_CategoryData> _categories = [
    _CategoryData(
      icon: Icons.image_rounded,
      title: AppStrings.catImage,
      subtitle: AppStrings.catImageSub,
      accentColor: AppColors.accentImage,
      route: AppRoutes.imageConverter,
    ),
    _CategoryData(
      icon: Icons.audiotrack_rounded,
      title: AppStrings.catAudio,
      subtitle: AppStrings.catAudioSub,
      accentColor: AppColors.accentAudio,
      route: AppRoutes.audioConverter,
    ),
    _CategoryData(
      icon: Icons.play_circle_fill_rounded,
      title: AppStrings.catVideo,
      subtitle: AppStrings.catVideoSub,
      accentColor: AppColors.accentVideo,
      route: AppRoutes.videoConverter,
    ),
    _CategoryData(
      icon: Icons.folder_zip_rounded,
      title: AppStrings.catArchive,
      subtitle: AppStrings.catArchiveSub,
      accentColor: AppColors.accentArchive,
      route: AppRoutes.archiveManager,
    ),
    _CategoryData(
      icon: Icons.description_rounded,
      title: AppStrings.catText,
      subtitle: AppStrings.catTextSub,
      accentColor: AppColors.accentText,
      route: AppRoutes.textConverter,
    ),
    _CategoryData(
      icon: Icons.picture_as_pdf_rounded,
      title: AppStrings.catPdf,
      subtitle: AppStrings.catPdfSub,
      accentColor: AppColors.accentPdf,
      route: AppRoutes.pdfTools,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Total animation time = last card delay + entry duration
    // (5 * 80ms) + 400ms = 800ms
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds:
            ((_categories.length - 1) * AppMotion.staggerDelay.inMilliseconds) +
                AppMotion.staggerEntry.inMilliseconds,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasAnimated) {
        _hasAnimated = true;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _controller.duration!.inMilliseconds;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.md,
        mainAxisSpacing: AppDimens.md,
        childAspectRatio: 1.1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];

        // Calculate stagger interval for this card
        final startMs = index * AppMotion.staggerDelay.inMilliseconds;
        final endMs = startMs + AppMotion.staggerEntry.inMilliseconds;
        final begin = startMs / totalMs;
        final end = (endMs / totalMs).clamp(0.0, 1.0);

        final slideAnim = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, end, curve: AppMotion.easeOutCubic),
        ));

        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(begin, end, curve: AppMotion.easeOut),
          ),
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(
                position: slideAnim,
                child: child,
              ),
            );
          },
          child: CategoryCard(
            icon: cat.icon,
            title: cat.title,
            subtitle: cat.subtitle,
            accentColor: cat.accentColor,
            onTap: () => context.push(cat.route),
          ),
        );
      },
    );
  }
}

class _CategoryData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String route;

  const _CategoryData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.route,
  });
}
