// ─────────────────────────────────────────────────────────────────────────────
// lib/view/widget/buyer/cart/cart_empty_state.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/buyer/cart_controller.dart';
import '../../../../core/constant/color.dart';

class CartEmptyState extends GetView<CartController> {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Animated Icon ──────────────────────────────────────────────────
            _AnimatedCartIcon(),

            const SizedBox(height: 32),

            // ── Title ──────────────────────────────────────────────────────────
            Text(
              'empty_cart_title'.tr,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColor.primaryColor,
              ),
            ),

            const SizedBox(height: 12),

            // ── Subtitle ───────────────────────────────────────────────────────
            Text(
              'empty_cart_subtitle'.tr,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColor.greyText,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 48),

            // ── CTA Button ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor,
                      AppColor.primaryColor.withOpacity(0.75),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: controller.startShopping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    Icons.storefront_rounded,
                    color: AppColor.white,
                    size: 22,
                  ),
                  label: Text(
                    'start_shopping'.tr,
                    style: TextStyle(
                      color: AppColor.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal animated icon ──────────────────────────────────────────────────────
class _AnimatedCartIcon extends StatefulWidget {
  @override
  State<_AnimatedCartIcon> createState() => _AnimatedCartIconState();
}

class _AnimatedCartIconState extends State<_AnimatedCartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _shake = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.6, curve: Curves.elasticIn),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(_shake.value, _bounce.value),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft glow behind icon
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.primaryColor.withOpacity(0.08),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.primaryColor.withOpacity(0.12),
              ),
            ),
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
