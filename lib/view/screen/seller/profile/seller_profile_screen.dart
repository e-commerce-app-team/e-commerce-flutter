import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_profile_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:e_commerce/view/widget/seller/profile/profile_widgets.dart';
import '../../../../core/constant/routes.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // يفضل دائماً حقن الكنترولر عبر الـ Bindings، ولكن إذا استخدمت Get.put هنا تأكد من تنظيفها
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

                  // ---------------- قسم إعدادات المتجر ----------------
                  ProfileMenuSection(
                    sectionLabel: 'my_store'.tr, // متجري
                    children: [
                      ProfileMenuTile(
                        icon: Icons.storefront_outlined,
                        title: 'edit_store_details'.tr, // تعديل بيانات المتجر
                        subtitle: ctrl.profile!.storeName,
                        iconColor: AppColor.primaryColor,
                        iconBg: AppColor.primarySurface,
                        onTap: () => Get.toNamed(AppRoute.storeEdit),
                      ),
                      ProfileMenuTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'shipping_settings'.tr, // إعدادات الشحن
                        subtitle: ctrl.shippingMethod == 'our_delivery'
                            ? 'platform_delivery'.tr  // توصيل المنصة
                            : 'self_shipping'.tr,     // شحن ذاتي
                        iconColor: AppColor.statOrders,
                        iconBg: const Color(0xffEEEDFE),
                        onTap: () => Get.toNamed(AppRoute.shippingSettings),
                      ),
                      ProfileMenuTile(
                        icon: Icons.star_outline_rounded,
                        title: 'ratings_and_reviews'.tr, // التقييمات والمراجعات
                        subtitle: '${ctrl.profile!.reviewCount} ${'review'.tr}',
                        iconColor: const Color(0xffF39C12),
                        iconBg: AppColor.warningLight,
                        showDivider: false,
                        onTap: () {
                          // TODO: Get.toNamed(AppRoute.reviews)
                        },
                      ),
                    ],
                  ),

                  // ---------------- قسم التسويق ----------------
                  ProfileMenuSection(
                    sectionLabel: 'marketing'.tr, // التسويق
                    children: [
                      ProfileMenuTile(
                        icon: Icons.casino_outlined,
                        title: 'spin_wheel'.tr, // دولاب الحظ
                        subtitle: 'spin_wheel_desc'.tr, // اشترك لتقديم عروض للمشترين
                        iconColor: AppColor.primaryColor,
                        iconBg: AppColor.primarySurface,
                        onTap: () {
                          Get.toNamed(AppRoute.spinWheele);
                        },
                      ),
                      ProfileMenuTile(
                        icon: Icons.local_offer_outlined,
                        title: 'discount_coupons'.tr, // كوبونات الخصم
                        iconColor: AppColor.success,
                        iconBg: AppColor.successLight,
                        onTap: () {
                          // TODO: Get.toNamed(AppRoute.coupons)
                        },
                      ),
                      ProfileMenuTile(
                        icon: Icons.campaign_outlined,
                        title: 'advertisements'.tr, // الإعلانات
                        iconColor: AppColor.info,
                        iconBg: AppColor.infoLight,
                        showDivider: false,
                        onTap: () {
                          Get.toNamed(AppRoute.ads);
                        },
                      ),
                    ],
                  ),

                  // ---------------- قسم المؤسسة (للتجار من نوع شركات) ----------------
                  if (ctrl.isWholesale)
                    ProfileMenuSection(
                      sectionLabel: 'enterprise'.tr, // المؤسسة
                      children: [
                        ProfileMenuTile(
                          icon: Icons.people_outline,
                          title: 'staff_management'.tr, // إدارة الموظفين
                          iconColor: AppColor.statOrders,
                          iconBg: const Color(0xffEEEDFE),
                          onTap: () {
                            // TODO: Get.toNamed(AppRoute.staff)
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.store_mall_directory_outlined,
                          title: 'branches_and_warehouses'.tr, // الفروع والمستودعات
                          iconColor: AppColor.statViews,
                          iconBg: AppColor.infoLight,
                          onTap: () {
                            // TODO: Get.toNamed(AppRoute.branches)
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'tax_invoices'.tr, // الفواتير الضريبية
                          iconColor: AppColor.warning,
                          iconBg: AppColor.warningLight,
                          showDivider: false,
                          onTap: () {
                            Get.toNamed(AppRoute.sellerInvoices);
                          },
                        ),
                      ],
                    ),

                  // ---------------- قسم الحساب والأمان ----------------
                  ProfileMenuSection(
                    sectionLabel: 'account_and_security'.tr, // الحساب والأمان
                    children: [
                      ProfileMenuTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'change_password'.tr, // تغيير كلمة المرور
                        iconColor: AppColor.grey,
                        iconBg: AppColor.secondBackground,
                        onTap: () {
                          Get.toNamed(AppRoute.changePassword);
                        },
                      ),
                      ProfileMenuTile(
                        icon: Icons.devices_outlined,
                        title: 'active_devices'.tr, // الأجهزة النشطة
                        iconColor: AppColor.grey,
                        iconBg: AppColor.secondBackground,
                        onTap: () {
                          // TODO: Get.toNamed(AppRoute.devices)
                        },
                      ),
                      ProfileMenuTile(
                        icon: Icons.notifications_outlined,
                        title: 'notification_settings'.tr, // إعدادات الإشعارات
                        iconColor: AppColor.grey,
                        iconBg: AppColor.secondBackground,
                        showDivider: false,
                        onTap: () {
                          // TODO: Get.toNamed(AppRoute.notifSettings)
                        },
                      ),
                    ],
                  ),

                  // ---------------- قسم الدعم الفني ----------------
                  ProfileMenuSection(
                    sectionLabel: 'support'.tr, // الدعم
                    children: [
                      ProfileMenuTile(
                        icon: Icons.headset_mic_outlined,
                        title: 'seller_support_center'.tr, // مركز دعم التجار
                        iconColor: AppColor.info,
                        iconBg: AppColor.infoLight,
                        onTap: () {
                          // TODO: Get.toNamed(AppRoute.support)
                        },
                      ),
                      ProfileMenuTile(
                        icon: Icons.info_outline_rounded,
                        title: 'about_app'.tr, // حول التطبيق
                        subtitle: 'الإصدار 1.0.0', // يمكن تركها هكذا أو وضعها بالـ Info
                        iconColor: AppColor.grey,
                        iconBg: AppColor.secondBackground,
                        showDivider: false,
                        onTap: () {},
                      ),
                    ],
                  ),

                  // ---------------- تسجيل الخروج ----------------
                  ProfileMenuSection(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.logout_rounded,
                        title: 'logout'.tr, // تسجيل الخروج
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
      ),
    );
  }

  void _confirmLogout(BuildContext context, SellerProfileController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('logout'.tr, style: AppTextStyle.heading3),
        content: Text('logout_confirm_msg'.tr, style: AppTextStyle.bodyMedium),
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
            child: Text('logout_button'.tr, style: AppTextStyle.buttonSmall),
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