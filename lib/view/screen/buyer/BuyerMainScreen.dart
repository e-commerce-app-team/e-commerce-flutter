import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';

import 'package:e_commerce/controller/buyer/buyer_main_controller.dart';
import 'package:e_commerce/view/screen/buyer/home/buyer_home_screen.dart';
import 'package:e_commerce/view/screen/buyer/explore/buyer_explore_screen.dart';
import 'package:e_commerce/view/screen/buyer/cart/buyer_cart_screen.dart';
import 'package:e_commerce/view/screen/buyer/orders/buyer_orders_screen.dart';
import 'package:e_commerce/view/screen/buyer/profile/buyer_profile_screen.dart';

class BuyerMainScreen extends StatelessWidget {
  const BuyerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BuyerMainController());

    return GetBuilder<BuyerMainController>(
      builder: (controller) {
        return Scaffold(
          body: IndexedStack(
            index: controller.currentIndex,
            children: const [
              BuyerHomeScreen(),
              BuyerExploreScreen(),
              BuyerCartScreen(),
              BuyerOrdersScreen(),
              BuyerProfileScreen(),
            ],
          ),
          bottomNavigationBar: _BuyerBottomNavBar(
            controller: controller,
          ),
        );
      },
    );
  }
}

class _BuyerBottomNavBar extends StatelessWidget {
  final BuyerMainController controller;

  const _BuyerBottomNavBar({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundcolor,
        border: Border(
          top: BorderSide(
            color: AppColor.grey.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                iconActive: Icons.home_rounded,
                label: "Home".tr,
                isActive: controller.currentIndex == 0,
                onTap: () => controller.changeTab(0),
              ),

              _NavItem(
                icon: Icons.explore_outlined,
                iconActive: Icons.explore,
                label: "Explore".tr,
                isActive: controller.currentIndex == 1,
                onTap: () => controller.changeTab(1),
              ),


              _NavItem(
                icon: Icons.receipt_long_outlined,
                iconActive: Icons.receipt_long,
                label: "My Orders".tr,
                isActive: controller.currentIndex == 3,
                onTap: () => controller.changeTab(3),
              ),

              _NavItem(
                icon: Icons.shopping_cart_outlined,
                iconActive: Icons.shopping_cart,
                label: "Cart".tr,
                isActive: controller.currentIndex == 2,
                onTap: () => controller.changeTab(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                iconActive: Icons.person,
                label: "Account".tr,
                isActive: controller.currentIndex == 4,
                onTap: () => controller.changeTab(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isActive ? iconActive : icon,
                      key: ValueKey(isActive),
                      size: 24,
                      color: isActive
                          ? AppColor.primaryColor
                          : AppColor.grey,
                    ),
                  ),

                  if (badgeCount > 0)
                    Positioned(
                      top: -10,
                      right: -12,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 25,
                        ),
                        decoration: BoxDecoration(
                          color:
                          AppColor.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          badgeCount > 99
                              ? "99+"
                              : badgeCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 3),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(
                  fontSize: 10,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isActive
                      ? AppColor.primaryColor
                      : AppColor.grey,
                ),
                child: Text(label),
              ),

              const SizedBox(height: 2),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}