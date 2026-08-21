import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/controller/buyer/buyer_profile_controller.dart';
import 'package:e_commerce/core/class/handling_dataview.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/localization/changelocal.dart';
import 'package:e_commerce/view/widget/seller/profile/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BuyerProfileController());

    return GetBuilder<BuyerProfileController>(
      builder: (ctrl) => Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColor.darkSecondBackground : AppColor.secondBackground,
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _AccountShimmer()
            : (ctrl.statusRequest == StatusRequest.offlinefailure ||
                    ctrl.statusRequest == StatusRequest.serverfailure ||
                    ctrl.profile == null)
                ? HandlingDataView(
                    statusRequest: ctrl.statusRequest,
                    widget: const SizedBox.shrink(),
                  )
                : _AccountBody(ctrl: ctrl),
      ),
    );
  }
}

class _AccountBody extends StatelessWidget {
  final BuyerProfileController ctrl;
  const _AccountBody({required this.ctrl});

  static const String _buyerEditProfileRoute = '/buyer/edit-profile';
  static const String _buyerAddressesRoute = '/buyer/addresses';
  static const String _buyerWalletRoute = '/buyer/wallet';
  static const String _buyerFollowingRoute = '/buyer/following-stores';
  static const String _buyerReviewsRoute = '/buyer/reviews';
  static const String _buyerConversationsRoute = '/buyer/conversations';
  static const String _buyerNotificationsRoute = '/buyer/notification-settings';

  @override
  Widget build(BuildContext context) {
    final profile = ctrl.profile!;

    return RefreshIndicator(
      onRefresh: ctrl.refreshProfile,
      color: AppColor.primaryColor,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: _BuyerProfileHeader(
              imageUrl: profile.profilePhotoUrl,
              onEditPhoto: () => Get.toNamed(_buyerEditProfileRoute),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _BuyerInfoCard(
                  fullName: profile.fullName,
                  email: profile.email,
                  ordersCount: profile.ordersCount,
                  favoritesCount: profile.favoritesCount,
                  reviewsCount: profile.reviewsCount,
                  isVip: profile.isVip,
                ),
                const SizedBox(height: 20),
                ProfileMenuSection(
                  sectionLabel: 'buyer_section_account'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.person_outline,
                      title: 'buyer_profile_edit_profile'.tr,
                      iconColor: AppColor.primaryColor,
                      iconBg: AppColor.primarySurface,
                      onTap: () => Get.toNamed(_buyerEditProfileRoute),
                    ),
                    ProfileMenuTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'buyer_profile_change_password'.tr,
                      iconColor: AppColor.grey,
                      iconBg: Get.isDarkMode
                          ? AppColor.darkSecondBackground
                          : AppColor.secondBackground,
                      showDivider: false,
                      onTap: () => Get.toNamed(AppRoute.changePassword),
                    ),
                  ],
                ),
                ProfileMenuSection(
                  sectionLabel: 'buyer_section_shopping'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.location_on_outlined,
                      title: 'buyer_profile_addresses'.tr,
                      iconColor: AppColor.statOrders,
                      iconBg: const Color(0xffEEEDFE),
                      onTap: () => Get.toNamed(_buyerAddressesRoute),
                    ),
                    ProfileMenuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'buyer_profile_wallet'.tr,
                      iconColor: AppColor.success,
                      iconBg: AppColor.successLight,
                      onTap: () => Get.toNamed(_buyerWalletRoute),
                    ),
                    ProfileMenuTile(
                      icon: Icons.store_outlined,
                      title: 'buyer_profile_following_stores'.tr,
                      iconColor: AppColor.info,
                      iconBg: AppColor.infoLight,
                      showDivider: false,
                      onTap: () => Get.toNamed(_buyerFollowingRoute),
                    ),
                  ],
                ),
                ProfileMenuSection(
                  sectionLabel: 'buyer_section_feedback'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.star_outline_rounded,
                      title: 'buyer_profile_my_reviews'.tr,
                      iconColor: AppColor.warning,
                      iconBg: AppColor.warningLight,
                      onTap: () => Get.toNamed(_buyerReviewsRoute),
                    ),
                    ProfileMenuTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'buyer_profile_messages'.tr,
                      iconColor: AppColor.primaryColor,
                      iconBg: AppColor.primarySurface,
                      showDivider: false,
                      onTap: () => Get.toNamed(_buyerConversationsRoute),
                    ),
                  ],
                ),
                ProfileMenuSection(
                  sectionLabel: 'buyer_section_preferences'.tr,
                  children: [
                    GetBuilder<LocaleController>(
                      builder: (locCtrl) => ProfileMenuTile(
                        icon: Icons.language_rounded,
                        title: 'buyer_profile_language'.tr,
                        subtitle: 'buyer_profile_language_sub'.tr,
                        iconColor: AppColor.primaryColor,
                        iconBg: AppColor.primarySurface,
                        trailing: ProfileTrailingChip(
                          label: (locCtrl.language?.languageCode ?? 'ar') == 'ar'
                              ? 'acct_lang_arabic_native'.tr
                              : 'acct_lang_english_native'.tr,
                        ),
                        onTap: () => Get.toNamed(AppRoute.languageSettings),
                      ),
                    ),
                    GetBuilder<LocaleController>(
                      builder: (locCtrl) => ProfileMenuTile(
                        icon: Icons.palette_outlined,
                        title: 'buyer_profile_theme'.tr,
                        subtitle: 'buyer_profile_theme_sub'.tr,
                        iconColor: AppColor.statAvg,
                        iconBg: AppColor.successLight,
                        trailing: ProfileTrailingChip(
                          label: locCtrl.isDarkMode
                              ? 'acct_theme_dark'.tr
                              : 'acct_theme_light'.tr,
                        ),
                        onTap: () => Get.toNamed(AppRoute.themeSettings),
                      ),
                    ),
                    ProfileMenuTile(
                      icon: Icons.notifications_outlined,
                      title: 'buyer_profile_notifications'.tr,
                      iconColor: AppColor.grey,
                      iconBg: Get.isDarkMode
                          ? AppColor.darkSecondBackground
                          : AppColor.secondBackground,
                      showDivider: false,
                      onTap: () => Get.toNamed(_buyerNotificationsRoute),
                    ),
                  ],
                ),
                ProfileMenuSection(
                  sectionLabel: 'buyer_section_support'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.info_outline,
                      title: 'buyer_profile_about'.tr,
                      subtitle: 'buyer_profile_about_version'.tr,
                      iconColor: AppColor.grey,
                      iconBg: Get.isDarkMode
                          ? AppColor.darkSecondBackground
                          : AppColor.secondBackground,
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),
                ProfileMenuSection(
                  children: [
                    ProfileMenuTile(
                      icon: Icons.logout_rounded,
                      title: 'buyer_profile_logout'.tr,
                      iconColor: AppColor.error,
                      iconBg: AppColor.errorLight,
                      isDestructive: true,
                      showDivider: false,
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('buyer_profile_logout_confirm_title'.tr, style: AppTextStyle.heading3),
        content: Text('buyer_profile_logout_confirm_body'.tr, style: AppTextStyle.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: AppTextStyle.buttonSmall.copyWith(color: AppColor.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('buyer_profile_logout_confirm_btn'.tr, style: AppTextStyle.buttonSmall),
          ),
        ],
      ),
    );
  }
}

class _BuyerProfileHeader extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onEditPhoto;

  const _BuyerProfileHeader({
    required this.imageUrl,
    required this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(gradient: AppColor.headerGradient),
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
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const _BuyerAvatarFallback(),
                            errorWidget: (_, __, ___) => const _BuyerAvatarFallback(),
                          )
                        : const _BuyerAvatarFallback(),
                  ),
                ),
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
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _BuyerAvatarFallback extends StatelessWidget {
  const _BuyerAvatarFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColor.primarySurface,
        child: Icon(Icons.person_rounded, size: 34, color: AppColor.primaryColor),
      );
}

class _BuyerInfoCard extends StatelessWidget {
  final String fullName;
  final String email;
  final int ordersCount;
  final int favoritesCount;
  final int reviewsCount;
  final bool isVip;

  const _BuyerInfoCard({
    required this.fullName,
    required this.email,
    required this.ordersCount,
    required this.favoritesCount,
    required this.reviewsCount,
    required this.isVip,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 52, 16, 0),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColor.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: AppTextStyle.heading2.copyWith(
                          fontSize: 17,
                          color: Get.isDarkMode ? Colors.white : AppColor.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isVip)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffF5D36A), Color(0xffD4A62A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'buyer_profile_vip_badge'.tr,
                          style: AppTextStyle.chip.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  value: '$ordersCount',
                  label: 'buyer_profile_orders_count'.tr,
                  icon: Icons.shopping_bag_outlined,
                  color: AppColor.statOrders,
                ),
                Container(width: 1, height: 30, color: AppColor.greyBorder),
                _Stat(
                  value: '$favoritesCount',
                  label: 'buyer_profile_favorites_count'.tr,
                  icon: Icons.favorite_border_rounded,
                  color: AppColor.error,
                ),
                Container(width: 1, height: 30, color: AppColor.greyBorder),
                _Stat(
                  value: '$reviewsCount',
                  label: 'buyer_profile_reviews_count'.tr,
                  icon: Icons.rate_review_outlined,
                  color: AppColor.warning,
                ),
              ],
            ),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: AppTextStyle.statNumberSmall.copyWith(
                  fontSize: 16,
                  color: Get.isDarkMode ? Colors.white : AppColor.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyle.statLabel),
        ],
      );
}

class _AccountShimmer extends StatelessWidget {
  const _AccountShimmer();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: const Column(
          children: [
            ProfileHeaderShimmer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ProfileMenuSectionShimmer(itemCount: 3),
                  ProfileMenuSectionShimmer(itemCount: 3),
                  ProfileMenuSectionShimmer(itemCount: 2),
                ],
              ),
            ),
          ],
        ),
      );
}
