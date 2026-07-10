import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_profile_controller.dart';
import 'package:e_commerce/core/localization/changelocal.dart';
import 'package:e_commerce/core/class/handling_dataview.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/view/widget/seller/profile/profile_widgets.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerProfileController());

    return GetBuilder<SellerProfileController>(
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
  final SellerProfileController ctrl;
  const _AccountBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final profile = ctrl.profile!;
    return RefreshIndicator(
      onRefresh: ctrl.refreshProfile,
      color: AppColor.primaryColor,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics:
        const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(
              profile: profile,
              onEditPhoto: () => Get.toNamed(AppRoute.storeEdit),
              onEditCover: () => Get.toNamed(AppRoute.storeEdit),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProfileInfoCard(profile: profile),
                const SizedBox(height: 20),

                ProfileMenuSection(
                  sectionLabel: 'acct_section_store'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.storefront_outlined,
                      title: 'acct_edit_store_title'.tr,
                      subtitle: profile.storeName,
                      iconColor: AppColor.primaryColor,
                      iconBg: AppColor.primarySurface,
                      onTap: () => Get.toNamed(AppRoute.storeEdit),
                    ),
                    ProfileMenuTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'acct_shipping_title'.tr,
                      subtitle: ctrl.shippingMethod == 'our_delivery'
                          ? 'acct_shipping_sub_platform'.tr
                          : 'acct_shipping_sub_self'.tr,
                      iconColor: AppColor.statOrders,
                      iconBg: const Color(0xffEEEDFE),
                      onTap: () => Get.toNamed(AppRoute.shippingSettings),
                    ),
                    ProfileMenuTile(
                      icon: Icons.star_outline_rounded,
                      title: 'acct_reviews_title'.tr,
                      subtitle: '${profile.reviewCount} ${'acct_reviews_count'.tr}',
                      iconColor: const Color(0xffF39C12),
                      iconBg: AppColor.warningLight,
                      trailing: const ProfileComingSoonChip(),
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),

                ProfileMenuSection(
                  sectionLabel: 'acct_section_marketing'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.casino_outlined,
                      title: 'acct_spin_title'.tr,
                      subtitle: 'acct_spin_sub'.tr,
                      iconColor: AppColor.primaryColor,
                      iconBg: AppColor.primarySurface,
                      onTap: () => Get.toNamed(AppRoute.spinWheele),
                    ),
                    ProfileMenuTile(
                      icon: Icons.local_offer_outlined,
                      title: 'acct_coupons_title'.tr,
                      iconColor: AppColor.success,
                      iconBg: AppColor.successLight,
                      onTap: () => Get.toNamed(AppRoute.coupons),
                    ),
                    ProfileMenuTile(
                      icon: Icons.campaign_outlined,
                      title: 'acct_ads_title'.tr,
                      iconColor: AppColor.info,
                      iconBg: AppColor.infoLight,
                      showDivider: false,
                      onTap: () => Get.toNamed(AppRoute.ads),
                    ),
                  ],
                ),

                if (ctrl.isWholesale)
                  ProfileMenuSection(
                    sectionLabel: 'acct_section_enterprise'.tr,
                    children: [
                      ProfileMenuTile(
                        icon: Icons.people_outline,
                        title: 'acct_staff_title'.tr,
                        iconColor: AppColor.statOrders,
                        iconBg: const Color(0xffEEEDFE),
                        onTap: () => Get.toNamed(AppRoute.sellerStaff),
                      ),
                      ProfileMenuTile(
                        icon: Icons.store_mall_directory_outlined,
                        title: 'acct_branches_title'.tr,
                        iconColor: AppColor.statViews,
                        iconBg: AppColor.infoLight,
                        onTap: () => Get.toNamed(AppRoute.sellerBranches),
                      ),
                      ProfileMenuTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'acct_invoices_title'.tr,
                        iconColor: AppColor.warning,
                        iconBg: AppColor.warningLight,
                        showDivider: false,
                        onTap: () => Get.toNamed(AppRoute.sellerInvoices),
                      ),
                    ],
                  ),

                ProfileMenuSection(
                  sectionLabel: 'acct_section_preferences'.tr,
                  children: [
                    GetBuilder<LocaleController>(
                      builder: (locCtrl) => ProfileMenuTile(
                        icon: Icons.language_rounded,
                        title: 'acct_language_title'.tr,
                        subtitle: 'acct_language_sub'.tr,
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
                        title: 'acct_theme_title'.tr,
                        subtitle: 'acct_theme_sub'.tr,
                        iconColor: AppColor.statAvg,
                        iconBg: AppColor.successLight,
                        trailing: ProfileTrailingChip(
                          label: locCtrl.isDarkMode
                              ? 'acct_theme_dark'.tr
                              : 'acct_theme_light'.tr,
                        ),
                        showDivider: false,
                        onTap: () => Get.toNamed(AppRoute.themeSettings),
                      ),
                    ),
                  ],
                ),

                ProfileMenuSection(
                  sectionLabel: 'acct_section_security'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'acct_change_password_title'.tr,
                      iconColor: AppColor.grey,
                      iconBg: Get.isDarkMode
                          ? AppColor.darkSecondBackground
                          : AppColor.secondBackground,
                      onTap: () => Get.toNamed(AppRoute.changePassword),
                    ),
                    ProfileMenuTile(
                      icon: Icons.notifications_outlined,
                      title: 'acct_notifications_title'.tr,
                      iconColor: AppColor.grey,
                      iconBg: Get.isDarkMode
                          ? AppColor.darkSecondBackground
                          : AppColor.secondBackground,
                      trailing: const ProfileComingSoonChip(),
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),

                ProfileMenuSection(
                  sectionLabel: 'acct_section_support'.tr,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.headset_mic_outlined,
                      title: 'acct_support_title'.tr,
                      iconColor: AppColor.info,
                      iconBg: AppColor.infoLight,
                      onTap: () => Get.toNamed(AppRoute.sellerSupport),
                    ),
                    ProfileMenuTile(
                      icon: Icons.info_outline_rounded,
                      title: 'acct_about_title'.tr,
                      subtitle: 'acct_about_version'.tr,
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
                      title: 'acct_logout_title'.tr,
                      iconColor: AppColor.error,
                      iconBg: AppColor.errorLight,
                      isDestructive: true,
                      showDivider: false,
                      onTap: () => _confirmLogout(context, ctrl),
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

  void _confirmLogout(BuildContext context, SellerProfileController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('acct_logout_confirm_title'.tr, style: AppTextStyle.heading3),
        content: Text('acct_logout_confirm_body'.tr, style: AppTextStyle.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: AppTextStyle.buttonSmall.copyWith(color: AppColor.grey)),
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
            child: Text('acct_logout_confirm_btn'.tr, style: AppTextStyle.buttonSmall),
          ),
        ],
      ),
    );
  }
}

class _AccountShimmer extends StatelessWidget {
  const _AccountShimmer();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Column(children: [
      const ProfileHeaderShimmer(),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          ProfileMenuSectionShimmer(itemCount: 3),
          ProfileMenuSectionShimmer(itemCount: 3),
          ProfileMenuSectionShimmer(itemCount: 2),
        ]),
      ),
    ]),
  );
}