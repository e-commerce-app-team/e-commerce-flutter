import 'dart:async';
import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_network_image.dart';

/// The home screen's hero: a gallery-style, auto-advancing banner
/// carousel. Cards peek at the edges (rather than a single full-bleed
/// slide) and carry a bottom gradient scrim so the title stays legible
/// over any photo, editorial-catalog style rather than a flat ad strip.
class HeroBannerCarousel extends StatefulWidget {
  final List<BuyerBannerItem> banners;
  final double height;
  final ValueChanged<int>? onBannerTap;
  final Duration autoPlayInterval;

  const HeroBannerCarousel({
    Key? key,
    required this.banners,
    this.height = 190,
    this.onBannerTap,
    this.autoPlayInterval = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.banners.length <= 1) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final isLast = _currentPage >= widget.banners.length - 1;
      if (isLast) {
        _controller.jumpToPage(0);
      } else {
        _controller.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _BannerCard(
                  banner: widget.banners[index],
                  onTap: widget.onBannerTap == null
                      ? null
                      : () => widget.onBannerTap!(index),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 7,
              height: 5,
              decoration: BoxDecoration(
                gradient: isActive ? AppColor.mainGradient : null,
                color: isActive ? null : AppColor.greyBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BuyerBannerItem banner;
  final VoidCallback? onTap;

  const _BannerCard({required this.banner, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColor.cardShadow,
          color: AppColor.secondBackground,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BuyerNetworkImage(
              url: banner.imageUrl,
              backgroundColor: AppColor.primarySurface,
              fallbackIcon: Icons.image_outlined,
              fallbackIconSize: 36,
            ),
            // Bottom scrim so the title stays legible over any photo.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.black.withOpacity(0),
                    AppColor.black.withOpacity(0.62),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            // Signature copper corner mark.
            PositionedDirectional(
              top: 16,
              start: 16,
              child: Container(
                width: 26,
                height: 3,
                decoration: BoxDecoration(
                  gradient: AppColor.mainGradient,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            if (banner.badgeLabel != null)
              PositionedDirectional(
                top: 16,
                end: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundcolor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    banner.badgeLabel!,
                    style: AppTextStyle.labelSmall.copyWith(
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            PositionedDirectional(
              bottom: 18,
              start: 20,
              end: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.displaySmall.copyWith(color: AppColor.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    banner.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColor.white.withOpacity(0.88),
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
