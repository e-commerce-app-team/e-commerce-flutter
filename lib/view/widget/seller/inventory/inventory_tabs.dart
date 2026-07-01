import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class InventoryTabs extends StatelessWidget {
  final SellerInventoryController ctrl;
  const InventoryTabs({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (label: 'tab_all'.tr,      count: ctrl.allCount,      alert: false),
      (label: 'tab_active'.tr,   count: ctrl.activeCount,   alert: false),
      (label: 'tab_low_stock'.tr,count: ctrl.lowStockCount, alert: ctrl.lowStockCount > 0),
      (label: 'tab_draft'.tr,    count: ctrl.draftCount,    alert: false),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final isActive = ctrl.selectedTabIndex == i;
          final t = tabs[i];
          return GestureDetector(
            onTap: () => ctrl.changeTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.label,
                    style: AppTextStyle.chip.copyWith(
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (t.count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: t.alert && isActive
                            ? AppColor.error
                            : Colors.white.withOpacity(isActive ? 0.3 : 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${t.count}',
                        style: AppTextStyle.badge.copyWith(fontSize: 9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}