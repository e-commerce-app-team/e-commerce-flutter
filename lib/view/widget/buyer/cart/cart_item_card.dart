// ─────────────────────────────────────────────────────────────────────────────
// lib/view/widget/buyer/cart/cart_item_card.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/buyer/cart_controller.dart';
import '../../../../core/constant/color.dart';
import '../../../../data/models/buyer/cart_models.dart';

class CartItemCard extends StatefulWidget {
  final CartItem item;
  final CartController controller;

  const CartItemCard({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
    with SingleTickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: ValueKey(widget.item.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) => widget.controller.removeItem(widget.item.id),
          background: _DismissBackground(),
          child: _ItemCard(
            item: widget.item,
            controller: widget.controller,
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        title: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColor.danger, size: 26),
            const SizedBox(width: 10),
            Text(
              'remove_item'.tr,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'remove_item_confirm'.tr,
          style: TextStyle(color: AppColor.greyText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child:
                Text('cancel'.tr, style: TextStyle(color: AppColor.greyText)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child:
                Text('remove'.tr, style: TextStyle(color: AppColor.white)),
          ),
        ],
      ),
    );
  }
}

// ── Dismiss background (red swipe indicator) ─────────────────────────────────
class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.only(left: 24),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColor.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_rounded, color: AppColor.danger, size: 30),
          const SizedBox(height: 4),
          Text(
            'delete'.tr,
            style: TextStyle(
              color: AppColor.danger,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── The actual card ────────────────────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  final CartItem item;
  final CartController controller;

  const _ItemCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.07),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image ───────────────────────────────────────────────
            _ProductImage(imageUrl: item.imageUrl),

            const SizedBox(width: 14),

            // ── Product details ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store label
                  _StoreChip(storeName: item.storeName),
                  const SizedBox(height: 5),

                  // Product name
                  Text(
                    item.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Variant badge
                  if (item.variant != null) ...[
                    const SizedBox(height: 6),
                    _VariantBadge(variant: item.variant!),
                  ],

                  const SizedBox(height: 12),

                  // Price row + quantity control
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _PriceColumn(item: item)),
                      _QuantityControl(
                          item: item, controller: controller),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product image ──────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String imageUrl;
  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _ImagePlaceholder();
        },
        errorBuilder: (_, __, ___) => _ImagePlaceholder(isError: true),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool isError;
  const _ImagePlaceholder({this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColor.backgroundcolor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isError ? Icons.broken_image_outlined : Icons.image_outlined,
        color: AppColor.greyText.withOpacity(0.5),
        size: 32,
      ),
    );
  }
}

// ── Store chip ─────────────────────────────────────────────────────────────────
class _StoreChip extends StatelessWidget {
  final String storeName;
  const _StoreChip({required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.storefront_rounded,
            size: 12, color: AppColor.primaryColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            storeName,
            style: TextStyle(
              fontSize: 11,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Variant badge ──────────────────────────────────────────────────────────────
class _VariantBadge extends StatelessWidget {
  final String variant;
  const _VariantBadge({required this.variant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.backgroundcolor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        variant,
        style: TextStyle(fontSize: 10.5, color: AppColor.greyText),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Price column ───────────────────────────────────────────────────────────────
class _PriceColumn extends StatelessWidget {
  final CartItem item;
  const _PriceColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current price
        Text(
          '${item.price.toStringAsFixed(2)} ${'currency'.tr}',
          style: TextStyle(
            color: AppColor.primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        if (item.originalPrice != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                '${item.originalPrice!.toStringAsFixed(2)} ${'currency'.tr}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColor.greyText,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColor.greyText,
                ),
              ),
              if (item.discountPercent != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '-${item.discountPercent!.toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColor.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

// ── Quantity control ───────────────────────────────────────────────────────────
class _QuantityControl extends StatelessWidget {
  final CartItem item;
  final CartController controller;
  const _QuantityControl({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isAtMin = item.quantity == 1;
    final isAtMax = item.quantity >= item.maxStock;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColor.backgroundcolor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease / delete button
          _QBtn(
            icon: isAtMin
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            onTap: () => controller.decreaseQuantity(item.id),
            color: isAtMin ? AppColor.danger : AppColor.primaryColor,
          ),

          // Quantity display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: SizedBox(
              key: ValueKey(item.quantity),
              width: 34,
              child: Center(
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          // Increase button
          _QBtn(
            icon: Icons.add_rounded,
            onTap: isAtMax
                ? null
                : () => controller.increaseQuantity(item.id),
            color: isAtMax
                ? AppColor.greyText.withOpacity(0.4)
                : AppColor.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _QBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 38,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
