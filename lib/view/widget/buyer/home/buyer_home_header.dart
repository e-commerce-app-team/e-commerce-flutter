import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';

/// Picks the right greeting translation key for the current time of day.
/// Pure presentation helper — no state, no side effects.
String _greetingKey() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'good_morning';
  if (hour < 18) return 'good_afternoon';
  return 'good_evening';
}

/// Top of the buyer home screen: greeting, delivery location, the
/// notification / cart shortcuts, and the search entry point.
///
/// This widget is purely presentational — every action is exposed as a
/// callback so a controller can be wired in later without touching layout.
class BuyerHomeHeader extends StatelessWidget {
  final String userName;
  final String deliveryLocation;
  final int notificationCount;
  final int cartCount;
  final String searchHint;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onSearchTap;

  const BuyerHomeHeader({
    Key? key,
    required this.userName,
    required this.deliveryLocation,
    this.notificationCount = 0,
    this.cartCount = 0,
    this.searchHint = '',
    this.onLocationTap,
    this.onNotificationTap,
    this.onCartTap,
    this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greetingKey().tr,
                    style: AppTextStyle.labelMedium.copyWith(
                      color: AppColor.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: AppTextStyle.displaySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onLocationTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColor.primaryColor,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            deliveryLocation,
                            style: AppTextStyle.bodySmall.copyWith(
                              color: AppColor.greyText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColor.greyText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _IconBadgeButton(
              icon: Icons.notifications_outlined,
              count: notificationCount,
              onTap: onNotificationTap,
            ),
            const SizedBox(width: 10),
            _IconBadgeButton(
              icon: Icons.shopping_bag_outlined,
              count: cartCount,
              onTap: onCartTap,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SearchField(hint: searchHint, onTap: onSearchTap),
      ],
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  const _IconBadgeButton({
    required this.icon,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColor.backgroundcolor,
          shape: BoxShape.circle,
          boxShadow: AppColor.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(icon, color: AppColor.black, size: 22),
            ),
            if (count > 0)
              PositionedDirectional(
                top: -2,
                end: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.backgroundcolor, width: 1.5),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.badge,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;

  const _SearchField({required this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColor.backgroundcolor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColor.grey, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                style: AppTextStyle.inputHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(width: 1, height: 22, color: AppColor.greyBorder),
            const SizedBox(width: 10),
            Icon(Icons.tune_rounded, color: AppColor.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
