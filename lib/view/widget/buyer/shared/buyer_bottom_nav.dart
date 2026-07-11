import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });
}

const List<_NavItemData> _kBuyerNavItems = [
  _NavItemData(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    labelKey: 'Home',
  ),
  _NavItemData(
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    labelKey: 'buyer_nav_explore',
  ),
  _NavItemData(
    icon: Icons.shopping_bag_outlined,
    activeIcon: Icons.shopping_bag_rounded,
    labelKey: 'buyer_nav_cart',
  ),
  _NavItemData(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    labelKey: 'buyer_nav_orders',
  ),
  _NavItemData(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    labelKey: 'Account',
  ),
];

/// Index of the cart tab inside [_kBuyerNavItems], used to attach the
/// item-count badge to the right icon.
const int kBuyerCartTabIndex = 2;

/// Custom floating-tab bottom navigation for the buyer app.
///
/// Deliberately not a stock [BottomNavigationBar]: the active tab is
/// rendered as a larger gradient-filled circle that visually rises above
/// the bar, while the rest stay flat and quiet. This is a controlled
/// widget — it owns no state — so a controller can drive [currentIndex]
/// and react to [onTap] later without any change to this file.
class BuyerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  static const double _barHeight = 64;
  static const double _stackHeight = 82;

  const BuyerBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: _stackHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: _barHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.backgroundcolor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: AppColor.bottomNavShadow,
              ),
            ),
            Row(
              children: List.generate(_kBuyerNavItems.length, (index) {
                final isActive = index == currentIndex;
                final item = _kBuyerNavItems[index];
                return Expanded(
                  child: _NavTab(
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    label: item.labelKey.tr,
                    isActive: isActive,
                    badgeCount: index == kBuyerCartTabIndex ? cartCount : 0,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = isActive ? 54 : 40;

    return Semantics(
      selected: isActive,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: BuyerBottomNav._stackHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: iconSize,
                height: iconSize,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isActive ? AppColor.mainGradient : null,
                  boxShadow: isActive ? AppColor.primaryShadow : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        isActive ? activeIcon : icon,
                        size: 22,
                        color: isActive ? AppColor.white : AppColor.grey,
                      ),
                    ),
                    if (badgeCount > 0)
                      PositionedDirectional(
                        top: -2,
                        end: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          constraints: const BoxConstraints(minWidth: 17),
                          decoration: BoxDecoration(
                            color: isActive ? AppColor.black : AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.backgroundcolor, width: 1.5),
                          ),
                          child: Text(
                            badgeCount > 9 ? '9+' : '$badgeCount',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.badge,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isActive
                    ? AppTextStyle.navLabelActive.copyWith(color: AppColor.primaryColor)
                    : AppTextStyle.navLabel.copyWith(color: AppColor.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
