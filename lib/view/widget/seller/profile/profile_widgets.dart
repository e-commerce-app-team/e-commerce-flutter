import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/profile_models.dart';

// =========================================================================
// ودجت الهيدر (صورة الغلاف وصورة الملف الشخصي)
// =========================================================================
class ProfileHeader extends StatelessWidget {
  final SellerProfileModel profile;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditCover;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditPhoto,
    required this.onEditCover,
  });

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      // الغلاف (Cover)
      GestureDetector(
        onTap: onEditCover,
        child: Container(
          height: 130,
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppColor.headerGradient),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.store_outlined, size: 48, color: Colors.white.withOpacity(0.1)),
            Positioned(
              top: 10, right: 10, // يفضل ربط الـ right والـ left باتجاه اللغة (RTL/LTR) لاحقاً إذا لزم الأمر
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.camera_alt_outlined, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('change_cover'.tr, // تم استبدال النص الثابت
                      style: AppTextStyle.labelSmall.copyWith(color: Colors.white, fontSize: 10)),
                ]),
              ),
            ),
          ]),
        ),
      ),
      // الصورة الشخصية (Profile Photo)
      Positioned(
        bottom: -44, right: 20,
        child: Stack(children: [
          Container(
            width: 82, height: 82,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: AppColor.cardShadow,
            ),
            child: const Icon(Icons.store, size: 38, color: AppColor.primaryColor),
          ),
          Positioned(
            bottom: 0, left: 0,
            child: GestureDetector(
              onTap: onEditPhoto,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    ],
  );
}

// =========================================================================
// كرت معلومات المتجر الأساسية (الاسم، الموقع، الإحصائيات)
// =========================================================================
class ProfileInfoCard extends StatelessWidget {
  final SellerProfileModel profile;
  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 56, 16, 0),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: BoxDecoration(
      color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(profile.storeName, style: AppTextStyle.heading2.copyWith(fontSize: 17, color: Get.isDarkMode ? Colors.white : AppColor.black)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: profile.isWholesale ? AppColor.infoLight : AppColor.primarySurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile.isWholesale ? 'wholesale_seller'.tr : 'individual_seller'.tr, // تم استبدال النص الثابت
            style: AppTextStyle.chip.copyWith(
              color: profile.isWholesale ? AppColor.info : AppColor.primaryColor,
              fontWeight: FontWeight.w700, fontSize: 10,
            ),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        const Icon(Icons.category_outlined, size: 13, color: AppColor.grey),
        const SizedBox(width: 4),
        Text(profile.category, style: AppTextStyle.bodySmall.copyWith(fontSize: 12)),
        const SizedBox(width: 12),
        const Icon(Icons.location_on_outlined, size: 13, color: AppColor.grey),
        const SizedBox(width: 4),
        Text(profile.city, style: AppTextStyle.bodySmall.copyWith(fontSize: 12)),
      ]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat(
            value: profile.ratingAvg.toStringAsFixed(1),
            label: 'rating'.tr, // تم استبدال النص الثابت
            icon: Icons.star_rounded,
            color: const Color(0xffFFD700)
        ),
        Container(width: 1, height: 30, color: AppColor.greyBorder),
        _Stat(
            value: '${profile.reviewCount}',
            label: 'review_count'.tr, // تم استبدال النص الثابت
            icon: Icons.rate_review_outlined,
            color: AppColor.info
        ),
        Container(width: 1, height: 30, color: AppColor.greyBorder),
        _Stat(
            value: '${profile.followersCount}',
            label: 'followers'.tr, // تم استبدال النص الثابت
            icon: Icons.people_outline,
            color: AppColor.success
        ),
      ]),
    ]),
  );
}

// ودجت فرعي داخلي لإحصائيات الكرت
class _Stat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(value, style: AppTextStyle.statNumberSmall.copyWith(fontSize: 16, color: Get.isDarkMode ? Colors.white : AppColor.black)),
    ]),
    const SizedBox(height: 2),
    Text(label, style: AppTextStyle.statLabel),
  ]);
}

// =========================================================================
// ودجت قسم القوائم (Sections)
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

// =========================================================================
// ودجت عنصر القائمة الفردي (List Tile)
// =========================================================================
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
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
            ]),
          ),
          trailing ?? Icon(Icons.chevron_right_rounded, size: 18, color: AppColor.greyLight),
        ]),
      ),
    ),
    if (showDivider)
      const Divider(height: 1, indent: 62, color: AppColor.greyBorder),
  ]);
}