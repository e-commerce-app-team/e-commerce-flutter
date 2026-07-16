import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/profile_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

// =========================================================================
// Header: cover + logo, real images with graceful fallback
// =========================================================================
class ProfileHeader extends StatelessWidget {
  final SellerProfileModel profile;
  final VoidCallback? onEditPhoto;
  final VoidCallback? onEditCover;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEditPhoto,
    this.onEditCover,
  });

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      GestureDetector(
        onTap: onEditCover,
        child: Container(
          height: 150,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(gradient: AppColor.headerGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (profile.coverUrl != null)
                CachedNetworkImage(
                  imageUrl: profile.coverUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 250),
                  placeholder: (_, __) => const _CoverFallback(),
                  errorWidget: (_, __, ___) => const _CoverFallback(),
                )
              else
                const _CoverFallback(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.25),
                    ],
                  ),
                ),
              ),
              // Only show cover-edit badge for owners
              if (onEditCover != null)
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: _GlassBadge(
                    icon: Icons.camera_alt_outlined,
                    label: 'acct_change_cover'.tr,
                  ),
                ),
            ],
          ),
        ),
      ),
      PositionedDirectional(
        bottom: -42,
        end: 20,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 84,
              height: 84,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppColor.cardShadow,
              ),
              child: ClipOval(
                child: profile.logoUrl != null
                    ? CachedNetworkImage(
                  imageUrl: profile.logoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _LogoFallback(),
                  errorWidget: (_, __, ___) => const _LogoFallback(),
                )
                    : const _LogoFallback(),
              ),
            ),
            // Only show photo-edit badge for owners
            if (onEditPhoto != null)
              PositionedDirectional(
                bottom: 0,
                start: 0,
                child: GestureDetector(
                  onTap: onEditPhoto,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 13, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(gradient: AppColor.headerGradient),
    child: Center(
      child: Icon(Icons.storefront_rounded,
          size: 46, color: Colors.white.withOpacity(0.18)),
    ),
  );
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColor.primarySurface,
    child: const Icon(Icons.storefront_rounded,
        size: 34, color: AppColor.primaryColor),
  );
}

class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.28),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: Colors.white),
      const SizedBox(width: 5),
      Text(label,
          style: AppTextStyle.labelSmall.copyWith(color: Colors.white, fontSize: 10)),
    ]),
  );
}

// =========================================================================
// Info card: real store name / category / city / stats
// =========================================================================
class ProfileInfoCard extends StatelessWidget {
  final SellerProfileModel profile;
  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 52, 16, 0),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: BoxDecoration(
      color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(
            profile.storeName.isNotEmpty ? profile.storeName : profile.fullName,
            style: AppTextStyle.heading2.copyWith(
              fontSize: 17,
              color: Get.isDarkMode ? Colors.white : AppColor.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: profile.isWholesale ? AppColor.infoLight : AppColor.primarySurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile.isWholesale ? 'acct_wholesale_seller'.tr : 'acct_individual_seller'.tr,
            style: AppTextStyle.chip.copyWith(
              color: profile.isWholesale ? AppColor.info : AppColor.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ]),
      if (profile.category.isNotEmpty || profile.city.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          if (profile.category.isNotEmpty) ...[
            const Icon(Icons.category_outlined, size: 13, color: AppColor.grey),
            const SizedBox(width: 4),
            Flexible(
              child: Text(profile.category,
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 12),
          ],
          if (profile.city.isNotEmpty) ...[
            const Icon(Icons.location_on_outlined, size: 13, color: AppColor.grey),
            const SizedBox(width: 4),
            Flexible(
              child: Text(profile.city,
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ]),
      ],
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat(
          value: profile.ratingAvg.toStringAsFixed(1),
          label: 'acct_rating'.tr,
          icon: Icons.star_rounded,
          color: const Color(0xffFFD700),
        ),
        Container(width: 1, height: 30, color: AppColor.greyBorder),
        _Stat(
          value: '${profile.reviewCount}',
          label: 'acct_reviews_count'.tr,
          icon: Icons.rate_review_outlined,
          color: AppColor.info,
        ),
        Container(width: 1, height: 30, color: AppColor.greyBorder),
        _Stat(
          value: '${profile.followersCount}',
          label: 'acct_followers'.tr,
          icon: Icons.people_outline,
          color: AppColor.success,
        ),
      ]),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(value,
          style: AppTextStyle.statNumberSmall.copyWith(
              fontSize: 16, color: Get.isDarkMode ? Colors.white : AppColor.black)),
    ]),
    const SizedBox(height: 2),
    Text(label, style: AppTextStyle.statLabel),
  ]);
}

// =========================================================================
// Menu section / tile
// =========================================================================
class ProfileMenuSection extends StatelessWidget {
  final String?      sectionLabel;
  final List<Widget> children;

  const ProfileMenuSection({super.key, this.sectionLabel, required this.children});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (sectionLabel != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(sectionLabel!.toUpperCase(),
              style: AppTextStyle.labelSmall.copyWith(letterSpacing: 0.8, fontSize: 10)),
        ),
      Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: Column(children: children),
      ),
    ],
  );
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  subtitle;
  final Color    iconColor;
  final Color    iconBg;
  final Widget?  trailing;
  final bool     isDestructive;
  final bool     showDivider;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconColor,
    required this.iconBg,
    this.trailing,
    this.isDestructive = false,
    this.showDivider = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: AppTextStyle.labelLarge.copyWith(
                    fontSize: 13,
                    color: isDestructive ? AppColor.error : (Get.isDarkMode ? Colors.white : AppColor.black),
                  )),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!,
                    style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
            ]),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right_rounded, size: 18, color: AppColor.greyLight),
        ]),
      ),
    ),
    if (showDivider)
      const Divider(height: 1, indent: 62, color: AppColor.greyBorder),
  ]);
}

// =========================================================================
// Small trailing chips
// =========================================================================
class ProfileTrailingChip extends StatelessWidget {
  final String label;
  const ProfileTrailingChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColor.primarySurface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label,
        style: AppTextStyle.chip.copyWith(
            color: AppColor.primaryColor, fontWeight: FontWeight.w700, fontSize: 11)),
  );
}

class ProfileComingSoonChip extends StatelessWidget {
  const ProfileComingSoonChip({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: AppColor.secondBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColor.greyBorder),
    ),
    child: Text('acct_coming_soon'.tr,
        style: AppTextStyle.chip.copyWith(
            color: AppColor.greyLight, fontWeight: FontWeight.w600, fontSize: 10)),
  );
}

// =========================================================================
// Shimmer skeletons
// =========================================================================
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const ShimmerBox(width: double.infinity, height: 150, radius: 0),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColor.cardShadow,
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 140, height: 16),
                ShimmerBox(width: 64, height: 22, radius: 12),
              ],
            ),
            const SizedBox(height: 12),
            const ShimmerBox(width: 180, height: 10),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                ShimmerBox(width: 46, height: 34),
                ShimmerBox(width: 46, height: 34),
                ShimmerBox(width: 46, height: 34),
              ],
            ),
          ]),
        ),
      ),
    ],
  );
}

class ProfileMenuSectionShimmer extends StatelessWidget {
  final int itemCount;
  const ProfileMenuSectionShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(
      children: List.generate(
        itemCount,
            (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: const [
            ShimmerBox(width: 36, height: 36, radius: 10),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(width: double.infinity, height: 12)),
          ]),
        ),
      ),
    ),
  );
}