import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class BuyerHomeHeader extends StatelessWidget {
  final String? userName;
  final String? deliveryLocation;
  final int notificationCount;
  final int cartCount;
  final String searchHint;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onSearchTap;

  const BuyerHomeHeader({
    super.key,
    this.userName,
    this.deliveryLocation,
    this.notificationCount = 0,
    this.cartCount = 0,
    this.searchHint = '',
    this.onLocationTap,
    this.onNotificationTap,
    this.onCartTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColor.headerGradient.createShader(bounds),
                child: const Text(
                  'NEXUS',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ),
            _IconButton(
              icon: Icons.notifications_outlined,
              count: notificationCount,
              onTap: onNotificationTap,
            ),
            const SizedBox(width: 10),
            _IconButton(
              icon: Icons.shopping_bag_outlined,
              count: cartCount,
              onTap: onCartTap,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SearchBar(hint: searchHint, onTap: onSearchTap),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  const _IconButton({required this.icon, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return const SizedBox.shrink();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, color: AppColor.black, size: 22)),
            if (count > 0)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$count', textAlign: TextAlign.center, style: AppTextStyle.badge),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;

  const _SearchBar({required this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColor.secondBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.greyBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColor.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint.isEmpty ? 'Search NEXUS' : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.inputHint,
              ),
            ),
            Icon(Icons.tune_rounded, color: AppColor.primaryColor),
          ],
        ),
      ),
    );
  }
}
