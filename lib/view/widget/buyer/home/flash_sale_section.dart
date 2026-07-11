import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_product_card.dart';

/// The one saturated, high-contrast moment on an otherwise quiet white
/// page. Everywhere else spends the brand color sparingly as an accent;
/// this section spends it all at once — the three-stop [AppColor.headerGradient]
/// fills the whole card — so it reads as a genuine "stop and look" moment
/// rather than just another section with a colored label.
class FlashSaleSection extends StatefulWidget {
  final List<BuyerProductItem> products;
  final Duration remaining;
  final VoidCallback? onSeeAll;
  final void Function(int index)? onProductTap;
  final void Function(int index)? onAddToCart;

  const FlashSaleSection({
    Key? key,
    required this.products,
    required this.remaining,
    this.onSeeAll,
    this.onProductTap,
    this.onAddToCart,
  }) : super(key: key);

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.remaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    final hours = _two(_remaining.inHours);
    final minutes = _two(_remaining.inMinutes.remainder(60));
    final seconds = _two(_remaining.inSeconds.remainder(60));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColor.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColor.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColor.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'flash_sale_title'.tr,
                  style: AppTextStyle.heading2.copyWith(color: AppColor.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.onSeeAll != null)
                InkWell(
                  onTap: widget.onSeeAll,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColor.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: AppColor.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'flash_sale_ends_in'.tr,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.white.withOpacity(0.85),
                ),
              ),
              const Spacer(),
              _CountdownUnit(value: hours),
              _colon(),
              _CountdownUnit(value: minutes),
              _colon(),
              _CountdownUnit(value: seconds),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 244,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 148,
                  child: BuyerProductCard(
                    product: widget.products[index],
                    onTap: widget.onProductTap == null
                        ? null
                        : () => widget.onProductTap!(index),
                    onAddToCart: widget.onAddToCart == null
                        ? null
                        : () => widget.onAddToCart!(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _colon() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(
          ':',
          style: AppTextStyle.orderNumber.copyWith(color: AppColor.white),
        ),
      );
}

class _CountdownUnit extends StatelessWidget {
  final String value;

  const _CountdownUnit({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: AppTextStyle.orderNumber.copyWith(color: AppColor.white),
      ),
    );
  }
}
