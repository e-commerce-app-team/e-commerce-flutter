import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_profile_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/screen/seller/profile/shipping_settings_screen.dart';
import 'package:e_commerce/view/screen/seller/profile/store_edit_screen.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:e_commerce/view/widget/seller/profile/profile_widgets.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerProfileController());
    return GetBuilder<SellerProfileController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _ProfileShimmer()
            : ctrl.profile == null
                ? const SizedBox.shrink()
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ProfileHeader(
                          profile:      ctrl.profile!,
                          onEditPhoto:  ctrl.pickProfilePhoto,
                          onEditCover:  ctrl.pickCover,
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([

                            ProfileInfoCard(profile: ctrl.profile!),
                            const SizedBox(height: 20),

                            if (ctrl.wallet != null) ...[
                              WalletCard(
                                wallet: ctrl.wallet!,
                                onWithdraw: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) =>
                                      const WithdrawalSheet(),
                                ),
                              ),
                              const SizedBox(height: 8),

                              if (ctrl.wallet!.transactions.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    boxShadow: AppColor.cardShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('آخر المعاملات',
                                          style: AppTextStyle.heading3
                                              .copyWith(fontSize: 14)),
                                      const Divider(
                                          height: 14,
                                          color: AppColor.greyBorder),
                                      ...ctrl.wallet!.transactions
                                          .map((tx) =>
                                              TransactionItem(tx: tx)),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                            ],

                            ProfileMenuSection(
                              sectionLabel: 'متجري',
                              children: [
                                ProfileMenuTile(
                                  icon: Icons.storefront_outlined,
                                  title: 'تعديل بيانات المتجر',
                                  subtitle: ctrl.profile!.storeName,
                                  iconColor: AppColor.primaryColor,
                                  iconBg: AppColor.primarySurface,
                                  onTap: () => Get.to(
                                    () => const StoreEditScreen(),
                                    transition: Transition.cupertino,
                                  ),
                                ),
                                ProfileMenuTile(
                                  icon: Icons.local_shipping_outlined,
                                  title: 'إعدادات الشحن',
                                  subtitle: ctrl.shippingMethod ==
                                          'our_delivery'
                                      ? 'توصيل المنصة'
                                      : 'شحن ذاتي',
                                  iconColor: AppColor.statOrders,
                                  iconBg:
                                      const Color(0xffEEEDFE),
                                  onTap: () => Get.to(
                                    () => const ShippingSettingsScreen(),
                                    transition: Transition.cupertino,
                                  ),
                                ),
                                ProfileMenuTile(
                                  icon: Icons.star_outline_rounded,
                                  title: 'التقييمات والمراجعات',
                                  subtitle:
                                      '${ctrl.profile!.reviewCount} تقييم',
                                  iconColor: const Color(0xffF39C12),
                                  iconBg: AppColor.warningLight,
                                  showDivider: false,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.reviews)
                                  },
                                ),
                              ],
                            ),

                            ProfileMenuSection(
                              sectionLabel: 'التسويق',
                              children: [
                                ProfileMenuTile(
                                  icon: Icons.casino_outlined,
                                  title: 'دولاب الحظ',
                                  subtitle:
                                      'اشترك لتقديم عروض للمشترين',
                                  iconColor: AppColor.primaryColor,
                                  iconBg: AppColor.primarySurface,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.spinWheel)
                                  },
                                ),
                                ProfileMenuTile(
                                  icon: Icons.local_offer_outlined,
                                  title: 'كوبونات الخصم',
                                  iconColor: AppColor.success,
                                  iconBg: AppColor.successLight,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.coupons)
                                  },
                                ),
                                ProfileMenuTile(
                                  icon: Icons.campaign_outlined,
                                  title: 'الإعلانات',
                                  iconColor: AppColor.info,
                                  iconBg: AppColor.infoLight,
                                  showDivider: false,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.ads)
                                  },
                                ),
                              ],
                            ),

                            if (ctrl.isWholesale)
                              ProfileMenuSection(
                                sectionLabel: 'المؤسسة',
                                children: [
                                  ProfileMenuTile(
                                    icon: Icons.people_outline,
                                    title: 'إدارة الموظفين',
                                    iconColor: AppColor.statOrders,
                                    iconBg: const Color(0xffEEEDFE),
                                    onTap: () {
                                      // TODO: Get.toNamed(AppRoute.staff)
                                    },
                                  ),
                                  ProfileMenuTile(
                                    icon: Icons.store_mall_directory_outlined,
                                    title: 'الفروع والمستودعات',
                                    iconColor: AppColor.statViews,
                                    iconBg: AppColor.infoLight,
                                    onTap: () {
                                      // TODO: Get.toNamed(AppRoute.branches)
                                    },
                                  ),
                                  ProfileMenuTile(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'الفواتير الضريبية',
                                    iconColor: AppColor.warning,
                                    iconBg: AppColor.warningLight,
                                    showDivider: false,
                                    onTap: () {
                                      // TODO: Get.toNamed(AppRoute.invoices)
                                    },
                                  ),
                                ],
                              ),

                            ProfileMenuSection(
                              sectionLabel: 'الحساب والأمان',
                              children: [
                                ProfileMenuTile(
                                  icon: Icons.lock_outline_rounded,
                                  title: 'تغيير كلمة المرور',
                                  iconColor: AppColor.grey,
                                  iconBg: AppColor.secondBackground,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.changePassword)
                                  },
                                ),
                                ProfileMenuTile(
                                  icon: Icons.devices_outlined,
                                  title: 'الأجهزة النشطة',
                                  iconColor: AppColor.grey,
                                  iconBg: AppColor.secondBackground,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.devices)
                                  },
                                ),
                                ProfileMenuTile(
                                  icon: Icons.notifications_outlined,
                                  title: 'إعدادات الإشعارات',
                                  iconColor: AppColor.grey,
                                  iconBg: AppColor.secondBackground,
                                  showDivider: false,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.notifSettings)
                                  },
                                ),
                              ],
                            ),

                            ProfileMenuSection(
                              sectionLabel: 'الدعم',
                              children: [
                                ProfileMenuTile(
                                  icon: Icons.headset_mic_outlined,
                                  title: 'مركز دعم التجار',
                                  iconColor: AppColor.info,
                                  iconBg: AppColor.infoLight,
                                  onTap: () {
                                    // TODO: Get.toNamed(AppRoute.support)
                                  },
                                ),
                                ProfileMenuTile(
                                  icon: Icons.info_outline_rounded,
                                  title: 'حول التطبيق',
                                  subtitle: 'الإصدار 1.0.0',
                                  iconColor: AppColor.grey,
                                  iconBg: AppColor.secondBackground,
                                  showDivider: false,
                                  onTap: () {},
                                ),
                              ],
                            ),

                            ProfileMenuSection(
                              children: [
                                ProfileMenuTile(
                                  icon: Icons.logout_rounded,
                                  title: 'تسجيل الخروج',
                                  iconColor: AppColor.error,
                                  iconBg: AppColor.errorLight,
                                  isDestructive: true,
                                  showDivider: false,
                                  onTap: () => _confirmLogout(
                                      context, ctrl),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _confirmLogout(
      BuildContext context, SellerProfileController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('تسجيل الخروج',
            style: AppTextStyle.heading3),
        content: Text('هل أنت متأكد من تسجيل الخروج؟',
            style: AppTextStyle.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء',
                style:
                    AppTextStyle.buttonSmall.copyWith(
                        color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('خروج',
                style: AppTextStyle.buttonSmall),
          ),
        ],
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Column(children: [
      const ShimmerBox(width: double.infinity, height: 130),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              ShimmerBox(width: 140, height: 16),
              ShimmerBox(width: 60,  height: 24, radius: 12),
            ]),
            SizedBox(height: 12),
            ShimmerBox(width: double.infinity, height: 10),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              ShimmerBox(width: 50, height: 36),
              ShimmerBox(width: 50, height: 36),
              ShimmerBox(width: 50, height: 36),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ]),
  );
}
