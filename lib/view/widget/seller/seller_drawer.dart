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
            bottom: false,
            child: Column(
              children: [
                _buildPremiumHeader(controller),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.backgroundcolor,
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        _DrawerGroup(label: "drawer_leadership".tr),
                        _DrawerItem(
                          icon: Icons.dashboard_rounded,
                          label: "drawer_dashboard".tr,
                          onTap: () {
                            Get.back();
                            controller.changeTab(0);
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.storefront_rounded,
                          label: "drawer_view_as_buyer".tr,
                          badge: "drawer_preview".tr,
                          badgeColor: AppColor.primaryColor,
                          onTap: () {
                            Get.back();
                            //  Get.toNamed(AppRoute.storePreview)
                          },
                        ),

                        _DrawerGroup(label: "drawer_marketing_growth".tr),
                        _DrawerItem(
                          icon: Icons.casino_rounded,
                          label: "drawer_spin_wheel".tr,
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoute.spinWheele);
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.local_activity_rounded,
                          label: "drawer_discount_coupons".tr,
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoute.coupons);
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.campaign_rounded,
                          label: "drawer_ads_sponsorships".tr,
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoute.ads);
                          },
                        ),

                        _DrawerGroup(label: "drawer_financial_management".tr),
                        _DrawerItem(
                          icon: Icons.account_balance_wallet_rounded,
                          label: "drawer_wallet_withdraw".tr,
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoute.sellerWallet);
                          },
                        ),

                        if (controller.isWholesale)
                          _DrawerItem(
                            icon: Icons.receipt_long_rounded,
                            label: "drawer_invoices_taxes".tr,
                            badge: "drawer_companies".tr,
                            onTap: () {
                              Get.back();
                              Get.toNamed(AppRoute.sellerInvoices);
                            },
                          ),

                        if (controller.isWholesale) ...[
                          _DrawerGroup(label: "drawer_enterprise_management".tr),
                          _DrawerItem(
                            icon: Icons.people_alt_rounded,
                            label: "drawer_employee_management".tr,
                            badge: "drawer_companies".tr,
                            onTap: () {
                              Get.back();
                              Get.toNamed(AppRoute.sellerStaff);
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.domain_rounded,
                            label: "drawer_branches_warehouses".tr,
                            badge: "drawer_companies".tr,
                            onTap: () {
                              Get.back();
                              Get.toNamed(AppRoute.sellerBranches);
                            },
                          ),
                        ],

                        _DrawerGroup(label: "drawer_support_system".tr),
                        _DrawerItem(
                          icon: Icons.support_agent_rounded,
                          label: "drawer_seller_support_center".tr,
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoute.sellerSupport);
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.settings_rounded,
                          label: "drawer_settings".tr,
                          onTap: () {
                            Get.back();
                            controller.changeTab(4);
                          },
                        ),

                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Divider(thickness: 1, color: AppColor.grey.withOpacity(0.2)),
                        ),
                        const SizedBox(height: 8),

                        _DrawerItem(
                          icon: Icons.logout_rounded,
                          label: "drawer_logout".tr,
                          color: Colors.redAccent,
                          isLogout: true,
                          onTap: () {
                            Get.back();
                            // TODO: controller.logout()
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumHeader(SellerMainController controller) {
    final isWholesale = controller.sellerType == "wholesale";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: AppColor.mainGradient,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: AppColor.primaryColor,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isWholesale ? Icons.domain_rounded : Icons.person_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isWholesale
                          ? "drawer_enterprise_seller".tr
                          : "drawer_individual_seller".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            controller.sellerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.email_rounded, color: Colors.white.withOpacity(0.8), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  controller.sellerEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColor.grey.withOpacity(0.8),
              letterSpacing: 1.2,
              fontFamily: "Cairo",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: AppColor.grey.withOpacity(0.2),
            ),
          ),
        ],
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
  final bool isLogout;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.color,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColor.black;
    final iconColor = color ?? AppColor.primaryColor;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isLogout ? Colors.redAccent.withOpacity(0.05) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: iconColor.withOpacity(0.1),
          highlightColor: iconColor.withOpacity(0.05),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isLogout 
                        ? Colors.redAccent.withOpacity(0.1) 
                        : iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: itemColor,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppColor.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (badgeColor ?? AppColor.grey).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeColor ?? AppColor.grey,
                        fontFamily: "Cairo",
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColor.grey.withOpacity(0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
