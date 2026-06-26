import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/controller/seller/seller_main_controller.dart';

class SellerDrawer extends StatelessWidget {
  const SellerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerMainController>(
      builder: (controller) {
        return Drawer(
          backgroundColor: AppColor.backgroundcolor,
          child: SafeArea(
            child: Column(
              children: [
                _DrawerHeader(
                  storeName: controller.sellerName,
                  email: controller.sellerEmail,
                  sellerType: controller.sellerType,
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      _DrawerGroup(label: "القيادة"),
                      _DrawerItem(
                        icon: Icons.dashboard_outlined,
                        label: "لوحة القيادة",
                        onTap: () {
                          Get.back();
                          controller.changeTab(0);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.visibility_outlined,
                        label: "عرض كمشتري",
                        badge: "معاينة",
                        badgeColor: AppColor.primaryColor,
                        onTap: () {
                          Get.back();
                          //  Get.toNamed(AppRoute.storePreview)
                        },
                      ),

                      _DrawerGroup(label: "التسويق والنمو"),
                      _DrawerItem(
                        icon: Icons.casino_outlined,
                        label: "دولاب الحظ",
                        onTap: () {
                          Get.back();
                            Get.toNamed(AppRoute.spinWheele);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.local_offer_outlined,
                        label: "كوبونات الخصم",
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppRoute.coupons);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.campaign_outlined,
                        label: "الإعلانات والرعاية",
                        onTap: () {
                          Get.back();
                           Get.toNamed(AppRoute.ads);
                        },
                      ),

                      _DrawerGroup(label: "الإدارة المالية"),
                      _DrawerItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "المحفظة والسحب",
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppRoute.sellerWallet);
                        },
                      ),

                      if (controller.isWholesale)
                        _DrawerItem(
                          icon: Icons.receipt_long_outlined,
                          label: "الفواتير والضرائب",
                          badge: "شركات",
                          onTap: () {
                            Get.back();
                             Get.toNamed(AppRoute.sellerInvoices);
                          },
                        ),

                      if (controller.isWholesale) ...[
                        _DrawerGroup(label: "إدارة المؤسسة"),
                        _DrawerItem(
                          icon: Icons.people_outline,
                          label: "إدارة الموظفين",
                          badge: "شركات",
                          onTap: () {
                            Get.back();
                           Get.toNamed(AppRoute.sellerStaff);
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.store_outlined,
                          label: "الفروع والمستودعات",
                          badge: "شركات",
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoute.sellerBranches);
                          },
                        ),
                      ],

                      _DrawerGroup(label: "الدعم والنظام"),
                      _DrawerItem(
                        icon: Icons.headset_mic_outlined,
                        label: "مركز دعم التجار",
                        onTap: () {
                          Get.back();
                           Get.toNamed(AppRoute.sellerSupport
                           );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        label: "الإعدادات",
                        onTap: () {
                          Get.back();
                          controller.changeTab(4);
                        },
                      ),

                      const Divider(thickness: 0.5),

                      _DrawerItem(
                        icon: Icons.logout,
                        label: "تسجيل الخروج",
                        color: Colors.red.shade400,
                        onTap: () {
                          Get.back();
                          // TODO: controller.logout()
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String storeName;
  final String email;
  final String sellerType;

  const _DrawerHeader({
    required this.storeName,
    required this.email,
    required this.sellerType,
  });

  @override
  Widget build(BuildContext context) {
    final isWholesale = sellerType == "wholesale";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        gradient: AppColor.mainGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),

          Text(
            storeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),

          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 11,
              fontFamily: "Cairo",
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Text(
              isWholesale ? "بائع مؤسسي / شركة" : "بائع فردي",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: "Cairo",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerGroup extends StatelessWidget {
  final String label;
  const _DrawerGroup({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColor.grey,
          letterSpacing: 0.8,
          fontFamily: "Cairo",
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColor.black;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: (color ?? AppColor.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: color ?? AppColor.primaryColor),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: itemColor,
              fontFamily: "Cairo",
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: badge != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColor.grey).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (badgeColor ?? AppColor.grey).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: badgeColor ?? AppColor.grey,
                      fontFamily: "Cairo",
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
