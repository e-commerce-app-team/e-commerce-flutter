import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

import '../../../../core/constant/routes.dart';
import '../../../screen/seller/inventory/add_edit_product_screen.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_box_outlined,
        label: 'add_product'.tr,
        color: AppColor.primaryColor,
        lightColor: AppColor.primarySurface,
        onTap: () {
          Get.to(() => const AddEditProductScreen(), transition: Transition.cupertino);        },
      ),
      _QuickAction(
        icon: Icons.local_offer_outlined,
        label: 'new_coupon'.tr,
        color: AppColor.statOrders,
        lightColor: const Color(0xffEEEDFE),
        onTap: () {
         Get.toNamed(AppRoute.coupons);
        },
      ),
      _QuickAction(
        icon: Icons.bar_chart_rounded,
        label: 'reports'.tr,
        color: AppColor.statViews,
        lightColor: AppColor.infoLight,
        onTap: () {
       Get.toNamed(AppRoute.sellerInvoices);
        },
      ),
      _QuickAction(
        icon: Icons.campaign_outlined,
        label: 'run_ad'.tr,
        color: AppColor.statAvg,
        lightColor: AppColor.successLight,
        onTap: () {
           Get.toNamed(AppRoute.ads);
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions,
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp:   (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.lightColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, size: 22, color: widget.color),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: AppTextStyle.labelSmall.copyWith(
                color: AppColor.black,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class PeriodSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _periods = [
    _PeriodItem(key: 'today',   labelKey: 'today'),
    _PeriodItem(key: 'weekly',  labelKey: 'weekly'),
    _PeriodItem(key: 'monthly', labelKey: 'monthly'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _periods.map((a) {
          final isActive = selected == a.key;
          return GestureDetector(
            onTap: () => onChanged(a.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? AppColor.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isActive ? AppColor.primaryShadow : null,
              ),
              child: Text(
                a.labelKey.tr,
                style: AppTextStyle.labelSmall.copyWith(
                  color: isActive ? Colors.white : AppColor.grey,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PeriodItem {
  final String key;
  final String labelKey;
  const _PeriodItem({required this.key, required this.labelKey});
}


class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyle.heading3),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: AppTextStyle.labelMedium.copyWith(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColor.primaryColor,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
